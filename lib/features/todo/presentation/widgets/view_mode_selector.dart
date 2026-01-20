import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/view_mode_provider.dart';

/// 보기 모드 선택기 위젯
///
/// 일간/주간/월간 보기 모드를 선택할 수 있는 SegmentedButton과
/// 날짜 네비게이션을 제공합니다.
class ViewModeSelector extends ConsumerWidget {
  const ViewModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModeState = ref.watch(viewModeNotifierProvider);
    final notifier = ref.read(viewModeNotifierProvider.notifier);

    return Column(
      children: [
        // 보기 모드 선택 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedButton<ViewMode>(
            segments: ViewMode.values.map((mode) {
              return ButtonSegment<ViewMode>(
                value: mode,
                label: Text(mode.label),
                icon: Icon(_getIconForMode(mode)),
              );
            }).toList(),
            selected: {viewModeState.mode},
            onSelectionChanged: (Set<ViewMode> selection) {
              notifier.setViewMode(selection.first);
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),

        // 날짜 네비게이션
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 이전 버튼
              IconButton(
                onPressed: () => notifier.goToPrevious(),
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: _getPreviousTooltip(viewModeState.mode),
              ),

              // 현재 날짜/기간 표시
              TextButton.icon(
                onPressed: () => notifier.goToToday(),
                icon: Icon(
                  Icons.today_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                label: Text(
                  _formatDateRange(viewModeState, notifier),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // 다음 버튼
              IconButton(
                onPressed: () => notifier.goToNext(),
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: _getNextTooltip(viewModeState.mode),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 보기 모드에 따른 아이콘 반환
  IconData _getIconForMode(ViewMode mode) {
    switch (mode) {
      case ViewMode.daily:
        return Icons.view_day_rounded;
      case ViewMode.weekly:
        return Icons.view_week_rounded;
      case ViewMode.monthly:
        return Icons.calendar_month_rounded;
    }
  }

  /// 날짜 범위 포맷팅
  String _formatDateRange(ViewModeState state, ViewModeNotifier notifier) {
    final date = state.selectedDate;
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');
    final monthFormat = DateFormat('yyyy년 M월', 'ko_KR');

    switch (state.mode) {
      case ViewMode.daily:
        // 오늘이면 "오늘" 표시
        if (_isToday(date)) {
          return '오늘 - ${dateFormat.format(date)}';
        }
        return dateFormat.format(date);

      case ViewMode.weekly:
        final weekStart = notifier.getWeekStart(date);
        final weekEnd = notifier.getWeekEnd(date);
        final startFormat = DateFormat('M/d', 'ko_KR');
        final endFormat = DateFormat('M/d', 'ko_KR');
        return '${startFormat.format(weekStart)} - ${endFormat.format(weekEnd)}';

      case ViewMode.monthly:
        return monthFormat.format(date);
    }
  }

  /// 오늘인지 확인
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// 이전 버튼 툴팁
  String _getPreviousTooltip(ViewMode mode) {
    switch (mode) {
      case ViewMode.daily:
        return '이전 날';
      case ViewMode.weekly:
        return '이전 주';
      case ViewMode.monthly:
        return '이전 달';
    }
  }

  /// 다음 버튼 툴팁
  String _getNextTooltip(ViewMode mode) {
    switch (mode) {
      case ViewMode.daily:
        return '다음 날';
      case ViewMode.weekly:
        return '다음 주';
      case ViewMode.monthly:
        return '다음 달';
    }
  }
}
