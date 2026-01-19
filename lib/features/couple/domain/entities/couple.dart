import 'package:freezed_annotation/freezed_annotation.dart';

part 'couple.freezed.dart';

/// WeDo 커플 엔티티
///
/// 도메인 레이어의 핵심 엔티티로, 커플 매칭 비즈니스 로직에서 사용됩니다.
/// Firestore 'couples' 컬렉션의 문서 구조와 매핑됩니다.
///
/// Firestore 구조:
/// ```
/// /couples/{coupleId}
///   - id: string
///   - inviteCode: string (unique, 6 chars)
///   - members: array<string> (userId list, max 2)
///   - createdAt: timestamp
///   - connectedAt: timestamp? (null until both joined)
/// ```
@freezed
class Couple with _$Couple {
  const factory Couple({
    /// 커플 고유 ID (Firestore 문서 ID)
    required String id,

    /// 초대 코드 (6자리 영숫자, 대문자)
    required String inviteCode,

    /// 커플 멤버 ID 목록 (최대 2명)
    required List<String> members,

    /// 커플 생성 일시
    required DateTime createdAt,

    /// 커플 연결 완료 일시 (두 번째 멤버 합류 시 설정)
    DateTime? connectedAt,
  }) = _Couple;

  /// Couple을 private constructor로 확장하여 getter 추가 가능하게 함
  const Couple._();

  /// 커플 연결 완료 여부 (2명 모두 합류)
  bool get isConnected => connectedAt != null && members.length == 2;

  /// 첫 번째 멤버 (커플 생성자)
  String? get creatorId => members.isNotEmpty ? members.first : null;

  /// 두 번째 멤버 (초대 코드로 합류한 사용자)
  String? get partnerId => members.length >= 2 ? members[1] : null;

  /// 대기 중 여부 (첫 번째 멤버만 있는 상태)
  bool get isWaitingForPartner => members.length == 1;

  /// 특정 사용자가 이 커플의 멤버인지 확인
  bool isMember(String userId) => members.contains(userId);

  /// 특정 사용자의 파트너 ID 조회
  String? getPartnerId(String userId) {
    if (!isMember(userId) || members.length < 2) return null;
    return members.firstWhere((id) => id != userId);
  }
}
