import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../couple/presentation/providers/couple_provider.dart';
import '../../domain/entities/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_list.dart';

/// 홈 화면 (Todo 목록)
///
/// 커플의 할 일 목록을 표시하는 메인 화면입니다.
/// - AppBar: 앱 타이틀과 설정 아이콘
/// - Todo 리스트: 완료/미완료 그룹화
/// - FAB: 새 할 일 추가
/// - Pull-to-refresh 지원
///
/// AC-006: 완료 상태 토글
/// AC-012: 파트너의 할 일 실시간 표시
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

    // 커플 상태
    final coupleState = ref.watch(currentCoupleStateProvider);
    final partnerName = coupleState.maybeWhen(
      connected: (couple) {
        // TODO: 파트너 이름을 가져오는 로직 필요
        // 현재는 null 반환하여 "파트너"로 표시
        return null;
      },
      orElse: () => null,
    );

    // Todo 스트림
    final todosAsync = ref.watch(todosStreamProvider);

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
      body: todosAsync.when(
        data: (todos) => _buildTodoList(
          context,
          ref,
          todos,
          currentUserId,
          partnerName,
        ),
        loading: () => const LoadingIndicator(
          message: '할 일을 불러오는 중...',
        ),
        error: (error, _) => _buildErrorState(context, ref, error),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateTodo(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('새 할 일'),
      ),
    );
  }

  /// Todo 리스트 빌드
  Widget _buildTodoList(
    BuildContext context,
    WidgetRef ref,
    List<Todo> todos,
    String currentUserId,
    String? partnerName,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        // Provider를 새로고침하여 데이터 리로드
        ref.invalidate(todosStreamProvider);
        // StreamProvider가 새 데이터를 가져올 때까지 잠시 대기
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: TodoList(
        todos: todos,
        currentUserId: currentUserId,
        partnerName: partnerName,
        onToggleComplete: (todo) => _toggleTodoComplete(ref, todo),
        onTodoTap: (todo) => _navigateToTodoDetail(context, todo),
        onDelete: (todo) => _deleteTodo(context, ref, todo),
        onCreateTodo: () => _navigateToCreateTodo(context),
      ),
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
