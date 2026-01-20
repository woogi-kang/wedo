import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/exceptions/auth_exception.dart';
import '../models/user_model.dart';

/// Auth Remote DataSource 인터페이스
///
/// Firebase Auth와 Firestore를 사용하는 원격 데이터 소스의 추상 인터페이스입니다.
abstract interface class AuthRemoteDataSource {
  /// 회원가입
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// 로그인
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  /// 로그아웃
  Future<void> signOut();

  /// 현재 사용자 조회
  UserModel? getCurrentUser();

  /// 인증 상태 변경 스트림
  Stream<UserModel?> authStateChanges();

  /// FCM 토큰 업데이트
  Future<void> updateFcmToken(String token);

  /// Firestore에서 사용자 정보 조회
  Future<UserModel?> getUserFromFirestore(String uid);

  /// Anonymous 로그인
  Future<UserModel> signInAnonymously();

  /// 사용자 displayName 업데이트
  Future<UserModel> updateDisplayName(String displayName);

  /// Firestore에 완전한 사용자 프로필이 있는지 확인
  Future<bool> hasCompleteProfile(String uid);
}

/// Auth Remote DataSource 구현체
///
/// Firebase Auth와 Cloud Firestore를 사용하여 인증 관련 작업을 수행합니다.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// Firestore users 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// 현재 캐시된 사용자 모델
  UserModel? _cachedUser;

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // 1. Firebase Auth로 사용자 생성
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw SignUpException.unknown('사용자 생성 후 정보를 가져올 수 없습니다.');
      }

      // 2. Firebase Auth 프로필 업데이트
      await firebaseUser.updateDisplayName(displayName);

      // 3. UserModel 생성
      final userModel = UserModel.create(
        uid: firebaseUser.uid,
        email: email,
        displayName: displayName,
      );

      // 4. Firestore에 사용자 문서 저장
      await _usersCollection.doc(firebaseUser.uid).set(userModel.toFirestore());

      // 5. 캐시 업데이트
      _cachedUser = userModel;

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e, isSignUp: true);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw SignUpException.unknown(e.toString());
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Firebase Auth로 로그인
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw SignInException.unknown('로그인 후 사용자 정보를 가져올 수 없습니다.');
      }

      // 2. Firestore에서 사용자 정보 조회
      final userModel = await getUserFromFirestore(firebaseUser.uid);
      if (userModel == null) {
        throw const UserNotFoundException('Firestore에서 사용자 정보를 찾을 수 없습니다.');
      }

      // 3. 캐시 업데이트
      _cachedUser = userModel;

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e, isSignUp: false);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw SignInException.unknown(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _cachedUser = null;
    } catch (e) {
      throw SignOutException.unknown(e.toString());
    }
  }

  @override
  UserModel? getCurrentUser() {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      _cachedUser = null;
      return null;
    }

    // 캐시된 사용자가 있고 UID가 일치하면 캐시 반환
    if (_cachedUser != null && _cachedUser!.uid == firebaseUser.uid) {
      return _cachedUser;
    }

    return null;
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        _cachedUser = null;
        return null;
      }

      try {
        // Firestore에서 최신 사용자 정보 조회
        final userModel = await getUserFromFirestore(firebaseUser.uid);

        if (userModel != null) {
          _cachedUser = userModel;
          return userModel;
        }

        // Firestore에 문서가 없어도 Firebase Auth 정보로 임시 UserModel 생성
        // Anonymous 로그인 직후에는 Firestore 문서가 없을 수 있음
        final tempUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _cachedUser = tempUser;
        return tempUser;
      } catch (e) {
        // Firestore 조회 실패 시에도 Firebase Auth 정보로 임시 UserModel 생성
        final tempUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _cachedUser = tempUser;
        return tempUser;
      }
    }).handleError((error) {
      // 스트림 에러 발생 시 캐시 초기화 후 null 반환
      _cachedUser = null;
      // 에러를 다시 던지지 않고 null로 처리하여 스트림 유지
    });
  }

  @override
  Future<void> updateFcmToken(String token) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      throw const UpdateFcmTokenException('로그인이 필요합니다.');
    }

    try {
      await _usersCollection.doc(firebaseUser.uid).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 캐시 업데이트
      if (_cachedUser != null) {
        _cachedUser = _cachedUser!.copyWith(
          fcmToken: token,
          updatedAt: DateTime.now(),
        );
      }
    } on FirebaseException catch (e) {
      throw UpdateFcmTokenException(e.message ?? 'FCM 토큰 업데이트 실패');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw UpdateFcmTokenException(e.toString());
    }
  }

  @override
  Future<UserModel?> getUserFromFirestore(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) {
        return null;
      }
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw FirestoreException.unknown(e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw FirestoreException.unknown(e.toString());
    }
  }

  @override
  Future<UserModel> signInAnonymously() async {
    try {
      // 1. Firebase Anonymous 로그인
      final credential = await _firebaseAuth.signInAnonymously();
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw SignInException.unknown('익명 로그인 후 사용자 정보를 가져올 수 없습니다.');
      }

      // 2. Firestore에서 기존 사용자 문서 확인
      final existingUser = await getUserFromFirestore(firebaseUser.uid);
      if (existingUser != null) {
        _cachedUser = existingUser;
        return existingUser;
      }

      // 3. 새 사용자인 경우 - displayName 없는 임시 UserModel 반환
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: '',
        displayName: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 캐시 업데이트 - 새 사용자도 캐시에 저장
      _cachedUser = userModel;

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SignInException.unknown(e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw SignInException.unknown(e.toString());
    }
  }

  @override
  Future<UserModel> updateDisplayName(String displayName) async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      throw const UserNotFoundException('로그인이 필요합니다.');
    }

    try {
      // 1. Firebase Auth 프로필 업데이트
      await firebaseUser.updateDisplayName(displayName);

      // 2. Firestore에서 기존 문서 확인
      final existingUser = await getUserFromFirestore(firebaseUser.uid);
      final now = DateTime.now();

      final UserModel userModel;
      if (existingUser != null) {
        // 기존 문서가 있으면 업데이트만
        userModel = existingUser.copyWith(
          displayName: displayName,
          updatedAt: now,
        );
        // UPDATE: 기존 문서 업데이트
        await _usersCollection.doc(firebaseUser.uid).update({
          'displayName': displayName,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // 새 문서 생성 - Security Rules에 맞는 필수 필드만 포함
        userModel = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: displayName,
          createdAt: now,
          updatedAt: now,
        );
        // CREATE: 새 문서 생성 (merge 없이)
        await _usersCollection.doc(firebaseUser.uid).set(
              _toFirestoreForCreate(userModel),
            );
      }

      // 3. 캐시 업데이트
      _cachedUser = userModel;

      return userModel;
    } on FirebaseException catch (e) {
      throw FirestoreException.unknown(e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw FirestoreException.unknown(e.toString());
    }
  }

  /// Security Rules CREATE에 맞는 Firestore 문서 생성
  /// null 값 필드는 제외하고 필수 필드만 포함
  Map<String, dynamic> _toFirestoreForCreate(UserModel model) {
    final data = <String, dynamic>{
      'uid': model.uid,
      'displayName': model.displayName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    // email은 빈 문자열이 아닐 때만 포함
    if (model.email.isNotEmpty) {
      data['email'] = model.email;
    }
    return data;
  }

  @override
  Future<bool> hasCompleteProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null) return false;

      final displayName = data['displayName'] as String?;
      return displayName != null && displayName.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Firebase Auth 예외를 앱 예외로 변환
  AuthException _mapFirebaseAuthException(
    firebase_auth.FirebaseAuthException e, {
    required bool isSignUp,
  }) {
    if (isSignUp) {
      return switch (e.code) {
        'email-already-in-use' => SignUpException.emailAlreadyInUse(),
        'invalid-email' => SignUpException.invalidEmail(),
        'weak-password' => SignUpException.weakPassword(),
        'operation-not-allowed' => SignUpException.operationNotAllowed(),
        _ => SignUpException.unknown(e.message),
      };
    } else {
      return switch (e.code) {
        'user-not-found' => SignInException.userNotFound(),
        'wrong-password' => SignInException.wrongPassword(),
        'invalid-email' => SignInException.invalidEmail(),
        'user-disabled' => SignInException.userDisabled(),
        'too-many-requests' => SignInException.tooManyRequests(),
        'invalid-credential' => SignInException.invalidCredential(),
        _ => SignInException.unknown(e.message),
      };
    }
  }
}
