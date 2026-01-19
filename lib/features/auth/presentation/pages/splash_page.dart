import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';

/// 스플래시 페이지
///
/// 앱 시작 시 표시되는 초기 화면입니다.
/// - 앱 로고와 이름을 표시합니다
/// - Firebase Auth 인증 상태를 확인합니다
/// - 인증 상태에 따라 적절한 화면으로 자동 이동합니다
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthState();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();
  }

  void _checkAuthState() {
    // 최소 스플래시 표시 시간 후 인증 상태 확인
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;

      final authState = ref.read(authStateChangesProvider);
      authState.when(
        data: (user) {
          if (user != null) {
            // 인증됨 - 홈으로 이동
            context.go(Routes.home);
          } else {
            // 미인증 - 로그인으로 이동
            context.go(Routes.login);
          }
        },
        loading: () {
          // 아직 로딩 중이면 조금 더 대기
          _waitForAuthState();
        },
        error: (_, __) {
          // 에러 발생 시 로그인으로 이동
          context.go(Routes.login);
        },
      );
    });
  }

  void _waitForAuthState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final authState = ref.read(authStateChangesProvider);
      if (authState.isLoading) {
        _waitForAuthState();
      } else {
        authState.whenData((user) {
          if (user != null) {
            context.go(Routes.home);
          } else {
            context.go(Routes.login);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고
              _buildLogo(colorScheme),
              const SizedBox(height: 24),

              // 앱 이름
              Text(
                'WeDo',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // 앱 슬로건
              Text(
                '함께하는 우리의 할 일',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),

              // 로딩 인디케이터
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ColorScheme colorScheme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.favorite_rounded,
        size: 60,
        color: Colors.white,
      ),
    );
  }
}
