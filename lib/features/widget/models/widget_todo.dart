import 'package:freezed_annotation/freezed_annotation.dart';

part 'widget_todo.freezed.dart';
part 'widget_todo.g.dart';

/// 위젯 전용 Todo 모델
///
/// 홈 위젯에 표시할 Todo 데이터를 담는 경량화된 모델입니다.
/// Android 위젯과 Flutter 간 데이터 전송에 사용됩니다.
///
/// SharedPreferences를 통해 JSON 형태로 저장됩니다.
@freezed
class WidgetTodo with _$WidgetTodo {
  const factory WidgetTodo({
    /// Todo 고유 ID
    required String id,

    /// Todo 제목
    required String title,

    /// Todo 카테고리 (선택)
    String? category,

    /// 마감 날짜 (ISO 8601 형식: "2026-01-21")
    String? dueDate,

    /// 마감 시간 ("HH:mm" 형식: "14:30")
    String? dueTime,

    /// 완료 여부
    @Default(false) bool isCompleted,

    /// 기한 초과 여부
    @Default(false) bool isOverdue,

    /// 생성자 이름 (표시용)
    required String creatorName,
  }) = _WidgetTodo;

  /// JSON에서 WidgetTodo 생성
  factory WidgetTodo.fromJson(Map<String, dynamic> json) =>
      _$WidgetTodoFromJson(json);
}
