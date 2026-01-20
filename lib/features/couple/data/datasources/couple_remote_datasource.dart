import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/exceptions/couple_exception.dart';
import '../../../../core/utils/invite_code_generator.dart';
import '../models/couple_model.dart';

/// Couple Remote DataSource 인터페이스
///
/// Cloud Firestore를 사용하는 원격 데이터 소스의 추상 인터페이스입니다.
abstract interface class CoupleRemoteDataSource {
  /// 새 커플 생성
  Future<CoupleModel> createCouple({required String userId});

  /// 초대 코드로 커플 합류
  Future<CoupleModel> joinCouple({
    required String userId,
    required String inviteCode,
  });

  /// 커플 ID로 커플 조회
  Future<CoupleModel?> getCouple({required String coupleId});

  /// 초대 코드로 커플 조회
  Future<CoupleModel?> getCoupleByInviteCode({required String inviteCode});

  /// 사용자 ID로 커플 조회
  Future<CoupleModel?> getCoupleByUserId({required String userId});

  /// 커플 상태 변경 스트림
  Stream<CoupleModel?> coupleStateChanges({required String coupleId});
}

/// Couple Remote DataSource 구현체
///
/// Cloud Firestore를 사용하여 커플 관련 작업을 수행합니다.
class CoupleRemoteDataSourceImpl implements CoupleRemoteDataSource {
  CoupleRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    InviteCodeGenerator? inviteCodeGenerator,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _inviteCodeGenerator = inviteCodeGenerator ?? InviteCodeGenerator();

  final FirebaseFirestore _firestore;
  final InviteCodeGenerator _inviteCodeGenerator;

  /// 최대 초대 코드 생성 재시도 횟수
  static const int _maxInviteCodeRetries = 10;

  /// Firestore couples 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _couplesCollection =>
      _firestore.collection('couples');

