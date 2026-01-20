import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';

/// 스플래시 페이지
///
/// 앱 시작 시 표시되는 초기 화면입니다.
/// - 앱 로고와 이름을 표시합니다
/// - 자동으로 Anonymous 로그인을 시도합니다
/// - 네비게이션은 GoRouter redirect에서 처리합니다
///
/// 새로운 흐름:
/// 1. 애니메이션 표시
/// 2. Firebase Auth 상태 확인
/// 3. 미로그인 시 자동 Anonymous 로그인
/// 4. Router redirect가 다음 화면으로 이동
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
  bool _hasTriedAutoSignIn = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _tryAutoSignIn();
  }

  /// 자동 Anonymous 로그인 시도
  Future<void> _tryAutoSignIn() async {
    if (_hasTriedAutoSignIn) return;
    _hasTriedAutoSignIn = true;

    // 애니메이션이 어느 정도 진행된 후 로그인 시도
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // 이미 로그인되어 있는지 확인
    final authAsync = ref.read(authStateChangesProvider);
    final isLoggedIn = authAsync.valueOrNull != null;

    if (!isLoggedIn) {
      // Anonymous 로그인 시도
      await ref.read(authControllerProvider.notifier).signInAnonymously();
    }
    // Router redirect가 다음 화면으로 이동시킴
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
