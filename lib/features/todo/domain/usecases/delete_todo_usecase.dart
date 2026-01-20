import '../repositories/todo_repository.dart';

/// Todo 삭제 Use Case
///
/// Clean Architecture의 Use Case 패턴을 따릅니다.
/// 단일 책임 원칙에 따라 Todo 삭제 로직만 처리합니다.
class DeleteTodoUseCase {
  const DeleteTodoUseCase(this._repository);

  final TodoRepository _repository;

  /// Todo 삭제 실행
  ///
  /// [todoId] 삭제할 Todo ID
  ///
  /// Throws: [DeleteTodoException] Todo 삭제 실패 시
  Future<void> call({required String todoId}) {
    return _repository.deleteTodo(todoId: todoId);
  }
}
