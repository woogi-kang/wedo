import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo.freezed.dart';

/// WeDo Todo 엔티티
///
/// 도메인 레이어의 핵심 엔티티로, 전역 할 일 관리 비즈니스 로직에서 사용됩니다.
/// Firestore '/todos/{todoId}' 컬렉션의 문서 구조와 매핑됩니다.
///
/// Firestore 구조:
/// ```
/// /todos/{todoId}
///   - id: string
///   - creatorId: string
///   - creatorName: string
///   - title: string
///   - description: string?
///   - category: string?
///   - dueDate: timestamp?
///   - dueTime: string? ("HH:mm" format)
///   - isCompleted: boolean
///   - completedBy: string?
///   - completedByName: string?
///   - createdAt: timestamp
///   - updatedAt: timestamp
/// ```
@freezed
class Todo with _$Todo {
  const factory Todo({
    /// Todo 고유 ID (Firestore 문서 ID)
    required String id,

    /// Todo 생성자 ID
    required String creatorId,

    /// Todo 생성자 이름 (표시용)
    required String creatorName,

    /// Todo 제목
    required String title,

    /// Todo 설명 (선택)
    String? description,

    /// Todo 카테고리 (선택)
    String? category,

    /// 마감 날짜 (선택)
    DateTime? dueDate,

    /// 마감 시간 ("HH:mm" 형식, 선택)
    String? dueTime,

    /// 완료 여부
    @Default(false) bool isCompleted,

    /// 완료한 사용자 ID (완료 시 설정)
    String? completedBy,

    /// 완료한 사용자 이름 (표시용)
    String? completedByName,

    /// Todo 생성 일시
    required DateTime createdAt,

    /// Todo 수정 일시
    required DateTime updatedAt,
  }) = _Todo;

  /// Todo를 private constructor로 확장하여 getter 추가 가능하게 함
  const Todo._();

  /// 마감 일시가 있는지 여부
  bool get hasDueDate => dueDate != null;

  /// 마감 시간이 있는지 여부
  bool get hasDueTime => dueTime != null;

  /// 완전한 마감 일시 (날짜 + 시간)
  DateTime? get dueDateTime {
    if (dueDate == null) return null;
    if (dueTime == null) return dueDate;

    final timeParts = dueTime!.split(':');
    if (timeParts.length != 2) return dueDate;

    final hour = int.tryParse(timeParts[0]) ?? 0;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    return DateTime(
      dueDate!.year,
      dueDate!.month,
      dueDate!.day,
      hour,
      minute,
    );
  }

  /// 기한 초과 여부
  bool get isOverdue {
    if (!hasDueDate || isCompleted) return false;
    final now = DateTime.now();
    final due = dueDateTime ?? dueDate!;
    return due.isBefore(now);
  }

  /// 오늘 마감인지 여부
  bool get isDueToday {
    if (!hasDueDate) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// 특정 사용자가 생성했는지 확인
  bool isCreatedBy(String userId) => creatorId == userId;

  /// 특정 사용자가 완료했는지 확인
  bool isCompletedBy(String userId) => completedBy == userId;
}
