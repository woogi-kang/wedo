import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// WeDo 사용자 엔티티
///
/// 도메인 레이어의 핵심 엔티티로, 비즈니스 로직에서 사용됩니다.
/// Firestore 'users' 컬렉션의 문서 구조와 매핑됩니다.
///
/// Firestore 구조:
/// ```
/// /users/{userId}
///   - uid: string
///   - email: string
///   - displayName: string
///   - coupleId: string?
///   - partnerId: string?
///   - fcmToken: string?
///   - createdAt: timestamp
///   - updatedAt: timestamp
/// ```
@freezed
class User with _$User {
  const factory User({
    /// Firebase Auth UID
    required String uid,

    /// 사용자 이메일
    required String email,

    /// 사용자 표시 이름
    required String displayName,

    /// 연결된 커플 ID (커플 매칭 시 생성)
    String? coupleId,

    /// 파트너 사용자 ID
    String? partnerId,

    /// Firebase Cloud Messaging 토큰 (푸시 알림용)
    String? fcmToken,

    /// 계정 생성 일시
    required DateTime createdAt,

    /// 마지막 업데이트 일시
    required DateTime updatedAt,
  }) = _User;

  /// User를 private constructor로 확장하여 getter 추가 가능하게 함
  const User._();

  /// 커플 연결 여부 확인
  bool get isCouplePaired => coupleId != null && partnerId != null;

  /// FCM 토큰 등록 여부 확인
  bool get hasFcmToken => fcmToken != null && fcmToken!.isNotEmpty;
}
