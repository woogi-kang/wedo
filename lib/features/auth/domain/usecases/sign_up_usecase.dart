import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// 회원가입 Use Case
///
/// Clean Architecture의 Use Case 패턴을 따릅니다.
/// 단일 책임 원칙에 따라 회원가입 로직만 처리합니다.
class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  /// 회원가입 실행
  ///
  /// [email] 사용자 이메일
  /// [password] 비밀번호
  /// [displayName] 표시 이름
  ///
  /// Returns: 생성된 [User] 엔티티
  /// Throws: [SignUpException] 회원가입 실패 시
  Future<User> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _repository.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
