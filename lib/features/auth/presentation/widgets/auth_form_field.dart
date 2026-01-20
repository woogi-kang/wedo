import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 인증 화면용 재사용 가능한 텍스트 필드
///
/// 이메일, 비밀번호, 이름 등 인증 관련 입력에 최적화된 스타일을 제공합니다.
/// AppColors를 사용하여 앱 테마와 일관된 디자인을 유지합니다.
class AuthFormField extends StatefulWidget {
  const AuthFormField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.autofillHints,
    this.enabled = true,
    this.maxLines = 1,
    this.autofocus = false,
  });

  /// 텍스트 컨트롤러
  final TextEditingController controller;

  /// 필드 라벨 (한글)
  final String label;

  /// 힌트 텍스트
  final String? hint;

  /// 키보드 타입
  final TextInputType keyboardType;

  /// 비밀번호 등 텍스트 숨김 여부
  final bool obscureText;

  /// 유효성 검사 함수
  final String? Function(String?)? validator;

  /// 값 변경 콜백
  final ValueChanged<String>? onChanged;

  /// 제출 콜백
  final ValueChanged<String>? onFieldSubmitted;

  /// 키보드 액션 버튼 타입
  final TextInputAction textInputAction;

  /// 접두 아이콘
  final IconData? prefixIcon;

  /// 자동 완성 힌트
  final Iterable<String>? autofillHints;

  /// 활성화 여부
  final bool enabled;

  /// 최대 줄 수
  final int maxLines;

  /// 자동 포커스 여부
  final bool autofocus;

  @override
  State<AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      autofocus: widget.autofocus,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: colorScheme.onSurfaceVariant,
              )
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
        ),
      ),
    );
  }
}

/// 이메일 입력 필드
///
/// AuthFormField를 이메일 입력에 최적화하여 래핑한 편의 위젯입니다.
class EmailFormField extends StatelessWidget {
  const EmailFormField({
    super.key,
    required this.controller,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction textInputAction;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return AuthFormField(
      controller: controller,
      label: '이메일',
      hint: 'example@email.com',
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
      autofillHints: const [AutofillHints.email],
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      autofocus: autofocus,
      validator: _validateEmail,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '올바른 이메일 형식이 아닙니다.';
    }
    return null;
  }
}

/// 비밀번호 입력 필드
///
/// AuthFormField를 비밀번호 입력에 최적화하여 래핑한 편의 위젯입니다.
class PasswordFormField extends StatelessWidget {
  const PasswordFormField({
    super.key,
    required this.controller,
    this.label = '비밀번호',
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
    this.validateStrength = true,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction textInputAction;
  final bool enabled;

  /// 비밀번호 강도 검사 여부 (회원가입 시 true, 로그인 시 false)
  final bool validateStrength;

  @override
  Widget build(BuildContext context) {
    return AuthFormField(
      controller: controller,
      label: label,
      hint: validateStrength ? '12자 이상, 대소문자/숫자/특수문자 중 3종류 포함' : null,
      obscureText: true,
      prefixIcon: Icons.lock_outlined,
      autofillHints: validateStrength
          ? const [AutofillHints.newPassword]
          : const [AutofillHints.password],
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      validator: validateStrength ? _validatePasswordStrength : _validatePasswordRequired,
    );
  }

  String? _validatePasswordRequired(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    return null;
  }

  String? _validatePasswordStrength(String? value) {
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }
    // NIST SP 800-63B 권장사항: 최소 12자 이상
    if (value.length < 12) {
      return '비밀번호는 12자 이상이어야 합니다.';
    }
    // 복잡성 요구사항: 대문자, 소문자, 숫자, 특수문자 중 3가지 이상
    int complexity = 0;
    if (RegExp(r'[A-Z]').hasMatch(value)) complexity++;
    if (RegExp(r'[a-z]').hasMatch(value)) complexity++;
    if (RegExp(r'[0-9]').hasMatch(value)) complexity++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) complexity++;

    if (complexity < 3) {
      return '대문자, 소문자, 숫자, 특수문자 중 3가지 이상 포함해주세요.';
    }
    return null;
  }
}

/// 이름 입력 필드
///
/// AuthFormField를 이름 입력에 최적화하여 래핑한 편의 위젯입니다.
class DisplayNameFormField extends StatelessWidget {
  const DisplayNameFormField({
    super.key,
    required this.controller,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction textInputAction;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return AuthFormField(
      controller: controller,
      label: '이름',
      hint: '표시될 이름을 입력해주세요',
      keyboardType: TextInputType.name,
      prefixIcon: Icons.person_outlined,
      autofillHints: const [AutofillHints.name],
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      autofocus: autofocus,
      validator: _validateDisplayName,
    );
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return '이름을 입력해주세요.';
    }
    if (value.length < 2) {
      return '이름은 2자 이상이어야 합니다.';
    }
    if (value.length > 20) {
      return '이름은 20자 이하여야 합니다.';
    }
    return null;
  }
}
