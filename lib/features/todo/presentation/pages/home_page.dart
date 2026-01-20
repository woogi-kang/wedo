import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/todo.dart';
import '../providers/todo_provider.dart';
import '../providers/view_mode_provider.dart';
import '../widgets/daily_view.dart';
import '../widgets/monthly_view.dart';
import '../widgets/view_mode_selector.dart';
import '../widgets/weekly_view.dart';

/// 홈 화면 (Todo 목록)
///
/// 모든 사용자의 할 일 목록을 표시하는 메인 화면입니다.
/// - AppBar: 앱 타이틀과 설정 아이콘
/// - 보기 모드 선택: 일간 | 주간 | 월간
/// - Todo 리스트: 선택된 보기 모드에 따라 표시
/// - FAB: 새 할 일 추가
/// - Pull-to-refresh 지원
///
/// AC-006: 완료 상태 토글
/// AC-021: 할 일이 없을 때 빈 상태 표시
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 현재 사용자 정보
    final currentUser = ref.watch(currentUserProvider);
    final currentUserId = currentUser?.uid ?? '';

    // Todo 스트림
    final todosAsync = ref.watch(todosStreamProvider);

    // 보기 모드 상태
    final viewModeState = ref.watch(viewModeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.favorite_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'WeDo',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(Routes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: '설정',
          ),
        ],
      ),
      body: Column(
        children: [
          // 보기 모드 선택기
          const ViewModeSelector(),

          const Divider(height: 1),

          // 콘텐츠 영역
          Expanded(
            child: todosAsync.when(
              data: (todos) => _buildViewModeContent(
                context,
                ref,
                todos,
                currentUserId,
                viewModeState.mode,
              ),
              loading: () => const LoadingIndicator(
                message: '할 일을 불러오는 중...',
              ),
              error: (error, _) => _buildErrorState(context, ref, error),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateTodo(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('새 할 일'),
      ),
    );
  }

  /// 보기 모드에 따른 콘텐츠 빌드
  Widget _buildViewModeContent(
    BuildContext context,
    WidgetRef ref,
    List<Todo> todos,
    String currentUserId,
    ViewMode viewMode,
  ) {
    // 공통 콜백
    void onToggleComplete(Todo todo) => _toggleTodoComplete(ref, todo);
    void onTodoTap(Todo todo) => _navigateToTodoDetail(context, todo);
    void onDelete(Todo todo) => _deleteTodo(context, ref, todo);
    void onCreateTodo() => _navigateToCreateTodo(context);

    // RefreshIndicator로 감싸서 새로고침 지원
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(todosStreamProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: switch (viewMode) {
        ViewMode.daily => DailyView(
            currentUserId: currentUserId,
            onToggleComplete: onToggleComplete,
            onTodoTap: onTodoTap,
            onDelete: onDelete,
            onCreateTodo: onCreateTodo,
          ),
        ViewMode.weekly => WeeklyView(
            currentUserId: currentUserId,
            onToggleComplete: onToggleComplete,
            onTodoTap: onTodoTap,
            onDelete: onDelete,
            onCreateTodo: onCreateTodo,
          ),
        ViewMode.monthly => MonthlyView(
            currentUserId: currentUserId,
            onToggleComplete: onToggleComplete,
            onTodoTap: onTodoTap,
            onDelete: onDelete,
            onCreateTodo: onCreateTodo,
          ),
      },
    );
  }

  /// 에러 상태 빌드
  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
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
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '오류가 발생했습니다',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.invalidate(todosStreamProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// Todo 완료 상태 토글
  Future<void> _toggleTodoComplete(WidgetRef ref, Todo todo) async {
    final controller = ref.read(todoControllerProvider.notifier);
    await controller.toggleComplete(
      todoId: todo.id,
      isCompleted: todo.isCompleted,
    );
  }

  /// Todo 상세 화면으로 이동
  void _navigateToTodoDetail(BuildContext context, Todo todo) {
    context.push(Routes.todoDetailPath(todo.id));
  }

  /// Todo 생성 화면으로 이동
  void _navigateToCreateTodo(BuildContext context) {
    context.push(Routes.todoCreate);
  }

  /// Todo 삭제
  Future<void> _deleteTodo(
    BuildContext context,
    WidgetRef ref,
    Todo todo,
  ) async {
    final controller = ref.read(todoControllerProvider.notifier);
    final success = await controller.deleteTodo(todoId: todo.id);

    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('할 일이 삭제되었습니다'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: '확인',
            onPressed: () {},
          ),
        ),
      );
    }
  }
}
