import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/category.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_form.dart';

/// Todo 수정 페이지
///
/// 기존 할 일을 수정하는 화면입니다.
/// TodoForm 위젯을 재사용하여 기존 데이터를 미리 채웁니다.
///
/// AC-007: 할 일 제목 수정 기능
class TodoEditPage extends ConsumerStatefulWidget {
  const TodoEditPage({
    super.key,
    required this.todoId,
  });

  /// Todo ID
  final String todoId;

  @override
  ConsumerState<TodoEditPage> createState() => _TodoEditPageState();
}

class _TodoEditPageState extends ConsumerState<TodoEditPage> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Todo 데이터 조회
    final todo = ref.watch(todoProvider(widget.todoId));
    final todosAsync = ref.watch(todosStreamProvider);

    // TodoController 상태 감시 (에러 처리용)
    ref.listen<AsyncValue<void>>(
      todoControllerProvider,
      (_, state) {
        state.whenOrNull(
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('수정'),
        leading: IconButton(
          onPressed: () => _handleBack(context),
          icon: const Icon(Icons.close_rounded),
          tooltip: '닫기',
        ),
      ),
      body: SafeArea(
        child: todosAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  '데이터를 불러올 수 없습니다',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          data: (_) {
            if (todo == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '할 일을 찾을 수 없습니다',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Todo 데이터를 TodoFormData로 변환
            final initialData = TodoFormData(
              title: todo.title,
              description: todo.description,
              category: todo.category != null
                  ? TodoCategory.fromString(todo.category)
                  : null,
              dueDate: todo.dueDate,
              dueTime: todo.dueTime,
            );

            return TodoForm(
              initialData: initialData,
              isLoading: _isSubmitting,
              submitButtonText: '수정',
              onSubmit: (data) => _handleSubmit(context, data),
            );
          },
        ),
      ),
    );
  }

  /// 뒤로가기 처리
  void _handleBack(BuildContext context) {
    if (_isSubmitting) return;
    context.pop();
  }

  /// 폼 제출 처리
  Future<bool> _handleSubmit(BuildContext context, TodoFormData data) async {
    if (_isSubmitting) return false;

    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(todoControllerProvider.notifier);
      final success = await controller.updateTodo(
        todoId: widget.todoId,
        title: data.title,
        description: data.description,
        category: data.category?.value,
        dueDate: data.dueDate,
        dueTime: data.dueTime,
      );

      if (!mounted) return success;

      if (success) {
        // 성공 시 이전 화면으로 돌아가기
        this.context.pop();

        // 성공 스낵바 표시
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(
            content: Text('할 일이 수정되었습니다'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      return success;
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
