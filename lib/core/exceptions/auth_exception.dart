// Auth 관련 커스텀 예외 클래스
//
// Firebase Auth 및 Firestore 작업 중 발생하는 에러를 앱 레벨에서
// 일관성 있게 처리하기 위한 예외 클래스 정의

/// Auth 관련 기본 예외 클래스
sealed class AuthException implements Exception {
  const AuthException(this.message, [this.code]);

  final String message;
  final String? code;

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

/// 회원가입 실패 예외
class SignUpException extends AuthException {
  const SignUpException(super.message, [super.code]);

  factory SignUpException.emailAlreadyInUse() =>
      const SignUpException('이미 사용 중인 이메일입니다.', 'email-already-in-use');

  factory SignUpException.invalidEmail() =>
      const SignUpException('유효하지 않은 이메일 형식입니다.', 'invalid-email');

  factory SignUpException.weakPassword() =>
      const SignUpException('비밀번호가 너무 약합니다.', 'weak-password');

  factory SignUpException.operationNotAllowed() =>
      const SignUpException('이메일/비밀번호 로그인이 비활성화되어 있습니다.', 'operation-not-allowed');

  factory SignUpException.unknown([String? message]) =>
      SignUpException(message ?? '회원가입 중 알 수 없는 오류가 발생했습니다.', 'unknown');
}

/// 로그인 실패 예외
class SignInException extends AuthException {
  const SignInException(super.message, [super.code]);

  factory SignInException.userNotFound() =>
      const SignInException('등록되지 않은 사용자입니다.', 'user-not-found');

  factory SignInException.wrongPassword() =>
      const SignInException('잘못된 비밀번호입니다.', 'wrong-password');

  factory SignInException.invalidEmail() =>
      const SignInException('유효하지 않은 이메일 형식입니다.', 'invalid-email');

  factory SignInException.userDisabled() =>
      const SignInException('비활성화된 계정입니다.', 'user-disabled');

  factory SignInException.tooManyRequests() =>
      const SignInException('너무 많은 로그인 시도가 있었습니다. 잠시 후 다시 시도해주세요.', 'too-many-requests');

  factory SignInException.invalidCredential() =>
      const SignInException('잘못된 인증 정보입니다.', 'invalid-credential');

  factory SignInException.unknown([String? message]) =>
      SignInException(message ?? '로그인 중 알 수 없는 오류가 발생했습니다.', 'unknown');
}

/// 로그아웃 실패 예외
class SignOutException extends AuthException {
  const SignOutException(super.message, [super.code]);

  factory SignOutException.unknown([String? message]) =>
      SignOutException(message ?? '로그아웃 중 알 수 없는 오류가 발생했습니다.', 'unknown');
}

/// 사용자 조회 실패 예외
class UserNotFoundException extends AuthException {
  const UserNotFoundException([String? message])
      : super(message ?? '사용자를 찾을 수 없습니다.', 'user-not-found');
}

/// FCM 토큰 업데이트 실패 예외
class UpdateFcmTokenException extends AuthException {
  const UpdateFcmTokenException([String? message])
      : super(message ?? 'FCM 토큰 업데이트에 실패했습니다.', 'update-fcm-token-failed');
}

/// Firestore 작업 실패 예외
class FirestoreException extends AuthException {
  const FirestoreException(super.message, [super.code]);

  factory FirestoreException.documentNotFound() =>
      const FirestoreException('문서를 찾을 수 없습니다.', 'document-not-found');

  factory FirestoreException.permissionDenied() =>
      const FirestoreException('권한이 없습니다.', 'permission-denied');

  factory FirestoreException.unknown([String? message]) =>
      FirestoreException(message ?? 'Firestore 작업 중 오류가 발생했습니다.', 'unknown');
}
