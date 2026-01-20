import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../domain/entities/todo.dart';
import '../providers/view_mode_provider.dart';
import 'todo_list_item.dart';

/// 월간 보기 위젯
///
/// 캘린더 형태로 투두를 표시합니다.
/// 투두가 있는 날짜에 도트를 표시하고,
/// 날짜를 탭하면 해당 날짜의 투두 목록을 표시합니다.
class MonthlyView extends ConsumerStatefulWidget {
  const MonthlyView({
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
  ConsumerState<MonthlyView> createState() => _MonthlyViewState();
}

class _MonthlyViewState extends ConsumerState<MonthlyView> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final monthlyTodos = ref.watch(monthlyTodosProvider);
    final notifier = ref.read(viewModeNotifierProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 선택된 날짜의 투두 목록
    final selectedDayTodos = _selectedDay != null
        ? monthlyTodos[DateTime(
              _selectedDay!.year,
              _selectedDay!.month,
              _selectedDay!.day,
            )] ??
            []
        : <Todo>[];

    return Column(
      children: [
        // 캘린더
        TableCalendar<Todo>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: 'ko_KR',
          headerVisible: false, // ViewModeSelector에서 네비게이션 처리

          // 이벤트 로더 - 해당 날짜의 투두 반환
          eventLoader: (day) {
            final normalizedDay = DateTime(day.year, day.month, day.day);
            return monthlyTodos[normalizedDay] ?? [];
          },

          // 날짜 선택 콜백
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            notifier.setSelectedDate(selectedDay);
          },

          // 페이지 변경 콜백
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
            notifier.setSelectedDate(focusedDay);
          },

          // 캘린더 스타일
          calendarStyle: CalendarStyle(
            // 오늘 스타일
            todayDecoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),

            // 선택된 날짜 스타일
            selectedDecoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),

            // 기본 스타일
            defaultTextStyle: TextStyle(
              color: colorScheme.onSurface,
            ),
            weekendTextStyle: TextStyle(
              color: colorScheme.error.withValues(alpha: 0.8),
            ),
            outsideTextStyle: TextStyle(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),

            // 마커 스타일 (투두가 있는 날짜 표시)
            markerDecoration: BoxDecoration(
              color: colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
            markerSize: 6,
            markerMargin: const EdgeInsets.symmetric(horizontal: 1),
          ),

          // 헤더 스타일 (숨김 처리했으므로 사용하지 않음)
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          // 요일 헤더 스타일
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: theme.textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            weekendStyle: theme.textTheme.bodySmall!.copyWith(
              color: colorScheme.error.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),

          // 캘린더 빌더 (커스텀 마커)
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isEmpty) return null;

              // 완료/미완료 비율에 따라 색상 결정
              final todos = events.cast<Todo>();
              final completedCount = todos.where((t) => t.isCompleted).length;
              final allCompleted = completedCount == todos.length;

              return Positioned(
                bottom: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: allCompleted
                            ? colorScheme.tertiary
                            : colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (todos.length > 1) ...[
                      const SizedBox(width: 2),
                      Text(
                        '${todos.length}',
                        style: TextStyle(
                          fontSize: 8,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),

        const Divider(height: 1),

        // 선택된 날짜의 투두 목록
        Expanded(
          child: _buildSelectedDayTodos(context, selectedDayTodos),
        ),
      ],
    );
  }

  /// 선택된 날짜의 투두 목록 빌드
  Widget _buildSelectedDayTodos(BuildContext context, List<Todo> todos) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('M월 d일 (E)', 'ko_KR');

    if (_selectedDay == null) {
      return _buildEmptySelection(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 선택된 날짜 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.event_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(_selectedDay!),
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
                  '${todos.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 투두 목록
        Expanded(
          child: todos.isEmpty
              ? _buildEmptyDayState(context)
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    return TodoListItem(
                      todo: todo,
                      currentUserId: widget.currentUserId,
                      onToggleComplete: () => widget.onToggleComplete(todo),
                      onTap: widget.onTodoTap != null
                          ? () => widget.onTodoTap!(todo)
                          : null,
                      onDelete: widget.onDelete != null
                          ? () => widget.onDelete!(todo)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// 날짜 미선택 상태
  Widget _buildEmptySelection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_rounded,
            size: 48,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '날짜를 선택해주세요',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// 선택된 날짜에 투두가 없는 상태
  Widget _buildEmptyDayState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_rounded,
              size: 48,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '이 날의 할 일이 없습니다',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.onCreateTodo != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: widget.onCreateTodo,
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
