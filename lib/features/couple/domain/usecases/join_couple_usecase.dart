import '../entities/couple.dart';
import '../repositories/couple_repository.dart';

/// 커플 합류 Use Case
///
/// Clean Architecture의 Use Case 패턴을 따릅니다.
/// 단일 책임 원칙에 따라 초대 코드를 통한 커플 합류 로직만 처리합니다.
class JoinCoupleUseCase {
  const JoinCoupleUseCase(this._repository);

  final CoupleRepository _repository;

  /// 커플 합류 실행
  ///
  /// [userId] 합류하는 사용자 ID
  /// [inviteCode] 6자리 초대 코드
  ///
  /// Returns: 합류한 [Couple] 엔티티
  /// Throws: [JoinCoupleException] 커플 합류 실패 시
  Future<Couple> call({
    required String userId,
    required String inviteCode,
  }) {
    return _repository.joinCouple(
      userId: userId,
      inviteCode: inviteCode,
    );
  }
}
