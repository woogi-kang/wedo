import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/couple/presentation/pages/couple_setup_page.dart';
import '../../features/couple/presentation/providers/couple_provider.dart';
import '../../features/todo/presentation/pages/home_page.dart';
import '../../features/todo/presentation/pages/todo_create_page.dart';
import '../../features/todo/presentation/pages/todo_detail_page.dart';
import '../../features/todo/presentation/pages/todo_edit_page.dart';
import 'routes.dart';

/// 커플 연결 상태를 bool?로 변환하는 Provider
///
/// null: 로딩 중, true: 연결됨, false: 미연결
/// CoupleState를 라우터에서 사용하기 쉬운 형태로 변환합니다.
final coupleConnectionStateProvider = Provider<bool?>((ref) {
  final coupleState = ref.watch(currentCoupleStateProvider);

  return coupleState.maybeWhen(
    loading: () => null,
    initial: () => null,
    noCouple: () => false,
    waitingForPartner: (_) => false,
    connected: (_) => true,
    error: (_) => false,
    orElse: () => null,
  );
});

/// 앱 라우터 Provider
///
/// go_router를 사용한 선언적 라우팅 구성
/// Riverpod Provider로 전역 접근 가능
final appRouterProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authStateChangesProvider);
  final coupleState = ref.watch(coupleConnectionStateProvider);

  // 인증 상태를 bool?로 변환
  // null: 로딩 중, true: 인증됨, false: 미인증
  final bool? authState = authAsync.when(
    data: (user) => user != null,
    loading: () => null,
    error: (_, __) => false,
  );

  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,

    // 리다이렉트 로직
    redirect: (context, state) {
      final currentPath = state.matchedLocation;
      final isAuthRoute = currentPath == Routes.login ||
          currentPath == Routes.signup ||
          currentPath == Routes.forgotPassword;
      final isSplash = currentPath == Routes.splash;
      final isCoupleSetup = currentPath.startsWith('/couple-setup');

      // 스플래시 화면에서는 리다이렉트하지 않음 (자체 로직으로 처리)
      if (isSplash) {
        return null;
      }

      // 로딩 중이면 스플래시로
      if (authState == null) {
        return Routes.splash;
      }

      // 미인증 상태
      if (authState == false) {
        // 인증 라우트가 아니면 로그인으로
        return isAuthRoute ? null : Routes.login;
      }

      // 인증된 상태
      if (authState == true) {
        // 인증 라우트에 있으면 다음 단계로
        if (isAuthRoute) {
          // 커플 연결 상태 확인
          if (coupleState == false) {
            return Routes.coupleSetup;
          }
          return Routes.home;
        }

        // 커플 미연결 상태에서 커플 설정이 아닌 곳 접근
        if (coupleState == false && !isCoupleSetup) {
          return Routes.coupleSetup;
        }
      }

      return null;
    },

    routes: [
      // === Splash ===
      GoRoute(
        path: Routes.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // === Authentication Routes ===
      GoRoute(
        path: Routes.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.signup,
        name: RouteNames.signup,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const _PlaceholderScreen(
          title: '비밀번호 찾기',
          subtitle: '이메일로 비밀번호를 재설정하세요',
        ),
      ),

      // === Couple Setup Routes ===
      GoRoute(
        path: Routes.coupleSetup,
        name: RouteNames.coupleSetup,
        builder: (context, state) => const CoupleSetupPage(),
      ),

      // === Main Home Route ===
      GoRoute(
        path: Routes.home,
        name: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),

      // === Todo Routes ===
      GoRoute(
        path: Routes.todoCreate,
        name: RouteNames.todoCreate,
        builder: (context, state) => const TodoCreatePage(),
      ),
      GoRoute(
        path: Routes.todoDetail,
        name: RouteNames.todoDetail,
        builder: (context, state) {
          final todoId = state.pathParameters['id'] ?? '';
          return TodoDetailPage(todoId: todoId);
        },
        routes: [
          // 중첩 라우트: /todo/:id/edit
          GoRoute(
            path: 'edit',
            name: RouteNames.todoEdit,
            builder: (context, state) {
              final todoId = state.pathParameters['id'] ?? '';
              return TodoEditPage(todoId: todoId);
            },
          ),
        ],
      ),

      // === Calendar Routes ===
      GoRoute(
        path: Routes.calendar,
        name: RouteNames.calendar,
        builder: (context, state) => const _PlaceholderScreen(
          title: '캘린더',
          subtitle: '일정을 확인하세요',
        ),
      ),
      GoRoute(
        path: Routes.calendarDate,
        name: RouteNames.calendarDate,
        builder: (context, state) {
          final date = state.pathParameters['date'] ?? '';
          return _PlaceholderScreen(
            title: '일정',
            subtitle: '날짜: $date',
          );
        },
      ),

      // === Settings Routes ===
      GoRoute(
        path: Routes.settings,
        name: RouteNames.settings,
        builder: (context, state) => const _PlaceholderScreen(
          title: '설정',
          subtitle: '앱 설정을 관리하세요',
        ),
        routes: [
          GoRoute(
            path: 'profile',
            name: RouteNames.settingsProfile,
            builder: (context, state) => const _PlaceholderScreen(
              title: '프로필 설정',
              subtitle: '프로필 정보를 수정하세요',
            ),
          ),
          GoRoute(
            path: 'notifications',
            name: RouteNames.settingsNotifications,
            builder: (context, state) => const _PlaceholderScreen(
              title: '알림 설정',
              subtitle: '알림을 관리하세요',
            ),
          ),
          GoRoute(
            path: 'theme',
            name: RouteNames.settingsTheme,
            builder: (context, state) => const _PlaceholderScreen(
              title: '테마 설정',
              subtitle: '앱 테마를 변경하세요',
            ),
          ),
          GoRoute(
            path: 'couple',
            name: RouteNames.settingsCouple,
            builder: (context, state) => const _PlaceholderScreen(
              title: '커플 관리',
              subtitle: '커플 연결을 관리하세요',
            ),
          ),
          GoRoute(
            path: 'about',
            name: RouteNames.settingsAbout,
            builder: (context, state) => const _PlaceholderScreen(
              title: '앱 정보',
              subtitle: 'WeDo v1.0.0',
            ),
          ),
        ],
      ),

      // === Profile Routes ===
      GoRoute(
        path: Routes.profile,
        name: RouteNames.profile,
        builder: (context, state) => const _PlaceholderScreen(
          title: '내 프로필',
          subtitle: '프로필을 확인하세요',
        ),
        routes: [
          GoRoute(
            path: 'partner',
            name: RouteNames.partnerProfile,
            builder: (context, state) => const _PlaceholderScreen(
              title: '파트너 프로필',
              subtitle: '파트너 정보를 확인하세요',
            ),
          ),
        ],
      ),
    ],

    // 에러 페이지
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );
});

/// 임시 플레이스홀더 화면 (개발용)
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.construction_rounded,
                  size: 40,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '구현 예정',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 에러 화면
class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('오류'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 40,
                  color: colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '페이지를 찾을 수 없습니다',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (error != null)
                Text(
                  error.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go(Routes.home),
                icon: const Icon(Icons.home_rounded),
                label: const Text('홈으로 돌아가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
