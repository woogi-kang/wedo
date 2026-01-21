import 'package:freezed_annotation/freezed_annotation.dart';
import 'widget_todo.dart';

part 'weekly_widget_data.freezed.dart';
part 'weekly_widget_data.g.dart';

/// 주간 위젯 데이터 모델
///
/// 주간 Todo 위젯에 표시할 데이터를 담는 모델입니다.
/// 현재 주의 Todo 목록과 메타데이터를 포함합니다.
///
/// SharedPreferences 키: 'widget_todos_weekly'
@freezed
class WeeklyWidgetData with _$WeeklyWidgetData {
  const factory WeeklyWidgetData({
    /// 이번 주 Todo 목록
    required List<WidgetTodo> todos,

    /// 주 시작일 (ISO 8601 형식: "2026-01-20")
    required String weekStart,

    /// 주 종료일 (ISO 8601 형식: "2026-01-26")
    required String weekEnd,

    /// 마지막 동기화 타임스탬프 (Unix timestamp, 초 단위)
    required int lastSyncTimestamp,

    /// 전체 Todo 개수
    required int totalCount,
  }) = _WeeklyWidgetData;

  /// JSON에서 WeeklyWidgetData 생성
  factory WeeklyWidgetData.fromJson(Map<String, dynamic> json) =>
      _$WeeklyWidgetDataFromJson(json);
}
