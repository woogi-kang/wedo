import '../entities/user.dart';

/// Auth Repository 인터페이스
///
/// 도메인 레이어에서 정의하는 인증 관련 추상 인터페이스입니다.
/// 데이터 레이어의 AuthRepositoryImpl에서 구현됩니다.
///
/// Clean Architecture 원칙에 따라 도메인 레이어는 데이터 소스의
/// 구체적인 구현에 의존하지 않습니다.
abstract interface class AuthRepository {
  /// 회원가입
  ///
  /// [email] 사용자 이메일
  /// [password] 비밀번호
  /// [displayName] 표시 이름
  ///
  /// Returns: 생성된 [User] 엔티티
  /// Throws: [SignUpException] 회원가입 실패 시
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// 로그인
  ///
  /// [email] 사용자 이메일
  /// [password] 비밀번호
  ///
  /// Returns: 로그인된 [User] 엔티티
  /// Throws: [SignInException] 로그인 실패 시
  Future<User> signIn({
    required String email,
    required String password,
  });

  /// 로그아웃
  ///
  /// Throws: [SignOutException] 로그아웃 실패 시
  Future<void> signOut();

  /// 현재 로그인된 사용자 조회
  ///
  /// Returns: 로그인된 [User] 또는 null (미로그인 상태)
  User? getCurrentUser();

  /// 인증 상태 변경 스트림
  ///
  /// Firebase Auth의 authStateChanges를 래핑하여
  /// 사용자 로그인/로그아웃 상태 변경을 실시간으로 전달합니다.
  ///
  /// Returns: [User?] 스트림 (로그인 시 User, 로그아웃 시 null)
  Stream<User?> authStateChanges();

  /// FCM 토큰 업데이트
  ///
  /// 푸시 알림을 위한 Firebase Cloud Messaging 토큰을
  /// 현재 사용자의 Firestore 문서에 저장합니다.
  ///
  /// [token] FCM 토큰
  /// Throws: [UpdateFcmTokenException] 업데이트 실패 시
  Future<void> updateFcmToken(String token);

  /// Anonymous 로그인
  ///
  /// Firebase Anonymous 인증을 사용하여 로그인합니다.
  /// 기기 기반의 임시 계정을 생성합니다.
  ///
  /// Returns: 로그인된 [User] 엔티티
  /// Throws: [SignInException] 로그인 실패 시
  Future<User> signInAnonymously();

  /// 사용자 displayName 업데이트
  ///
  /// 사용자의 표시 이름을 설정하거나 업데이트합니다.
  /// Firestore에 사용자 문서가 없으면 생성합니다.
  ///
  /// [displayName] 설정할 표시 이름
  /// Returns: 업데이트된 [User] 엔티티
  Future<User> updateDisplayName(String displayName);

  /// Firestore에 완전한 사용자 프로필이 있는지 확인
  ///
  /// displayName이 설정되어 있는지 확인합니다.
  ///
  /// [uid] 확인할 사용자 ID
  /// Returns: 프로필이 완전하면 true
  Future<bool> hasCompleteProfile(String uid);
}
