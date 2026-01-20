import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

/// Todo 업데이트 Use Case
///
/// Clean Architecture의 Use Case 패턴을 따릅니다.
/// 단일 책임 원칙에 따라 Todo 업데이트 로직만 처리합니다.
class UpdateTodoUseCase {
  const UpdateTodoUseCase(this._repository);

  final TodoRepository _repository;

  /// Todo 업데이트 실행
  ///
  /// [todoId] 업데이트할 Todo ID
  /// [title] 새 제목 (선택)
  /// [description] 새 설명 (선택)
  /// [category] 새 카테고리 (선택)
  /// [dueDate] 새 마감 날짜 (선택)
  /// [dueTime] 새 마감 시간 (선택)
  ///
  /// Returns: 업데이트된 [Todo] 엔티티
  /// Throws: [UpdateTodoException] Todo 업데이트 실패 시
  Future<Todo> call({
    required String todoId,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  }) {
    return _repository.updateTodo(
      todoId: todoId,
      title: title,
      description: description,
      category: category,
      dueDate: dueDate,
      dueTime: dueTime,
    );
  }
}
