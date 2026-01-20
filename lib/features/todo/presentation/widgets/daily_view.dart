import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/todo.dart';
import '../providers/view_mode_provider.dart';
import 'todo_list_item.dart';

/// 일간 보기 위젯
///
/// 선택된 날짜의 투두만 표시합니다.
/// 완료/미완료로 그룹화하여 표시합니다.
class DailyView extends ConsumerWidget {
  const DailyView({
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
    final todos = ref.watch(dailyTodosProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 빈 상태
    if (todos.isEmpty) {
      return _buildEmptyState(context);
    }

    // 미완료/완료 분리
    final incompleteTodos = todos.where((t) => !t.isCompleted).toList();
    final completedTodos = todos.where((t) => t.isCompleted).toList();

    return CustomScrollView(
      slivers: [
        // 미완료 섹션
        if (incompleteTodos.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              icon: Icons.pending_actions_rounded,
              title: '미완료',
              count: incompleteTodos.length,
              color: colorScheme.primary,
              containerColor: colorScheme.primaryContainer,
              onContainerColor: colorScheme.onPrimaryContainer,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final todo = incompleteTodos[index];
                return TodoListItem(
                  todo: todo,
                  currentUserId: currentUserId,
                  onToggleComplete: () => onToggleComplete(todo),
                  onTap: onTodoTap != null ? () => onTodoTap!(todo) : null,
                  onDelete: onDelete != null ? () => onDelete!(todo) : null,
                );
              },
              childCount: incompleteTodos.length,
            ),
          ),
        ],

        // 완료 섹션
        if (completedTodos.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              context,
              icon: Icons.check_circle_outline_rounded,
              title: '완료',
              count: completedTodos.length,
              color: colorScheme.outline,
              containerColor: colorScheme.surfaceContainerHighest,
              onContainerColor: colorScheme.onSurfaceVariant,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final todo = completedTodos[index];
                return TodoListItem(
                  todo: todo,
                  currentUserId: currentUserId,
                  onToggleComplete: () => onToggleComplete(todo),
                  onTap: onTodoTap != null ? () => onTodoTap!(todo) : null,
                  onDelete: onDelete != null ? () => onDelete!(todo) : null,
                );
              },
              childCount: completedTodos.length,
            ),
          ),
        ],

        // 하단 여백 (FAB가 가리지 않도록)
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  /// 섹션 헤더 빌드
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    required Color containerColor,
    required Color onContainerColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: onContainerColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
                Icons.event_available_rounded,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '이 날의 할 일이 없습니다',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '새 할 일을 추가하거나\n다른 날짜를 선택해보세요',
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
