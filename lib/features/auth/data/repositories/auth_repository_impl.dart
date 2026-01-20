import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// AuthRepository 구현체
///
/// Clean Architecture의 Repository 패턴 구현체입니다.
/// Domain 레이어의 AuthRepository 인터페이스를 구현하고,
/// AuthRemoteDataSource를 사용하여 실제 데이터 작업을 수행합니다.
///
/// Repository는 데이터 소스를 추상화하여 도메인 레이어가
/// 구체적인 데이터 소스 구현에 의존하지 않도록 합니다.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final userModel = await _remoteDataSource.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    return userModel.toEntity();
  }

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final userModel = await _remoteDataSource.signIn(
      email: email,
      password: password,
    );
    return userModel.toEntity();
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }

  @override
  User? getCurrentUser() {
    final userModel = _remoteDataSource.getCurrentUser();
    return userModel?.toEntity();
  }

  @override
  Stream<User?> authStateChanges() {
    return _remoteDataSource.authStateChanges().map(
          (userModel) => userModel?.toEntity(),
        );
  }

  @override
  Future<void> updateFcmToken(String token) {
    return _remoteDataSource.updateFcmToken(token);
  }

  @override
  Future<User> signInAnonymously() async {
    final userModel = await _remoteDataSource.signInAnonymously();
    return userModel.toEntity();
  }

  @override
  Future<User> updateDisplayName(String displayName) async {
    final userModel = await _remoteDataSource.updateDisplayName(displayName);
    return userModel.toEntity();
  }

  @override
  Future<bool> hasCompleteProfile(String uid) {
    return _remoteDataSource.hasCompleteProfile(uid);
  }
}
