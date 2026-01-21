import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

import '../todo/domain/entities/todo.dart';
import 'models/calendar_widget_data.dart';
import 'models/weekly_widget_data.dart';
import 'models/widget_todo.dart';

/// 위젯 데이터 동기화 서비스
///
/// Flutter 앱과 Android 홈 위젯 간의 데이터 동기화를 담당합니다.
/// SharedPreferences를 통해 JSON 형태로 데이터를 저장하고,
/// home_widget 패키지를 사용하여 위젯 업데이트를 트리거합니다.
class WidgetDataSync {
  /// 주간 위젯 데이터 저장 키
  static const String weeklyWidgetKey = 'widget_todos_weekly';

  /// 캘린더 위젯 데이터 저장 키
  static const String calendarWidgetKey = 'widget_calendar_data';

  /// Android 위젯 앱 그룹 ID (iOS에서는 사용)
  static const String appGroupId = 'group.com.wedo.app.widget';

  /// 날짜 포맷터 (ISO 8601 날짜)
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// 월 포맷터 (ISO 8601 월)
  static final DateFormat _monthFormat = DateFormat('yyyy-MM');

  /// WidgetDataSync 초기화
  ///
  /// 앱 시작 시 호출하여 위젯 그룹을 설정합니다.
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(appGroupId);
  }

  /// 주간 위젯 데이터 동기화
  ///
  /// [todos] 전체 Todo 목록
  ///
  /// 이번 주의 Todo를 필터링하여 위젯 데이터로 변환하고 저장합니다.
  Future<void> syncWeeklyWidget(List<Todo> todos) async {
    // 이번 주 시작일과 종료일 계산
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    // 이번 주 Todo 필터링
    final weeklyTodos = todos.where((todo) {
      if (todo.dueDate == null) return false;
      final dueDate = todo.dueDate!;
      return !dueDate.isBefore(
              DateTime(weekStart.year, weekStart.month, weekStart.day)) &&
          !dueDate.isAfter(DateTime(weekEnd.year, weekEnd.month, weekEnd.day,
              23, 59, 59));
    }).toList();

    // WidgetTodo로 변환
    final widgetTodos = weeklyTodos.map((todo) => _convertToWidgetTodo(todo)).toList();

    // 마감일 기준 정렬
    widgetTodos.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });

    // WeeklyWidgetData 생성
    final weeklyData = WeeklyWidgetData(
      todos: widgetTodos,
      weekStart: _dateFormat.format(weekStart),
      weekEnd: _dateFormat.format(weekEnd),
      lastSyncTimestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      totalCount: widgetTodos.length,
    );

    // SharedPreferences에 저장
    await HomeWidget.saveWidgetData<String>(
      weeklyWidgetKey,
      jsonEncode(weeklyData.toJson()),
    );

    // 위젯 업데이트 트리거
    await HomeWidget.updateWidget(
      androidName: 'WeeklyTodoWidgetProvider',
    );
  }

  /// 캘린더 위젯 데이터 동기화
  ///
  /// [todos] 전체 Todo 목록
  ///
  /// 이번 달의 Todo 통계를 계산하여 위젯 데이터로 저장합니다.
  Future<void> syncCalendarWidget(List<Todo> todos) async {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    // 이번 달 Todo 필터링 및 날짜별 그룹화
    final Map<String, int> todoCountByDate = {};

    for (final todo in todos) {
      if (todo.dueDate == null) continue;
      final dueDate = todo.dueDate!;

      // 이번 달 범위 확인
      if (dueDate.isBefore(currentMonth) || !dueDate.isBefore(nextMonth)) {
        continue;
      }

      final dateKey = _dateFormat.format(dueDate);
      todoCountByDate[dateKey] = (todoCountByDate[dateKey] ?? 0) + 1;
    }

    // 오늘 Todo 개수 계산
    final todayKey = _dateFormat.format(now);
    final todayTodoCount = todoCountByDate[todayKey] ?? 0;

    // 이번 주 Todo 개수 계산
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    int weekTodoCount = 0;

    for (final todo in todos) {
      if (todo.dueDate == null) continue;
      final dueDate = todo.dueDate!;
      if (!dueDate.isBefore(
              DateTime(weekStart.year, weekStart.month, weekStart.day)) &&
          !dueDate.isAfter(DateTime(weekEnd.year, weekEnd.month, weekEnd.day,
              23, 59, 59))) {
        weekTodoCount++;
      }
    }

    // CalendarWidgetData 생성
    final calendarData = CalendarWidgetData(
      currentMonth: _monthFormat.format(currentMonth),
      todoCountByDate: todoCountByDate,
      todayTodoCount: todayTodoCount,
      weekTodoCount: weekTodoCount,
      lastSyncTimestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    // SharedPreferences에 저장
    await HomeWidget.saveWidgetData<String>(
      calendarWidgetKey,
      jsonEncode(calendarData.toJson()),
    );

    // 위젯 업데이트 트리거
    await HomeWidget.updateWidget(
      androidName: 'CalendarWidgetProvider',
    );
  }

  /// 모든 위젯 데이터 동기화
  ///
  /// [todos] 전체 Todo 목록
  ///
  /// 주간 위젯과 캘린더 위젯을 병렬로 동기화합니다.
  Future<void> syncAllWidgets(List<Todo> todos) async {
    await Future.wait([
      syncWeeklyWidget(todos),
      syncCalendarWidget(todos),
    ]);
  }

  /// Todo를 WidgetTodo로 변환
  WidgetTodo _convertToWidgetTodo(Todo todo) {
    return WidgetTodo(
      id: todo.id,
      title: todo.title,
      category: todo.category,
      dueDate: todo.dueDate != null ? _dateFormat.format(todo.dueDate!) : null,
      dueTime: todo.dueTime,
      isCompleted: todo.isCompleted,
      isOverdue: todo.isOverdue,
      creatorName: todo.creatorName,
    );
  }
}
