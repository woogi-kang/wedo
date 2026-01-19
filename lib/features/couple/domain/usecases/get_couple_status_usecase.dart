import '../entities/couple.dart';
import '../repositories/couple_repository.dart';

/// 커플 상태 조회 Use Case
///
/// Clean Architecture의 Use Case 패턴을 따릅니다.
/// 단일 책임 원칙에 따라 사용자의 커플 상태 조회 로직만 처리합니다.
class GetCoupleStatusUseCase {
  const GetCoupleStatusUseCase(this._repository);

  final CoupleRepository _repository;

  /// 사용자의 커플 상태 조회 실행
  ///
  /// [userId] 조회할 사용자 ID
  ///
  /// Returns: [Couple] 엔티티 또는 null (커플이 없는 경우)
  /// Throws: [GetCoupleException] 조회 실패 시
  Future<Couple?> call({required String userId}) {
    return _repository.getCoupleByUserId(userId: userId);
  }

  /// 커플 상태 변경 스트림 구독
  ///
  /// [coupleId] 구독할 커플 ID
  ///
  /// Returns: [Couple] 스트림 (실시간 상태 변경 감지)
  Stream<Couple?> watch({required String coupleId}) {
    return _repository.coupleStateChanges(coupleId: coupleId);
  }
}
