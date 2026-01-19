import 'package:flutter/material.dart';

/// Todo가 없을 때 표시하는 빈 상태 위젯
///
/// 일러스트레이션과 메시지를 통해 사용자에게 빈 상태를 알립니다.
/// AC-021: 할 일이 없을 때 빈 상태 표시
class EmptyTodoState extends StatelessWidget {
  const EmptyTodoState({
    super.key,
    this.onCreateTodo,
  });

  /// 할 일 생성 버튼 클릭 콜백
  final VoidCallback? onCreateTodo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 일러스트레이션 아이콘
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checklist_rounded,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // 메인 메시지
            Text(
              '할 일이 없어요',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 서브 메시지
            Text(
              '새로운 할 일을 추가해서\n함께 목표를 달성해보세요!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 할 일 추가 버튼
            if (onCreateTodo != null)
              FilledButton.icon(
                onPressed: onCreateTodo,
                icon: const Icon(Icons.add_rounded),
                label: const Text('새 할 일 추가'),
              ),
          ],
        ),
      ),
    );
  }
}
