import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 초대 코드 입력 위젯
///
/// 파트너의 6자리 초대 코드를 입력받는 위젯입니다.
/// - 6자리 숫자/영문 대문자 입력
/// - 자동 대문자 변환
/// - 입력 완료 시 콜백 호출
class InviteCodeInput extends StatefulWidget {
  const InviteCodeInput({
    super.key,
    required this.onSubmit,
    this.enabled = true,
    this.errorMessage,
  });

  /// 코드 입력 완료 콜백
  final void Function(String code) onSubmit;

  /// 입력 활성화 여부
  final bool enabled;

  /// 에러 메시지 (유효하지 않은 코드 등)
  final String? errorMessage;

  @override
  State<InviteCodeInput> createState() => _InviteCodeInputState();
}

class _InviteCodeInputState extends State<InviteCodeInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final code = _controller.text.trim().toUpperCase();
    if (code.length == 6) {
      widget.onSubmit(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 안내 텍스트
        Text(
          '코드 입력',
          style: AppTextStyles.titleMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '파트너에게 받은 초대 코드를 입력하세요',
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // 코드 입력 필드
        _buildInputField(colorScheme),

        // 에러 메시지
        if (widget.errorMessage != null) ...[
          const SizedBox(height: 12),
          _buildErrorMessage(colorScheme),
        ],

        const SizedBox(height: 24),

        // 연결하기 버튼
        _buildSubmitButton(colorScheme),
      ],
    );
  }

  Widget _buildInputField(ColorScheme colorScheme) {
    return SizedBox(
      width: 240,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled,
        textAlign: TextAlign.center,
        maxLength: 6,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          UpperCaseTextFormatter(),
        ],
        style: AppTextStyles.headlineSmall.copyWith(
          color: colorScheme.onSurface,
          letterSpacing: 8,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: '------',
          hintStyle: AppTextStyles.headlineSmall.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            letterSpacing: 8,
          ),
          counterText: '',
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: widget.errorMessage != null
                  ? colorScheme.error
                  : colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: widget.errorMessage != null
                  ? colorScheme.error
                  : AppColors.primary,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
        ),
        onChanged: (_) {
          // 버튼 활성화 상태 및 에러 상태 갱신을 위해 항상 setState 호출
          setState(() {});
        },
        onSubmitted: (_) => _handleSubmit(),
      ),
    );
  }

  Widget _buildErrorMessage(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.onErrorContainer,
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              widget.errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ColorScheme colorScheme) {
    final isValid = _controller.text.length == 6;

    return FilledButton.icon(
      onPressed: widget.enabled && isValid ? _handleSubmit : null,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
      ),
      icon: const Icon(Icons.link_rounded, size: 20),
      label: Text(
        '연결하기',
        style: AppTextStyles.button.copyWith(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}

/// 입력을 대문자로 변환하는 TextInputFormatter
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
