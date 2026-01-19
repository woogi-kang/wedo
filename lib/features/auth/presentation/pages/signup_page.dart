import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_form_field.dart';

/// 회원가입 페이지
///
/// 이메일, 비밀번호, 이름으로 새 계정을 만드는 화면입니다.
/// - 이름 입력 필드
/// - 이메일 입력 필드
/// - 비밀번호 입력 필드
/// - 회원가입 버튼
/// - 로그인 페이지 링크
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).signUp(
          displayName: _displayNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _navigateToLogin() {
    context.go(Routes.login);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: colorScheme.onSurface,
          ),
          onPressed: _navigateToLogin,
        ),
      ),
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
                    const SizedBox(height: 40),

                    // 에러 메시지
                    if (authState is AuthError) ...[
                      _buildErrorMessage(authState.message, colorScheme),
                      const SizedBox(height: 16),
                    ],

                    // 이름 입력
                    DisplayNameFormField(
                      controller: _displayNameController,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),

                    // 이메일 입력
                    EmailFormField(
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // 비밀번호 입력
                    PasswordFormField(
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      validateStrength: true,
                      onFieldSubmitted: (_) => _handleSignup(),
                    ),
                    const SizedBox(height: 24),

                    // 회원가입 버튼
                    _buildSignupButton(isLoading, colorScheme),
                    const SizedBox(height: 16),

                    // 로그인 링크
                    _buildLoginLink(colorScheme),
                    const SizedBox(height: 24),

                    // 약관 안내
                    _buildTermsNotice(colorScheme),
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
        // 타이틀
        Text(
          '회원가입',
          style: AppTextStyles.headlineLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '새 계정을 만들어 시작하세요',
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

  Widget _buildSignupButton(bool isLoading, ColorScheme colorScheme) {
    return FilledButton(
      onPressed: isLoading ? null : _handleSignup,
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
              '회원가입',
              style: AppTextStyles.button.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
    );
  }

  Widget _buildLoginLink(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '이미 계정이 있으신가요? ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: _navigateToLogin,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            '로그인',
            style: AppTextStyles.button.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsNotice(ColorScheme colorScheme) {
    return Text(
      '회원가입 시 서비스 이용약관 및 개인정보처리방침에 동의하게 됩니다.',
      style: AppTextStyles.caption.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      ),
      textAlign: TextAlign.center,
    );
  }
}
