import '../entities/couple.dart';
import '../repositories/couple_repository.dart';

/// 초대 코드 생성 (커플 생성) Use Case
///
/// Clean Architecture의 Use Case 패턴을 따릅니다.
/// 단일 책임 원칙에 따라 커플 생성 및 초대 코드 발급 로직만 처리합니다.
class CreateInviteCodeUseCase {
  const CreateInviteCodeUseCase(this._repository);

  final CoupleRepository _repository;

  /// 초대 코드 생성 (커플 생성) 실행
  ///
  /// [userId] 커플을 생성하는 사용자 ID
  ///
  /// Returns: 생성된 [Couple] 엔티티 (inviteCode 포함)
  /// Throws: [CreateCoupleException] 커플 생성 실패 시
  Future<Couple> call({required String userId}) {
    return _repository.createCouple(userId: userId);
  }
}
