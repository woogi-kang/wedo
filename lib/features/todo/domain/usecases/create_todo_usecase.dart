import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

/// Todo 생성 Use Case
///
/// Clean Architecture의 Use Case 패턴을 따릅니다.
/// 단일 책임 원칙에 따라 Todo 생성 로직만 처리합니다.
class CreateTodoUseCase {
  const CreateTodoUseCase(this._repository);

  final TodoRepository _repository;

  /// Todo 생성 실행
  ///
  /// [coupleId] 커플 ID
  /// [creatorId] Todo 생성자 ID
  /// [title] Todo 제목
  /// [description] Todo 설명 (선택)
  /// [category] Todo 카테고리 (선택)
  /// [dueDate] 마감 날짜 (선택)
  /// [dueTime] 마감 시간 "HH:mm" 형식 (선택)
  ///
  /// Returns: 생성된 [Todo] 엔티티
  /// Throws: [CreateTodoException] Todo 생성 실패 시
  Future<Todo> call({
    required String coupleId,
    required String creatorId,
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  }) {
    return _repository.createTodo(
      coupleId: coupleId,
      creatorId: creatorId,
      title: title,
      description: description,
      category: category,
      dueDate: dueDate,
      dueTime: dueTime,
    );
  }
}
