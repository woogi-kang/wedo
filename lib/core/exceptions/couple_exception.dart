// Couple 관련 커스텀 예외 클래스
//
// 커플 매칭 기능 관련 작업 중 발생하는 에러를 앱 레벨에서
// 일관성 있게 처리하기 위한 예외 클래스 정의

/// Couple 관련 기본 예외 클래스
sealed class CoupleException implements Exception {
  const CoupleException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => 'CoupleException: $message (code: $code)';
}

/// 커플 생성 실패 예외
class CreateCoupleException extends CoupleException {
  const CreateCoupleException(super.message, [super.code]);

  factory CreateCoupleException.alreadyInCouple() => const CreateCoupleException(
        '이미 커플에 속해 있습니다.',
        'already-in-couple',
      );

  factory CreateCoupleException.invalidUser() => const CreateCoupleException(
        '유효하지 않은 사용자입니다.',
        'invalid-user',
      );

  factory CreateCoupleException.unknown([String? message]) => CreateCoupleException(
        message ?? '커플 생성 중 알 수 없는 오류가 발생했습니다.',
        'unknown',
      );
}

/// 커플 합류 실패 예외
class JoinCoupleException extends CoupleException {
  const JoinCoupleException(super.message, [super.code]);

  factory JoinCoupleException.invalidInviteCode() => const JoinCoupleException(
        '유효하지 않은 초대 코드입니다.',
        'invalid-invite-code',
      );

  factory JoinCoupleException.coupleFull() => const JoinCoupleException(
        '이미 커플이 완성되어 참여할 수 없습니다.',
        'couple-full',
      );

  factory JoinCoupleException.alreadyInCouple() => const JoinCoupleException(
        '이미 다른 커플에 속해 있습니다.',
        'already-in-couple',
      );

  factory JoinCoupleException.cannotJoinOwnCouple() => const JoinCoupleException(
        '자신이 생성한 커플에는 참여할 수 없습니다.',
        'cannot-join-own-couple',
      );

  factory JoinCoupleException.expiredInviteCode() => const JoinCoupleException(
        '만료된 초대 코드입니다.',
        'expired-invite-code',
      );

  factory JoinCoupleException.unknown([String? message]) => JoinCoupleException(
        message ?? '커플 합류 중 알 수 없는 오류가 발생했습니다.',
        'unknown',
      );
}

/// 커플 조회 실패 예외
class GetCoupleException extends CoupleException {
  const GetCoupleException(super.message, [super.code]);

  factory GetCoupleException.notFound() => const GetCoupleException(
        '커플을 찾을 수 없습니다.',
        'couple-not-found',
      );

  factory GetCoupleException.permissionDenied() => const GetCoupleException(
        '권한이 없습니다.',
        'permission-denied',
      );

  factory GetCoupleException.unknown([String? message]) => GetCoupleException(
        message ?? '커플 조회 중 알 수 없는 오류가 발생했습니다.',
        'unknown',
      );
}

/// 초대 코드 관련 예외
class InviteCodeException extends CoupleException {
  const InviteCodeException(super.message, [super.code]);

  factory InviteCodeException.generationFailed() => const InviteCodeException(
        '초대 코드 생성에 실패했습니다.',
        'generation-failed',
      );

  factory InviteCodeException.duplicateCode() => const InviteCodeException(
        '중복된 초대 코드입니다. 다시 시도해주세요.',
        'duplicate-code',
      );

  factory InviteCodeException.unknown([String? message]) => InviteCodeException(
        message ?? '초대 코드 처리 중 알 수 없는 오류가 발생했습니다.',
        'unknown',
      );
}
