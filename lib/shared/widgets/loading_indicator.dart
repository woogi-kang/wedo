import 'package:flutter/material.dart';

/// 중앙 정렬 로딩 인디케이터 위젯
///
/// 페이지 전체 또는 컨테이너에서 로딩 상태를 표시할 때 사용합니다.
/// Material Design 3의 CircularProgressIndicator를 사용합니다.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = 36.0,
    this.strokeWidth = 4.0,
    this.color,
    this.message,
  });

  /// 인디케이터 크기
  final double size;

  /// 선 두께
  final double strokeWidth;

  /// 커스텀 색상 (null이면 테마 primary 사용)
  final Color? color;

  /// 로딩 메시지 (선택)
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              color: color ?? colorScheme.primary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
