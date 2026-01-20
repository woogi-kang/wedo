import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

/// Todo 목록 실시간 감시 Use Case
///
/// Clean Architecture의 Use Case 패턴을 따릅니다.
/// 단일 책임 원칙에 따라 Todo 실시간 스트림 로직만 처리합니다.
class WatchTodosUseCase {
  const WatchTodosUseCase(this._repository);

  final TodoRepository _repository;

  /// 전역 Todo 실시간 감시 실행
  ///
  /// Returns: [Todo] 리스트 스트림
  Stream<List<Todo>> call() {
    return _repository.watchTodos();
  }

  /// 특정 날짜의 Todo 실시간 감시 실행
  ///
  /// [date] 조회할 날짜
  ///
  /// Returns: [Todo] 리스트 스트림
  Stream<List<Todo>> byDate({required DateTime date}) {
    return _repository.watchTodosByDate(date: date);
  }
}
