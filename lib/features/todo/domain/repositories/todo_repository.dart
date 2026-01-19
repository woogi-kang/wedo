import '../entities/todo.dart';

/// Todo Repository 인터페이스
///
/// 도메인 레이어에서 정의하는 Todo 관련 추상 인터페이스입니다.
/// 데이터 레이어의 TodoRepositoryImpl에서 구현됩니다.
///
/// Clean Architecture 원칙에 따라 도메인 레이어는 데이터 소스의
/// 구체적인 구현에 의존하지 않습니다.
abstract interface class TodoRepository {
  /// 새 Todo 생성
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
  Future<Todo> createTodo({
    required String coupleId,
    required String creatorId,
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  });

  /// Todo 업데이트
  ///
  /// [coupleId] 커플 ID
  /// [todoId] 업데이트할 Todo ID
  /// [title] 새 제목 (선택)
  /// [description] 새 설명 (선택)
  /// [category] 새 카테고리 (선택)
  /// [dueDate] 새 마감 날짜 (선택)
  /// [dueTime] 새 마감 시간 (선택)
  ///
  /// Returns: 업데이트된 [Todo] 엔티티
  /// Throws: [UpdateTodoException] Todo 업데이트 실패 시
  Future<Todo> updateTodo({
    required String coupleId,
    required String todoId,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  });

  /// Todo 삭제
  ///
  /// [coupleId] 커플 ID
  /// [todoId] 삭제할 Todo ID
  ///
  /// Throws: [DeleteTodoException] Todo 삭제 실패 시
  Future<void> deleteTodo({
    required String coupleId,
    required String todoId,
  });

  /// Todo 완료 상태 토글
  ///
  /// [coupleId] 커플 ID
  /// [todoId] Todo ID
  /// [completedBy] 완료 처리하는 사용자 ID (완료 시), null (미완료로 변경 시)
  ///
  /// Returns: 업데이트된 [Todo] 엔티티
  /// Throws: [UpdateTodoException] 상태 변경 실패 시
  Future<Todo> toggleComplete({
    required String coupleId,
    required String todoId,
    required String? completedBy,
  });

  /// Todo ID로 단일 Todo 조회
  ///
  /// [coupleId] 커플 ID
  /// [todoId] 조회할 Todo ID
  ///
  /// Returns: [Todo] 엔티티 또는 null (존재하지 않는 경우)
  /// Throws: [GetTodoException] 조회 실패 시
  Future<Todo?> getTodo({
    required String coupleId,
    required String todoId,
  });

  /// 커플의 모든 Todo 조회
  ///
  /// [coupleId] 커플 ID
  ///
  /// Returns: [Todo] 리스트
  /// Throws: [GetTodoException] 조회 실패 시
  Future<List<Todo>> getTodos({required String coupleId});

  /// 커플의 Todo 실시간 스트림
  ///
  /// [coupleId] 구독할 커플 ID
  ///
  /// Firestore의 실시간 업데이트를 스트림으로 전달합니다.
  /// Todo 추가, 수정, 삭제 등의 변경을 실시간으로 감지합니다.
  ///
  /// Returns: [Todo] 리스트 스트림
  Stream<List<Todo>> watchTodos({required String coupleId});

  /// 특정 날짜의 Todo 실시간 스트림
  ///
  /// [coupleId] 구독할 커플 ID
  /// [date] 조회할 날짜
  ///
  /// 해당 날짜에 마감인 Todo를 실시간으로 전달합니다.
  ///
  /// Returns: [Todo] 리스트 스트림
  Stream<List<Todo>> watchTodosByDate({
    required String coupleId,
    required DateTime date,
  });
}
