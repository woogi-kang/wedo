import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/todo_provider.dart';
import '../widgets/todo_form.dart';

/// Todo 생성 페이지
///
/// 새로운 할 일을 생성하는 화면입니다.
/// - 제목 입력 (필수)
/// - 설명 입력 (선택)
/// - 카테고리 선택 (칩 형태)
/// - 마감일/시간 선택
///
/// AC-005: 모든 필드로 Todo 생성 가능
/// AC-005: 빈 제목 시 에러 표시
class TodoCreatePage extends ConsumerStatefulWidget {
  const TodoCreatePage({super.key});

  @override
  ConsumerState<TodoCreatePage> createState() => _TodoCreatePageState();
}

class _TodoCreatePageState extends ConsumerState<TodoCreatePage> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // TodoController 상태 감시 (에러 처리용)
    ref.listen<AsyncValue<void>>(
      todoControllerProvider,
      (_, state) {
        state.whenOrNull(
          error: (error, _) {
            // 에러 스낵바 표시
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
        title: const Text('새 할 일'),
        leading: IconButton(
          onPressed: () => _handleBack(context),
          icon: const Icon(Icons.close_rounded),
          tooltip: '닫기',
        ),
      ),
      body: SafeArea(
        child: TodoForm(
          isLoading: _isSubmitting,
          submitButtonText: '저장',
          onSubmit: (data) => _handleSubmit(context, data),
        ),
      ),
    );
  }

  /// 뒤로가기 처리
  void _handleBack(BuildContext context) {
    if (_isSubmitting) return;

    // 폼에 입력된 내용이 있으면 확인 다이얼로그 표시
    // (간단한 구현을 위해 바로 뒤로가기)
    context.pop();
  }

  /// 폼 제출 처리
  Future<bool> _handleSubmit(BuildContext context, TodoFormData data) async {
    if (_isSubmitting) return false;

    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(todoControllerProvider.notifier);
      final success = await controller.createTodo(
        title: data.title,
        description: data.description,
        category: data.category?.value,
        dueDate: data.dueDate,
        dueTime: data.dueTime,
      );

      if (!mounted) return success;

      if (success) {
        // 성공 시 홈으로 돌아가기
        this.context.pop();

        // 성공 스낵바 표시
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(
            content: Text('할 일이 추가되었습니다'),
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