  /// Firestore users 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<CoupleModel> createCouple({required String userId}) async {
    try {
      // 1. 사용자가 이미 커플에 속해 있는지 확인
      final existingCouple = await getCoupleByUserId(userId: userId);
      if (existingCouple != null) {
        throw CreateCoupleException.alreadyInCouple();
      }

      // 2. 고유한 초대 코드 생성 (중복 체크)
      String inviteCode;
      int retries = 0;

      do {
        inviteCode = _inviteCodeGenerator.generate();
        final existing = await getCoupleByInviteCode(inviteCode: inviteCode);
        if (existing == null) break;
        retries++;
      } while (retries < _maxInviteCodeRetries);

      if (retries >= _maxInviteCodeRetries) {
        throw InviteCodeException.generationFailed();
      }

      // 3. 새 커플 문서 생성
      final docRef = _couplesCollection.doc();
      final coupleModel = CoupleModel.create(
        id: docRef.id,
        inviteCode: inviteCode,
        creatorUserId: userId,
      );

      // 4. Firestore 트랜잭션으로 커플 생성 및 사용자 업데이트
      await _firestore.runTransaction((transaction) async {
        // 커플 문서 생성
        transaction.set(docRef, coupleModel.toFirestore());

        // 사용자 문서에 coupleId 업데이트
        final userRef = _usersCollection.doc(userId);
        transaction.update(userRef, {
          'coupleId': docRef.id,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return coupleModel;
    } on CoupleException {
      rethrow;
    } on FirebaseException catch (e) {
      throw CreateCoupleException.unknown(e.message);
    } catch (e) {
      if (e is CoupleException) rethrow;
      throw CreateCoupleException.unknown(e.toString());
    }
  }

  @override
  Future<CoupleModel> joinCouple({
    required String userId,
    required String inviteCode,
  }) async {
    try {
      // 1. 초대 코드 정규화
      final normalizedCode = InviteCodeGenerator.normalize(inviteCode);

      // 2. 초대 코드 형식 검증
      if (!InviteCodeGenerator.isValidFormat(normalizedCode)) {
        throw JoinCoupleException.invalidInviteCode();
      }

      // 3. 사용자가 이미 커플에 속해 있는지 확인
      final existingCouple = await getCoupleByUserId(userId: userId);
      if (existingCouple != null) {
        throw JoinCoupleException.alreadyInCouple();
      }

      // 4. 초대 코드로 커플 조회
      final coupleModel = await getCoupleByInviteCode(inviteCode: normalizedCode);
      if (coupleModel == null) {
        throw JoinCoupleException.invalidInviteCode();
      }

      // 5. 커플이 이미 완성되었는지 확인
      if (coupleModel.members.length >= 2) {
        throw JoinCoupleException.coupleFull();
      }

      // 6. 자신이 생성한 커플인지 확인
      if (coupleModel.members.contains(userId)) {
        throw JoinCoupleException.cannotJoinOwnCouple();
      }

      // 7. Firestore 트랜잭션으로 커플 합류 처리
      final updatedCouple = coupleModel.addPartner(userId);
      final partnerId = coupleModel.members.first;

      await _firestore.runTransaction((transaction) async {
        final coupleRef = _couplesCollection.doc(coupleModel.id);

        // 커플 문서 업데이트
        transaction.update(coupleRef, {
          'members': updatedCouple.members,
          'connectedAt': Timestamp.fromDate(updatedCouple.connectedAt!),
        });

        // 합류한 사용자의 문서 업데이트
        final userRef = _usersCollection.doc(userId);
        transaction.update(userRef, {
          'coupleId': coupleModel.id,
          'partnerId': partnerId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 커플 생성자의 문서 업데이트
        final partnerRef = _usersCollection.doc(partnerId);
        transaction.update(partnerRef, {
          'partnerId': userId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      return updatedCouple;
    } on CoupleException {
      rethrow;
    } on FirebaseException catch (e) {
      throw JoinCoupleException.unknown(e.message);
    } catch (e) {
      if (e is CoupleException) rethrow;
      throw JoinCoupleException.unknown(e.toString());
    }
  }

  @override
  Future<CoupleModel?> getCouple({required String coupleId}) async {
    try {
      final doc = await _couplesCollection.doc(coupleId).get();
      if (!doc.exists) {
        return null;
      }
      return CoupleModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw GetCoupleException.unknown(e.message);
    } catch (e) {
      if (e is CoupleException) rethrow;
      throw GetCoupleException.unknown(e.toString());
    }
  }

  @override
  Future<CoupleModel?> getCoupleByInviteCode({required String inviteCode}) async {
    try {
      final normalizedCode = InviteCodeGenerator.normalize(inviteCode);
      final query = await _couplesCollection
          .where('inviteCode', isEqualTo: normalizedCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }
      return CoupleModel.fromFirestore(query.docs.first);
    } on FirebaseException catch (e) {
      throw GetCoupleException.unknown(e.message);
    } catch (e) {
      if (e is CoupleException) rethrow;
      throw GetCoupleException.unknown(e.toString());
    }
  }

  @override
  Future<CoupleModel?> getCoupleByUserId({required String userId}) async {
    try {
      final query = await _couplesCollection
          .where('members', arrayContains: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return null;
      }
      return CoupleModel.fromFirestore(query.docs.first);
    } on FirebaseException catch (e) {
      throw GetCoupleException.unknown(e.message);
    } catch (e) {
      if (e is CoupleException) rethrow;
      throw GetCoupleException.unknown(e.toString());
    }
  }

  @override
  Stream<CoupleModel?> coupleStateChanges({required String coupleId}) {
    return _couplesCollection.doc(coupleId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      try {
        return CoupleModel.fromFirestore(doc);
      } catch (e) {
        // 문서 변환 실패 시 null 반환
        return null;
      }
    }).handleError((error) {
      // 스트림 에러 발생 시 예외로 변환
      if (error is FirebaseException) {
        throw GetCoupleException.unknown(error.message);
      }
      throw GetCoupleException.unknown(error.toString());
    });
  }
}
