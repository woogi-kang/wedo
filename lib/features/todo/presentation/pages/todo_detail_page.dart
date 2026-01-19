import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/todo.dart';
import '../providers/todo_provider.dart';
import '../widgets/delete_confirmation_dialog.dart';

/// Todo 상세 보기 페이지
///
/// 할 일의 상세 정보를 읽기 전용으로 표시합니다.
/// - 제목, 설명, 카테고리, 마감일/시간
/// - 완료 상태 및 완료자 정보
/// - 생성자 정보
/// - 수정/삭제 버튼
///
/// AC-007: 할 일 수정 기능
/// AC-008: 삭제 시 확인 다이얼로그
class TodoDetailPage extends ConsumerWidget {
  const TodoDetailPage({
    super.key,
    required this.todoId,
  });

  /// Todo ID
  final String todoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Todo 데이터 조회
    final todo = ref.watch(todoProvider(todoId));
    final currentUserId = ref.watch(currentUserProvider)?.uid;

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

    // 로딩 상태 확인
    final todosAsync = ref.watch(todosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('상세 보기'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: '뒤로',
        ),
        actions: [
          if (todo != null) ...[
            // 수정 버튼
            IconButton(
              onPressed: () => _navigateToEdit(context),
              icon: const Icon(Icons.edit_outlined),
              tooltip: '수정',
            ),
            // 삭제 버튼
            IconButton(
              onPressed: () => _handleDelete(context, ref),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: colorScheme.error,
              ),
              tooltip: '삭제',
            ),
          ],
        ],
      ),
      body: todosAsync.when(
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

          return _buildContent(
            context,
            ref,
            theme,
            colorScheme,
            todo,
            currentUserId ?? '',
          );
        },
      ),
    );
  }

  /// 상세 내용 빌드
  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
    Todo todo,
    String currentUserId,
  ) {
    final isCreatedByMe = todo.isCreatedBy(currentUserId);
    final category = todo.category != null
        ? TodoCategory.fromString(todo.category)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 완료 배지
          if (todo.isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '완료됨',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 제목
          Text(
            todo.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),

          const SizedBox(height: 24),

          // 설명
          if (todo.description != null && todo.description!.isNotEmpty) ...[
            _buildSection(
              theme: theme,
              colorScheme: colorScheme,
              icon: Icons.description_outlined,
              title: '설명',
              child: Text(
                todo.description!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 카테고리
          if (category != null) ...[
            _buildSection(
              theme: theme,
              colorScheme: colorScheme,
              icon: _getCategoryIcon(category),
              title: '카테고리',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category.displayName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // 마감일/시간
          if (todo.hasDueDate) ...[
            _buildSection(
              theme: theme,
              colorScheme: colorScheme,
              icon: Icons.event_outlined,
              title: '마감일',
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: todo.isOverdue
                          ? colorScheme.errorContainer
                          : colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDate(todo.dueDate!),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: todo.isOverdue
                            ? colorScheme.onErrorContainer
                            : colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (todo.hasDueTime) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            todo.dueTime!,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (todo.isOverdue) ...[
                    const SizedBox(width: 8),
                    Text(
                      '기한 초과',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          const Divider(),
          const SizedBox(height: 16),

          // 생성자 정보
          _buildInfoRow(
            theme: theme,
            colorScheme: colorScheme,
            icon: Icons.person_outline_rounded,
            label: '만든 사람',
            value: isCreatedByMe ? '내가 만듦' : '파트너가 만듦',
            valueColor: isCreatedByMe ? AppColors.partner1 : AppColors.partner2,
          ),

          const SizedBox(height: 12),

          // 완료자 정보
          if (todo.isCompleted && todo.completedBy != null)
            _buildInfoRow(
              theme: theme,
              colorScheme: colorScheme,
              icon: Icons.check_circle_outline_rounded,
              label: '완료한 사람',
              value: todo.completedBy == currentUserId ? '내가 완료' : '파트너가 완료',
              valueColor: todo.completedBy == currentUserId
                  ? AppColors.partner1
                  : AppColors.partner2,
            ),

          const SizedBox(height: 12),

          // 생성일
          _buildInfoRow(
            theme: theme,
            colorScheme: colorScheme,
            icon: Icons.calendar_today_outlined,
            label: '생성일',
            value: _formatDateTime(todo.createdAt),
            valueColor: colorScheme.onSurfaceVariant,
          ),

          const SizedBox(height: 32),

          // 완료/미완료 토글 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () => _handleToggleComplete(context, ref, todo),
              style: FilledButton.styleFrom(
                backgroundColor:
                    todo.isCompleted ? colorScheme.outline : AppColors.primary,
                foregroundColor:
                    todo.isCompleted ? colorScheme.onInverseSurface : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(
                todo.isCompleted
                    ? Icons.undo_rounded
                    : Icons.check_circle_outline_rounded,
              ),
              label: Text(
                todo.isCompleted ? '미완료로 변경' : '완료로 표시',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      todo.isCompleted ? colorScheme.onInverseSurface : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 빌드
  Widget _buildSection({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  /// 정보 행 빌드
  Widget _buildInfoRow({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 카테고리 아이콘
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

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return '오늘';
    }
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day + 1) {
      return '내일';
    }
    if (date.year == now.year) {
      return '${date.month}월 ${date.day}일';
    }
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 날짜/시간 포맷팅
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 수정 페이지로 이동
  void _navigateToEdit(BuildContext context) {
    context.push('${Routes.todoDetailPath(todoId)}/edit');
  }

  /// 삭제 처리
  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await DeleteConfirmationDialog.show(
      context: context,
      title: '할 일 삭제',
      content: '정말 삭제하시겠습니까?\n삭제된 할 일은 복구할 수 없습니다.',
    );

    if (!confirmed) return;
    if (!context.mounted) return;

    final controller = ref.read(todoControllerProvider.notifier);
    final success = await controller.deleteTodo(todoId: todoId);

    if (!context.mounted) return;

    if (success) {
      context.go(Routes.home);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('할 일이 삭제되었습니다'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 완료 상태 토글
  Future<void> _handleToggleComplete(
    BuildContext context,
    WidgetRef ref,
    Todo todo,
  ) async {
    final controller = ref.read(todoControllerProvider.notifier);
    await controller.toggleComplete(
      todoId: todo.id,
      isCompleted: todo.isCompleted,
    );
  }
}
