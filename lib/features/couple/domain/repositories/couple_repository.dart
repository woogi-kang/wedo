import '../entities/couple.dart';

/// Couple Repository 인터페이스
///
/// 도메인 레이어에서 정의하는 커플 관련 추상 인터페이스입니다.
/// 데이터 레이어의 CoupleRepositoryImpl에서 구현됩니다.
///
/// Clean Architecture 원칙에 따라 도메인 레이어는 데이터 소스의
/// 구체적인 구현에 의존하지 않습니다.
abstract interface class CoupleRepository {
  /// 새 커플 생성 (초대 코드 발급)
  ///
  /// [userId] 커플을 생성하는 사용자 ID
  ///
  /// Returns: 생성된 [Couple] 엔티티
  /// Throws: [CreateCoupleException] 커플 생성 실패 시
  Future<Couple> createCouple({required String userId});

  /// 초대 코드로 커플 합류
  ///
  /// [userId] 합류하는 사용자 ID
  /// [inviteCode] 6자리 초대 코드
  ///
  /// Returns: 합류한 [Couple] 엔티티
  /// Throws: [JoinCoupleException] 커플 합류 실패 시
  Future<Couple> joinCouple({
    required String userId,
    required String inviteCode,
  });

  /// 커플 ID로 커플 조회
  ///
  /// [coupleId] 조회할 커플 ID
  ///
  /// Returns: [Couple] 엔티티 또는 null (존재하지 않는 경우)
  /// Throws: [GetCoupleException] 조회 실패 시
  Future<Couple?> getCouple({required String coupleId});

  /// 초대 코드로 커플 조회
  ///
  /// [inviteCode] 6자리 초대 코드
  ///
  /// Returns: [Couple] 엔티티 또는 null (존재하지 않는 경우)
  /// Throws: [GetCoupleException] 조회 실패 시
  Future<Couple?> getCoupleByInviteCode({required String inviteCode});

  /// 사용자의 커플 상태 조회
  ///
  /// [userId] 조회할 사용자 ID
  ///
  /// Returns: [Couple] 엔티티 또는 null (커플이 없는 경우)
  /// Throws: [GetCoupleException] 조회 실패 시
  Future<Couple?> getCoupleByUserId({required String userId});

  /// 커플 상태 변경 스트림
  ///
  /// [coupleId] 구독할 커플 ID
  ///
  /// Firestore의 실시간 업데이트를 스트림으로 전달합니다.
  /// 파트너 합류, 연결 완료 등의 상태 변경을 실시간으로 감지합니다.
  ///
  /// Returns: [Couple] 스트림
  Stream<Couple?> coupleStateChanges({required String coupleId});
}
