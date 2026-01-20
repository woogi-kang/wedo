import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/todo.dart';

/// Todo 리스트 아이템 위젯
///
/// 단일 Todo 항목을 카드 형태로 표시합니다.
/// - 체크박스로 완료 상태 토글
/// - 제목 및 카테고리 배지
/// - 마감 일시 표시
/// - 생성자 이름 표시
class TodoListItem extends StatelessWidget {
  const TodoListItem({
    super.key,
    required this.todo,
    required this.currentUserId,
    required this.onToggleComplete,
    this.onTap,
    this.onDelete,
  });

  /// Todo 데이터
  final Todo todo;

  /// 현재 로그인한 사용자 ID
  final String currentUserId;

  /// 완료 상태 토글 콜백
  final VoidCallback onToggleComplete;

  /// 항목 탭 콜백
  final VoidCallback? onTap;

  /// 삭제 콜백 (스와이프 삭제용)
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 생성자가 나인지 확인
    final isCreatedByMe = todo.isCreatedBy(currentUserId);
    final creatorLabel = isCreatedByMe ? '나' : todo.creatorName;
    final creatorColor = isCreatedByMe ? AppColors.partner1 : AppColors.partner2;

    // 카테고리
    final category = todo.category != null
        ? TodoCategory.fromString(todo.category)
        : null;

    Widget card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: todo.isCompleted
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 체크박스
              Checkbox(
                value: todo.isCompleted,
                onChanged: (_) => onToggleComplete(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // 컨텐츠
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 행
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            todo.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: todo.isCompleted
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,
                              decoration: todo.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 메타 정보 행
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        // 생성자 배지
                        _Badge(
                          icon: Icons.person_outline_rounded,
                          label: creatorLabel,
                          backgroundColor: creatorColor.withValues(alpha: 0.2),
                          textColor: creatorColor,
                        ),

                        // 카테고리 배지
                        if (category != null)
                          _Badge(
                            icon: _getCategoryIcon(category),
                            label: category.displayName,
                            backgroundColor:
                                colorScheme.secondaryContainer.withValues(alpha: 0.5),
                            textColor: colorScheme.onSecondaryContainer,
                          ),

                        // 마감일 배지
                        if (todo.hasDueDate)
                          _Badge(
                            icon: Icons.schedule_rounded,
                            label: _formatDueDate(todo),
                            backgroundColor: todo.isOverdue
                                ? colorScheme.errorContainer
                                : colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                            textColor: todo.isOverdue
                                ? colorScheme.onErrorContainer
                                : colorScheme.onTertiaryContainer,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 스와이프 삭제 지원
    if (onDelete != null) {
      return Dismissible(
        key: Key(todo.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete!(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            color: colorScheme.onErrorContainer,
          ),
        ),
        confirmDismiss: (_) async {
          return await _showDeleteConfirmDialog(context);
        },
        child: card,
      );
    }

    return card;
  }

  /// 카테고리에 맞는 아이콘 반환
  IconData _getCategoryIcon(TodoCategory category) {
    return switch (category) {
      TodoCategory.housework => Icons.home_outlined,
      TodoCategory.shopping => Icons.shopping_bag_outlined,
      TodoCategory.appointment => Icons.event_outlined,
      TodoCategory.anniversary => Icons.favorite_outline_rounded,
      TodoCategory.exercise => Icons.fitness_center_outlined,
      TodoCategory.other => Icons.label_outline_rounded,
    };
  }

  /// 마감일 포맷팅
  String _formatDueDate(Todo todo) {
    final now = DateTime.now();
    final date = todo.dueDate!;

    String dateStr;
    if (todo.isDueToday) {
      dateStr = '오늘';
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1) {
      dateStr = '내일';
    } else if (date.year == now.year) {
      dateStr = '${date.month}/${date.day}';
    } else {
      dateStr = '${date.year}/${date.month}/${date.day}';
    }

    if (todo.hasDueTime) {
      return '$dateStr ${todo.dueTime}';
    }
    return dateStr;
  }

  /// 삭제 확인 다이얼로그
  Future<bool> _showDeleteConfirmDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('할 일 삭제'),
            content: const Text('이 할 일을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('삭제'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

/// 메타 정보 배지 위젯
class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
