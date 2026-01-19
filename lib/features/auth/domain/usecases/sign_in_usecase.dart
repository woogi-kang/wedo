import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// 로그인 Use Case
///
/// Clean Architecture의 Use Case 패턴을 따릅니다.
/// 단일 책임 원칙에 따라 로그인 로직만 처리합니다.
class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  /// 로그인 실행
  ///
  /// [email] 사용자 이메일
  /// [password] 비밀번호
  ///
  /// Returns: 로그인된 [User] 엔티티
  /// Throws: [SignInException] 로그인 실패 시
  Future<User> call({
    required String email,
    required String password,
  }) {
    return _repository.signIn(
      email: email,
      password: password,
    );
  }
}
