import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 초대 코드 표시 위젯
///
/// 6자리 초대 코드를 시각적으로 표시하고 복사 기능을 제공합니다.
/// - 각 문자가 개별 박스에 표시됨
/// - 복사 버튼으로 클립보드에 복사
/// - 복사 완료 시 스낵바로 피드백 제공
class InviteCodeDisplay extends StatelessWidget {
  const InviteCodeDisplay({
    super.key,
    required this.inviteCode,
    this.onCopied,
  });

  /// 표시할 6자리 초대 코드
  final String inviteCode;

  /// 복사 완료 콜백
  final VoidCallback? onCopied;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 안내 텍스트
        Text(
          '초대 코드',
          style: AppTextStyles.titleMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '파트너에게 아래 코드를 공유하세요',
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // 코드 표시 박스들
        _buildCodeBoxes(colorScheme),
        const SizedBox(height: 24),

        // 복사 버튼
        _buildCopyButton(context, colorScheme),
      ],
    );
  }

  Widget _buildCodeBoxes(ColorScheme colorScheme) {
    final characters = inviteCode.split('');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: characters.asMap().entries.map((entry) {
        final index = entry.key;
        final char = entry.value;

        return Row(
          children: [
            Container(
              width: 48,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  char,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // 3자리 후 구분자 추가
            if (index == 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '-',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else if (index < 5)
              const SizedBox(width: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildCopyButton(BuildContext context, ColorScheme colorScheme) {
    return OutlinedButton.icon(
      onPressed: () => _copyToClipboard(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: const Icon(Icons.copy_rounded, size: 20),
      label: Text(
        '코드 복사',
        style: AppTextStyles.button.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '초대 코드가 복사되었습니다',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    onCopied?.call();
  }
}
