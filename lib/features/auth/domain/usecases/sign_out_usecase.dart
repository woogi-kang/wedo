import '../repositories/auth_repository.dart';

/// 로그아웃 Use Case
///
/// Clean Architecture의 Use Case 패턴을 따릅니다.
/// 단일 책임 원칙에 따라 로그아웃 로직만 처리합니다.
class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  /// 로그아웃 실행
  ///
  /// Throws: [SignOutException] 로그아웃 실패 시
  Future<void> call() {
    return _repository.signOut();
  }
}
