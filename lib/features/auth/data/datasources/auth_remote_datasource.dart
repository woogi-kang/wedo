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

      // Firestore에서 최신 사용자 정보 조회
      final userModel = await getUserFromFirestore(firebaseUser.uid);
      _cachedUser = userModel;
      return userModel;
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
