import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';

/// Todo 카테고리 선택 위젯
///
/// 칩(Chip) 형태로 카테고리를 선택할 수 있는 위젯입니다.
/// 각 카테고리는 아이콘과 한글 이름으로 표시됩니다.
///
/// 사용 예:
/// ```dart
/// CategorySelector(
///   selectedCategory: _selectedCategory,
///   onCategorySelected: (category) {
///     setState(() => _selectedCategory = category);
///   },
/// )
/// ```
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  /// 현재 선택된 카테고리
  final TodoCategory? selectedCategory;

  /// 카테고리 선택 콜백
  final ValueChanged<TodoCategory?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        Text(
          '카테고리',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // 카테고리 칩 목록
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TodoCategory.allCategories.map((category) {
            final isSelected = selectedCategory == category;
            return _CategoryChip(
              category: category,
              isSelected: isSelected,
              onTap: () {
                // 이미 선택된 카테고리를 다시 탭하면 선택 해제
                onCategorySelected(isSelected ? null : category);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// 개별 카테고리 칩 위젯
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final TodoCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 16,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            category.displayName,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      selectedColor: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
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
}
