import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/todo.dart';
import 'todo_provider.dart';

part 'view_mode_provider.g.dart';

/// 보기 모드 열거형
///
/// 일간, 주간, 월간 보기 모드를 정의합니다.
enum ViewMode {
  daily('일간'),
  weekly('주간'),
  monthly('월간');

  const ViewMode(this.label);

  /// 보기 모드 레이블
  final String label;
}

/// 보기 모드 상태
///
/// 현재 선택된 보기 모드와 기준 날짜를 관리합니다.
class ViewModeState {
  const ViewModeState({
    this.mode = ViewMode.daily,
    required this.selectedDate,
  });

  /// 현재 보기 모드
  final ViewMode mode;

  /// 선택된 날짜 (일간: 특정 날짜, 주간: 주의 시작일, 월간: 월의 첫 날)
  final DateTime selectedDate;

  /// 복사본 생성
  ViewModeState copyWith({
    ViewMode? mode,
    DateTime? selectedDate,
  }) {
    return ViewModeState(
      mode: mode ?? this.mode,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

/// ViewMode Notifier Provider
///
/// 보기 모드 상태를 관리하는 Notifier입니다.
///
/// keepAlive: true로 설정하여 화면 이동 시에도 보기 모드 설정이 유지됩니다.
@Riverpod(keepAlive: true)
class ViewModeNotifier extends _$ViewModeNotifier {
  @override
  ViewModeState build() {
    // 기본값: 오늘 날짜로 일간 보기
    return ViewModeState(
      mode: ViewMode.daily,
      selectedDate: _normalizeDate(DateTime.now()),
    );
  }

  /// 날짜를 정규화 (시간 정보 제거)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 보기 모드 변경
  void setViewMode(ViewMode mode) {
    state = state.copyWith(mode: mode);
  }

  /// 선택된 날짜 변경
  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: _normalizeDate(date));
  }

  /// 오늘로 이동
  void goToToday() {
    state = state.copyWith(selectedDate: _normalizeDate(DateTime.now()));
  }

  /// 이전 날짜/주/월로 이동
  void goToPrevious() {
    final current = state.selectedDate;
    DateTime newDate;

    switch (state.mode) {
      case ViewMode.daily:
        newDate = current.subtract(const Duration(days: 1));
        break;
      case ViewMode.weekly:
        newDate = current.subtract(const Duration(days: 7));
        break;
      case ViewMode.monthly:
        newDate = DateTime(current.year, current.month - 1, 1);
        break;
    }

    state = state.copyWith(selectedDate: _normalizeDate(newDate));
  }

  /// 다음 날짜/주/월로 이동
  void goToNext() {
    final current = state.selectedDate;
    DateTime newDate;

    switch (state.mode) {
      case ViewMode.daily:
        newDate = current.add(const Duration(days: 1));
        break;
      case ViewMode.weekly:
        newDate = current.add(const Duration(days: 7));
        break;
      case ViewMode.monthly:
        newDate = DateTime(current.year, current.month + 1, 1);
        break;
    }

    state = state.copyWith(selectedDate: _normalizeDate(newDate));
  }

  /// 주의 시작일 (월요일) 계산
  DateTime getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return _normalizeDate(date.subtract(Duration(days: weekday - 1)));
  }

  /// 주의 마지막일 (일요일) 계산
  DateTime getWeekEnd(DateTime date) {
    final weekday = date.weekday;
    return _normalizeDate(date.add(Duration(days: 7 - weekday)));
  }
}

/// 일간 보기용 필터링된 Todo 목록
///
/// 선택된 날짜의 Todo만 반환합니다.
@riverpod
List<Todo> dailyTodos(Ref ref) {
  final viewModeState = ref.watch(viewModeNotifierProvider);
  final todosAsync = ref.watch(todosStreamProvider);

  return todosAsync.whenOrNull(
        data: (todos) {
          final selectedDate = viewModeState.selectedDate;
          return todos.where((todo) {
            if (todo.dueDate == null) return false;
            return _isSameDay(todo.dueDate!, selectedDate);
          }).toList();
        },
      ) ??
      [];
}

/// 주간 보기용 필터링된 Todo 목록
///
/// 선택된 주의 Todo를 요일별로 그룹화하여 반환합니다.
@riverpod
Map<DateTime, List<Todo>> weeklyTodos(Ref ref) {
  final viewModeState = ref.watch(viewModeNotifierProvider);
  final todosAsync = ref.watch(todosStreamProvider);
  final notifier = ref.read(viewModeNotifierProvider.notifier);

  return todosAsync.whenOrNull(
        data: (todos) {
          final weekStart = notifier.getWeekStart(viewModeState.selectedDate);
          final weekEnd = notifier.getWeekEnd(viewModeState.selectedDate);

          // 주간 범위의 Todo 필터링
          final weekTodos = todos.where((todo) {
            if (todo.dueDate == null) return false;
            final dueDate = DateTime(
              todo.dueDate!.year,
              todo.dueDate!.month,
              todo.dueDate!.day,
            );
            return !dueDate.isBefore(weekStart) && !dueDate.isAfter(weekEnd);
          }).toList();

          // 요일별 그룹화
          final Map<DateTime, List<Todo>> grouped = {};
          for (var i = 0; i < 7; i++) {
            final day = weekStart.add(Duration(days: i));
            grouped[day] = weekTodos.where((todo) {
              return _isSameDay(todo.dueDate!, day);
            }).toList();
          }

          return grouped;
        },
      ) ??
      {};
}

/// 월간 보기용 필터링된 Todo 목록
///
/// 선택된 월의 Todo를 날짜별로 그룹화하여 반환합니다.
@riverpod
Map<DateTime, List<Todo>> monthlyTodos(Ref ref) {
  final viewModeState = ref.watch(viewModeNotifierProvider);
  final todosAsync = ref.watch(todosStreamProvider);

  return todosAsync.whenOrNull(
        data: (todos) {
          final selectedDate = viewModeState.selectedDate;
          final monthStart = DateTime(selectedDate.year, selectedDate.month, 1);
          final monthEnd = DateTime(selectedDate.year, selectedDate.month + 1, 0);

          // 월간 범위의 Todo 필터링
          final monthTodos = todos.where((todo) {
            if (todo.dueDate == null) return false;
            final dueDate = DateTime(
              todo.dueDate!.year,
              todo.dueDate!.month,
              todo.dueDate!.day,
            );
            return !dueDate.isBefore(monthStart) && !dueDate.isAfter(monthEnd);
          }).toList();

          // 날짜별 그룹화
          final Map<DateTime, List<Todo>> grouped = {};
          for (final todo in monthTodos) {
            final day = DateTime(
              todo.dueDate!.year,
              todo.dueDate!.month,
              todo.dueDate!.day,
            );
            grouped.putIfAbsent(day, () => []).add(todo);
          }

          return grouped;
        },
      ) ??
      {};
}

/// 두 날짜가 같은 날인지 확인
bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
