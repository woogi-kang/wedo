import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_remote_datasource.dart';

/// TodoRepository 구현체
///
/// Clean Architecture의 Repository 패턴 구현체입니다.
/// Domain 레이어의 TodoRepository 인터페이스를 구현하고,
/// TodoRemoteDataSource를 사용하여 실제 데이터 작업을 수행합니다.
///
/// Repository는 데이터 소스를 추상화하여 도메인 레이어가
/// 구체적인 데이터 소스 구현에 의존하지 않도록 합니다.
///
/// 전역 Todo 시스템: 모든 사용자가 하나의 Todo 리스트를 공유합니다.
class TodoRepositoryImpl implements TodoRepository {
  const TodoRepositoryImpl(this._remoteDataSource);

  final TodoRemoteDataSource _remoteDataSource;

  @override
  Future<Todo> createTodo({
    required String creatorId,
    required String creatorName,
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  }) async {
    final todoModel = await _remoteDataSource.createTodo(
      creatorId: creatorId,
      creatorName: creatorName,
      title: title,
      description: description,
      category: category,
      dueDate: dueDate,
      dueTime: dueTime,
    );
    return todoModel.toEntity();
  }

  @override
  Future<Todo> updateTodo({
    required String todoId,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  }) async {
    final todoModel = await _remoteDataSource.updateTodo(
      todoId: todoId,
      title: title,
      description: description,
      category: category,
      dueDate: dueDate,
      dueTime: dueTime,
    );
    return todoModel.toEntity();
  }

  @override
  Future<void> deleteTodo({required String todoId}) async {
    await _remoteDataSource.deleteTodo(todoId: todoId);
  }

  @override
  Future<Todo> toggleComplete({
    required String todoId,
    required String? completedBy,
    required String? completedByName,
  }) async {
    final todoModel = await _remoteDataSource.toggleComplete(
      todoId: todoId,
      completedBy: completedBy,
      completedByName: completedByName,
    );
    return todoModel.toEntity();
  }

  @override
  Future<Todo?> getTodo({required String todoId}) async {
    final todoModel = await _remoteDataSource.getTodo(todoId: todoId);
    return todoModel?.toEntity();
  }

  @override
  Future<List<Todo>> getTodos() async {
    final todoModels = await _remoteDataSource.getTodos();
    return todoModels.map((model) => model.toEntity()).toList();
  }

  @override
  Stream<List<Todo>> watchTodos() {
    return _remoteDataSource.watchTodos().map(
          (todoModels) => todoModels.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Stream<List<Todo>> watchTodosByDate({required DateTime date}) {
    return _remoteDataSource
        .watchTodosByDate(date: date)
        .map(
          (todoModels) => todoModels.map((model) => model.toEntity()).toList(),
        );
  }
}
