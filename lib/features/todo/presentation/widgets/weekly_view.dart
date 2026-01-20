import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/todo.dart';
import '../providers/view_mode_provider.dart';
import 'todo_list_item.dart';

/// 주간 보기 위젯
///
/// 해당 주의 투두를 요일별로 그룹화하여 표시합니다.
class WeeklyView extends ConsumerWidget {
  const WeeklyView({
    super.key,
    required this.currentUserId,
    required this.onToggleComplete,
    this.onTodoTap,
    this.onDelete,
    this.onCreateTodo,
  });

  /// 현재 로그인한 사용자 ID
  final String currentUserId;

  /// 완료 상태 토글 콜백
  final void Function(Todo todo) onToggleComplete;

  /// Todo 항목 탭 콜백
  final void Function(Todo todo)? onTodoTap;

  /// 삭제 콜백
  final void Function(Todo todo)? onDelete;

  /// 할 일 생성 콜백
  final VoidCallback? onCreateTodo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyTodos = ref.watch(weeklyTodosProvider);
    final viewModeState = ref.watch(viewModeNotifierProvider);
    final notifier = ref.read(viewModeNotifierProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 주간 날짜 목록 생성
    final weekStart = notifier.getWeekStart(viewModeState.selectedDate);
    final weekDays = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );

    // 전체 투두 개수 계산
    final totalTodos = weeklyTodos.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );

    if (totalTodos == 0) {
      return _buildEmptyState(context);
    }

    return CustomScrollView(
      slivers: [
        // 주간 요약 헤더
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.view_week_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '이번 주 할 일',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalTodos',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 요일별 섹션
        ...weekDays.expand((day) {
          final todosForDay = weeklyTodos[day] ?? [];
          final isToday = _isToday(day);

          return [
            SliverToBoxAdapter(
              child: _buildDayHeader(context, day, todosForDay.length, isToday),
            ),
            if (todosForDay.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final todo = todosForDay[index];
                    return TodoListItem(
                      todo: todo,
                      currentUserId: currentUserId,
                      onToggleComplete: () => onToggleComplete(todo),
                      onTap: onTodoTap != null ? () => onTodoTap!(todo) : null,
                      onDelete: onDelete != null ? () => onDelete!(todo) : null,
                    );
                  },
                  childCount: todosForDay.length,
                ),
              ),
          ];
        }),

        // 하단 여백 (FAB가 가리지 않도록)
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  /// 요일 헤더 빌드
  Widget _buildDayHeader(
    BuildContext context,
    DateTime day,
    int todoCount,
    bool isToday,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('E', 'ko_KR');
    final dayFormat = DateFormat('M/d', 'ko_KR');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isToday
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          // 요일 표시
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isToday ? colorScheme.primary : colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                dateFormat.format(day),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isToday
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 날짜
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      dayFormat.format(day),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '오늘',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (todoCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$todoCount개의 할 일',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 2),
                  Text(
                    '할 일 없음',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 오늘인지 확인
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 빈 상태 빌드
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.view_week_rounded,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '이번 주 할 일이 없습니다',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '새 할 일을 추가하거나\n다른 주를 선택해보세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onCreateTodo != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onCreateTodo,
                icon: const Icon(Icons.add_rounded),
                label: const Text('할 일 추가'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
