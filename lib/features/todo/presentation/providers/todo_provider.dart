import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/exceptions/todo_exception.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../widget/widget_data_sync.dart';
import '../../data/datasources/todo_remote_datasource.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

part 'todo_provider.g.dart';

/// TodoRemoteDataSource Provider
///
/// Firestore 데이터 소스 인스턴스를 제공합니다.
@Riverpod(keepAlive: true)
TodoRemoteDataSource todoRemoteDataSource(Ref ref) {
  return TodoRemoteDataSourceImpl();
}

/// TodoRepository Provider
///
/// Todo 관련 비즈니스 로직을 수행하는 Repository 인스턴스를 제공합니다.
@Riverpod(keepAlive: true)
TodoRepository todoRepository(Ref ref) {
  final dataSource = ref.watch(todoRemoteDataSourceProvider);
  return TodoRepositoryImpl(dataSource);
}

/// 단일 Todo Provider (Family)
///
/// todoId로 특정 Todo를 조회합니다.
/// todosStream에서 해당 ID를 가진 Todo를 찾아 반환합니다.
/// Todo가 없으면 null을 반환합니다.
@riverpod
Todo? todo(Ref ref, String todoId) {
  final todosAsync = ref.watch(todosStreamProvider);

  return todosAsync.whenOrNull(
    data: (todos) => todos.where((t) => t.id == todoId).firstOrNull,
  );
}

/// 전역 Todo 실시간 스트림 Provider
///
/// 모든 사용자가 공유하는 전역 Todo를 실시간으로 감지합니다.
/// 로그인되어 있으면 Todo 리스트를 반환합니다.
///
/// keepAlive: true로 설정하여 화면 이동 시에도 스트림 구독이 유지됩니다.
@Riverpod(keepAlive: true)
Stream<List<Todo>> todosStream(Ref ref) async* {
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    yield [];
    return;
  }

  final repository = ref.watch(todoRepositoryProvider);
  yield* repository.watchTodos();
}

/// Todo Controller Provider
///
/// Todo CRUD 작업을 수행하는 컨트롤러입니다.
/// UI에서 Todo 작업을 수행할 때 이 Provider를 사용합니다.
///
/// 전역 Todo 시스템: 모든 사용자가 하나의 Todo 리스트를 공유합니다.
@riverpod
class TodoController extends _$TodoController {
  /// 위젯 동기화 서비스
  final WidgetDataSync _widgetDataSync = WidgetDataSync();

  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  TodoRepository get _repository => ref.read(todoRepositoryProvider);

  String? get _currentUserId => ref.read(currentUserProvider)?.uid;

  String? get _currentUserName => ref.read(currentUserProvider)?.displayName;

  /// 위젯 데이터 동기화
  ///
  /// Todo CRUD 작업 후 호출하여 위젯 데이터를 업데이트합니다.
  Future<void> _syncWidgets() async {
    try {
      final todosAsync = ref.read(todosStreamProvider);
      final todos = todosAsync.valueOrNull ?? [];

      developer.log('위젯 동기화 시작: ${todos.length}개 Todo', name: 'TodoController');

      await _widgetDataSync.syncAllWidgets(todos);

      developer.log('위젯 동기화 완료', name: 'TodoController');
    } catch (e) {
      developer.log('위젯 동기화 실패: $e', name: 'TodoController');
      // 위젯 동기화 실패는 주요 작업에 영향을 주지 않음
    }
  }

