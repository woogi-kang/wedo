/// WeDo 앱 라우트 경로 상수
///
/// 모든 라우트 경로를 중앙에서 관리
/// 타입 안전한 라우팅을 위한 상수 정의
abstract final class Routes {
  // === Splash & Onboarding ===
  /// 스플래시 화면 (앱 초기 진입점)
  static const String splash = '/';

  /// 온보딩 화면
  static const String onboarding = '/onboarding';

  // === Authentication ===
  /// 로그인 화면
  static const String login = '/login';

  /// 회원가입 화면
  static const String signup = '/signup';

  /// 비밀번호 찾기/재설정
  static const String forgotPassword = '/forgot-password';

  // === Couple Setup ===
  /// 커플 설정/연결 화면
  static const String coupleSetup = '/couple-setup';

  /// 초대 코드 입력 화면
  static const String coupleInvite = '/couple-setup/invite';

  /// 초대 코드 생성/공유 화면
  static const String coupleShare = '/couple-setup/share';

  // === Main Navigation ===
  /// 홈 화면 (메인 Todo 목록)
  static const String home = '/home';

  // === Todo ===
  /// Todo 생성 화면
  static const String todoCreate = '/todo/create';

  /// Todo 상세 화면 (:id 파라미터)
  static const String todoDetail = '/todo/:id';

  /// Todo 수정 화면 (:id 파라미터)
  static const String todoEdit = '/todo/:id/edit';

  /// Todo 상세 경로 생성 헬퍼
  static String todoDetailPath(String id) => '/todo/$id';

  /// Todo 수정 경로 생성 헬퍼
  static String todoEditPath(String id) => '/todo/$id/edit';

  // === Calendar ===
  /// 캘린더 화면
  static const String calendar = '/calendar';

  /// 특정 날짜 Todo 목록
  static const String calendarDate = '/calendar/:date';

  /// 특정 날짜 경로 생성 헬퍼
  static String calendarDatePath(String date) => '/calendar/$date';

  // === Settings ===
  /// 설정 메인 화면
  static const String settings = '/settings';

  /// 프로필 설정
  static const String settingsProfile = '/settings/profile';

  /// 알림 설정
  static const String settingsNotifications = '/settings/notifications';

  /// 테마 설정
  static const String settingsTheme = '/settings/theme';

  /// 커플 관리
  static const String settingsCouple = '/settings/couple';

  /// 앱 정보
  static const String settingsAbout = '/settings/about';

  // === Profile ===
  /// 내 프로필 화면
  static const String profile = '/profile';

  /// 파트너 프로필 화면
  static const String partnerProfile = '/profile/partner';
}

/// 라우트 이름 상수 (GoRouter name 파라미터용)
///
/// context.goNamed() 사용 시 활용
abstract final class RouteNames {
  // === Splash & Onboarding ===
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';

  // === Authentication ===
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgotPassword = 'forgotPassword';

  // === Couple Setup ===
  static const String coupleSetup = 'coupleSetup';
  static const String coupleInvite = 'coupleInvite';
  static const String coupleShare = 'coupleShare';

  // === Main Navigation ===
  static const String home = 'home';

  // === Todo ===
  static const String todoCreate = 'todoCreate';
  static const String todoDetail = 'todoDetail';
  static const String todoEdit = 'todoEdit';

  // === Calendar ===
  static const String calendar = 'calendar';
  static const String calendarDate = 'calendarDate';

  // === Settings ===
  static const String settings = 'settings';
  static const String settingsProfile = 'settingsProfile';
  static const String settingsNotifications = 'settingsNotifications';
  static const String settingsTheme = 'settingsTheme';
  static const String settingsCouple = 'settingsCouple';
  static const String settingsAbout = 'settingsAbout';

  // === Profile ===
  static const String profile = 'profile';
  static const String partnerProfile = 'partnerProfile';
}
