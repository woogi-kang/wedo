import 'package:freezed_annotation/freezed_annotation.dart';

part 'calendar_widget_data.freezed.dart';
part 'calendar_widget_data.g.dart';

/// 캘린더 위젯 데이터 모델
///
/// 캘린더 위젯에 표시할 데이터를 담는 모델입니다.
/// 월별 Todo 통계와 날짜별 Todo 개수를 포함합니다.
///
/// SharedPreferences 키: 'widget_calendar_data'
@freezed
class CalendarWidgetData with _$CalendarWidgetData {
  const factory CalendarWidgetData({
    /// 현재 월 (ISO 8601 형식: "2026-01")
    required String currentMonth,

    /// 날짜별 Todo 개수 (키: "2026-01-21", 값: Todo 개수)
    required Map<String, int> todoCountByDate,

    /// 오늘 Todo 개수
    required int todayTodoCount,

    /// 이번 주 Todo 개수
    required int weekTodoCount,

    /// 마지막 동기화 타임스탬프 (Unix timestamp, 초 단위)
    required int lastSyncTimestamp,
  }) = _CalendarWidgetData;

  /// JSON에서 CalendarWidgetData 생성
  factory CalendarWidgetData.fromJson(Map<String, dynamic> json) =>
      _$CalendarWidgetDataFromJson(json);
}