  /// 새 Todo 생성
  ///
  /// [title] Todo 제목
  /// [description] Todo 설명 (선택)
  /// [category] Todo 카테고리 (선택)
  /// [dueDate] 마감 날짜 (선택)
  /// [dueTime] 마감 시간 "HH:mm" 형식 (선택)
  Future<bool> createTodo({
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  }) async {
    final userId = _currentUserId;
    final userName = _currentUserName;

    if (userId == null || userName == null) {
      state = AsyncError('로그인이 필요합니다.', StackTrace.current);
      return false;
    }

    state = const AsyncLoading();

    try {
      await _repository.createTodo(
        creatorId: userId,
        creatorName: userName,
        title: title,
        description: description,
        category: category,
        dueDate: dueDate,
        dueTime: dueTime,
      );
      state = const AsyncData(null);

      // Todo 생성 후 위젯 동기화
      await _syncWidgets();

      return true;
    } on CreateTodoException catch (e) {
      state = AsyncError(e.message, StackTrace.current);
      return false;
    } catch (e) {
      state = AsyncError('할 일 생성 중 오류가 발생했습니다.', StackTrace.current);
      return false;
    }
  }

  /// Todo 완료 상태 토글
  ///
  /// [todoId] 토글할 Todo ID
  /// [isCompleted] 현재 완료 상태 (true면 미완료로, false면 완료로)
  Future<bool> toggleComplete({
    required String todoId,
    required bool isCompleted,
  }) async {
    final userId = _currentUserId;
    final userName = _currentUserName;

    if (userId == null) {
      state = AsyncError('로그인이 필요합니다.', StackTrace.current);
      return false;
    }

    state = const AsyncLoading();

    try {
      await _repository.toggleComplete(
        todoId: todoId,
        // 완료 시 사용자 ID 및 이름, 미완료로 변경 시 null
        completedBy: isCompleted ? null : userId,
        completedByName: isCompleted ? null : userName,
      );
      state = const AsyncData(null);

      // 완료 상태 변경 후 위젯 동기화
      await _syncWidgets();

      return true;
    } on UpdateTodoException catch (e) {
      state = AsyncError(e.message, StackTrace.current);
      return false;
    } catch (e) {
      state = AsyncError('상태 변경 중 오류가 발생했습니다.', StackTrace.current);
      return false;
    }
  }

  /// Todo 삭제
  ///
  /// [todoId] 삭제할 Todo ID
  Future<bool> deleteTodo({required String todoId}) async {
    final userId = _currentUserId;

    if (userId == null) {
      state = AsyncError('로그인이 필요합니다.', StackTrace.current);
      return false;
    }

    state = const AsyncLoading();

    try {
      await _repository.deleteTodo(todoId: todoId);
      state = const AsyncData(null);

      // Todo 삭제 후 위젯 동기화
      await _syncWidgets();

      return true;
    } on DeleteTodoException catch (e) {
      state = AsyncError(e.message, StackTrace.current);
      return false;
    } catch (e) {
      state = AsyncError('삭제 중 오류가 발생했습니다.', StackTrace.current);
      return false;
    }
  }

  /// Todo 업데이트
  ///
  /// [todoId] 업데이트할 Todo ID
  /// [title] 새 제목 (선택)
  /// [description] 새 설명 (선택)
  /// [category] 새 카테고리 (선택)
  /// [dueDate] 새 마감 날짜 (선택)
  /// [dueTime] 새 마감 시간 (선택)
  Future<bool> updateTodo({
    required String todoId,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  }) async {
    final userId = _currentUserId;

    if (userId == null) {
      state = AsyncError('로그인이 필요합니다.', StackTrace.current);
      return false;
    }

    state = const AsyncLoading();

    try {
      await _repository.updateTodo(
        todoId: todoId,
        title: title,
        description: description,
        category: category,
        dueDate: dueDate,
        dueTime: dueTime,
      );
      state = const AsyncData(null);

      // Todo 업데이트 후 위젯 동기화
      await _syncWidgets();

      return true;
    } on UpdateTodoException catch (e) {
      state = AsyncError(e.message, StackTrace.current);
      return false;
    } catch (e) {
      state = AsyncError('업데이트 중 오류가 발생했습니다.', StackTrace.current);
      return false;
    }
  }

  /// 에러 상태 초기화
  void clearError() {
    state = const AsyncData(null);
  }
}
