import 'package:flutter/material.dart';

/// 삭제 확인 다이얼로그
///
/// 할 일 삭제 시 사용자 확인을 위한 다이얼로그입니다.
/// - 삭제 버튼은 빨간색으로 강조
/// - 취소/삭제 두 가지 액션 제공
///
/// 사용 예:
/// ```dart
/// final confirmed = await DeleteConfirmationDialog.show(
///   context: context,
///   title: '할 일 삭제',
///   content: '이 할 일을 삭제하시겠습니까?',
/// );
/// if (confirmed) {
///   // 삭제 실행
/// }
/// ```
class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText = '취소',
    this.confirmText = '삭제',
  });

  /// 다이얼로그 제목
  final String title;

  /// 다이얼로그 내용
  final String content;

  /// 취소 버튼 텍스트
  final String cancelText;

  /// 확인 버튼 텍스트
  final String confirmText;

  /// 삭제 확인 다이얼로그를 표시하고 결과를 반환합니다.
  ///
  /// [context] BuildContext
  /// [title] 다이얼로그 제목
  /// [content] 다이얼로그 내용
  /// [cancelText] 취소 버튼 텍스트 (기본값: '취소')
  /// [confirmText] 확인 버튼 텍스트 (기본값: '삭제')
  ///
  /// Returns: 삭제 확인 시 true, 취소 시 false
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    String cancelText = '취소',
    String confirmText = '삭제',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteConfirmationDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: colorScheme.onErrorContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        content,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
