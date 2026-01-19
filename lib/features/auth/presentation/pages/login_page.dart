import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_form_field.dart';

/// 로그인 페이지
///
/// 이메일과 비밀번호로 로그인하는 화면입니다.
/// - 이메일/비밀번호 입력 폼
/// - 로그인 버튼
/// - 회원가입 페이지 링크
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _navigateToSignup() {
    context.go(Routes.signup);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = authState is AuthLoading;

    // 인증 성공 시 홈으로 이동
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        context.go(Routes.home);
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 헤더
                    _buildHeader(colorScheme),
                    const SizedBox(height: 48),

                    // 에러 메시지
                    if (authState is AuthError) ...[
                      _buildErrorMessage(authState.message, colorScheme),
                      const SizedBox(height: 16),
                    ],

                    // 이메일 입력
                    EmailFormField(
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),

                    // 비밀번호 입력
                    PasswordFormField(
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      validateStrength: false,
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),
                    const SizedBox(height: 24),

                    // 로그인 버튼
                    _buildLoginButton(isLoading, colorScheme),
                    const SizedBox(height: 16),

                    // 회원가입 링크
                    _buildSignupLink(colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      children: [
        // 로고
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),

        // 타이틀
        Text(
          '로그인',
          style: AppTextStyles.headlineLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '계정에 로그인하세요',
          style: AppTextStyles.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String message, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onErrorContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading, ColorScheme colorScheme) {
    return FilledButton(
      onPressed: isLoading ? null : _handleLogin,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Text(
              '로그인',
              style: AppTextStyles.button.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
    );
  }

  Widget _buildSignupLink(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '계정이 없으신가요? ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: _navigateToSignup,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            '회원가입',
            style: AppTextStyles.button.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
