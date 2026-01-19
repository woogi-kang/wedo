import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

/// Todo 완료 상태 토글 Use Case
///
/// Clean Architecture의 Use Case 패턴을 따릅니다.
/// 단일 책임 원칙에 따라 Todo 완료 상태 변경 로직만 처리합니다.
class ToggleCompleteUseCase {
  const ToggleCompleteUseCase(this._repository);

  final TodoRepository _repository;

  /// Todo 완료 상태 토글 실행
  ///
  /// [coupleId] 커플 ID
  /// [todoId] Todo ID
  /// [completedBy] 완료 처리하는 사용자 ID (완료 시), null (미완료로 변경 시)
  ///
  /// Returns: 업데이트된 [Todo] 엔티티
  /// Throws: [UpdateTodoException] 상태 변경 실패 시
  Future<Todo> call({
    required String coupleId,
    required String todoId,
    required String? completedBy,
  }) {
    return _repository.toggleComplete(
      coupleId: coupleId,
      todoId: todoId,
      completedBy: completedBy,
    );
  }
}
