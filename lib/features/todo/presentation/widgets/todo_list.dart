import 'package:flutter/material.dart';

import '../../domain/entities/todo.dart';
import 'empty_todo_state.dart';
import 'todo_list_item.dart';

/// Todo 리스트 위젯
///
/// Todo 목록을 ListView로 표시합니다.
/// 빈 상태, 완료/미완료 구분 표시를 지원합니다.
class TodoList extends StatelessWidget {
  const TodoList({
    super.key,
    required this.todos,
    required this.currentUserId,
    required this.onToggleComplete,
    this.onTodoTap,
    this.onDelete,
    this.onCreateTodo,
    this.groupByCompletion = true,
  });

  /// Todo 목록
  final List<Todo> todos;

  /// 현재 로그인한 사용자 ID
  final String currentUserId;

  /// 완료 상태 토글 콜백
  final void Function(Todo todo) onToggleComplete;

  /// Todo 항목 탭 콜백
  final void Function(Todo todo)? onTodoTap;

  /// 삭제 콜백
  final void Function(Todo todo)? onDelete;

  /// 할 일 생성 콜백 (빈 상태에서 버튼 표시용)
  final VoidCallback? onCreateTodo;

  /// 완료/미완료로 그룹화 여부
  final bool groupByCompletion;

  @override
  Widget build(BuildContext context) {
    // 빈 상태
    if (todos.isEmpty) {
      return EmptyTodoState(onCreateTodo: onCreateTodo);
    }

    // 그룹화 하지 않으면 단순 리스트
    if (!groupByCompletion) {
      return _buildSimpleList();
    }

    // 완료/미완료로 그룹화
    return _buildGroupedList(context);
  }

  /// 단순 리스트 빌드
  Widget _buildSimpleList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return TodoListItem(
          todo: todo,
          currentUserId: currentUserId,
          onToggleComplete: () => onToggleComplete(todo),
          onTap: onTodoTap != null ? () => onTodoTap!(todo) : null,
          onDelete: onDelete != null ? () => onDelete!(todo) : null,
        );
      },
    );
  }

  /// 완료/미완료로 그룹화된 리스트 빌드
  Widget _buildGroupedList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 미완료/완료 분리
    final incompleteTodos = todos.where((t) => !t.isCompleted).toList();
    final completedTodos = todos.where((t) => t.isCompleted).toList();

    return CustomScrollView(
      slivers: [
        // 미완료 섹션
        if (incompleteTodos.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.pending_actions_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '미완료',
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
                      '${incompleteTodos.length}',
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '완료',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.outline,
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
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${completedTodos.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
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
}
