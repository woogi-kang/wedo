import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/exceptions/todo_exception.dart';
import '../models/todo_model.dart';

/// Todo Remote DataSource 인터페이스
///
/// Cloud Firestore를 사용하는 원격 데이터 소스의 추상 인터페이스입니다.
/// 전역 Todo 시스템을 위해 모든 사용자가 공유하는 `/todos` 컬렉션을 사용합니다.
abstract interface class TodoRemoteDataSource {
  /// 새 Todo 생성
  Future<TodoModel> createTodo({
    required String creatorId,
    required String creatorName,
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  });

  /// Todo 업데이트
  Future<TodoModel> updateTodo({
    required String todoId,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  });

  /// Todo 삭제
  Future<void> deleteTodo({required String todoId});

  /// Todo 완료 상태 토글
  Future<TodoModel> toggleComplete({
    required String todoId,
    required String? completedBy,
    required String? completedByName,
  });

  /// Todo ID로 단일 Todo 조회
  Future<TodoModel?> getTodo({required String todoId});

  /// 모든 Todo 조회
  Future<List<TodoModel>> getTodos();

  /// 모든 Todo 실시간 스트림
  Stream<List<TodoModel>> watchTodos();

  /// 특정 날짜의 Todo 실시간 스트림
  Stream<List<TodoModel>> watchTodosByDate({required DateTime date});
}

/// Todo Remote DataSource 구현체
///
/// Cloud Firestore를 사용하여 Todo 관련 작업을 수행합니다.
/// 전역 `/todos` 컬렉션을 사용하여 모든 사용자가 Todo를 공유합니다.
class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  TodoRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Firestore /todos 컬렉션 참조 (전역)
  CollectionReference<Map<String, dynamic>> get _todosCollection =>
      _firestore.collection('todos');

  @override
  Future<TodoModel> createTodo({
    required String creatorId,
    required String creatorName,
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  }) async {
    try {
      // 1. 새 Todo 문서 참조 생성
      final docRef = _todosCollection.doc();

      // 2. TodoModel 생성
      final todoModel = TodoModel.create(
        id: docRef.id,
        creatorId: creatorId,
        creatorName: creatorName,
        title: title,
        description: description,
        category: category,
        dueDate: dueDate,
        dueTime: dueTime,
      );

      // 3. Firestore에 저장
      await docRef.set(todoModel.toFirestore());

      return todoModel;
    } on FirebaseException catch (e) {
      throw CreateTodoException.unknown(e.message);
    } catch (e) {
      if (e is TodoException) rethrow;
      throw CreateTodoException.unknown(e.toString());
    }
  }

  @override
  Future<TodoModel> updateTodo({
    required String todoId,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  }) async {
    try {
      // 1. 업데이트할 필드만 변경
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (dueDate != null) updateData['dueDate'] = Timestamp.fromDate(dueDate);
      if (dueTime != null) updateData['dueTime'] = dueTime;

      // 2. Firestore 업데이트 (문서가 없으면 FirebaseException 발생)
      final docRef = _todosCollection.doc(todoId);
      await docRef.update(updateData);

      // 3. 업데이트된 Todo 반환
      final doc = await docRef.get();
      if (!doc.exists) {
        throw UpdateTodoException.notFound();
      }

      return TodoModel.fromFirestore(doc);
    } on TodoException {
      rethrow;
    } on FirebaseException catch (e) {
      // NOT_FOUND 에러 코드 처리
      if (e.code == 'not-found') {
        throw UpdateTodoException.notFound();
      }
      throw UpdateTodoException.unknown(e.message);
    } catch (e) {
      if (e is TodoException) rethrow;
      throw UpdateTodoException.unknown(e.toString());
    }
  }

  @override
  Future<void> deleteTodo({required String todoId}) async {
    try {
      // Firestore에서 삭제 전 존재 확인
      final docRef = _todosCollection.doc(todoId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw DeleteTodoException.notFound();
      }

      await docRef.delete();
    } on TodoException {
      rethrow;
    } on FirebaseException catch (e) {
      throw DeleteTodoException.unknown(e.message);
    } catch (e) {
      if (e is TodoException) rethrow;
      throw DeleteTodoException.unknown(e.toString());
    }
  }

  @override
  Future<TodoModel> toggleComplete({
    required String todoId,
    required String? completedBy,
    required String? completedByName,
  }) async {
    try {
      // 1. 기존 Todo 조회
      final existing = await getTodo(todoId: todoId);
      if (existing == null) {
        throw UpdateTodoException.notFound();
      }

      // 2. 완료 상태 토글
      final newIsCompleted = !existing.isCompleted;
      final updatedModel = existing.copyWith(
        isCompleted: newIsCompleted,
        completedBy: newIsCompleted ? completedBy : null,
        completedByName: newIsCompleted ? completedByName : null,
        updatedAt: DateTime.now(),
      );

      // 3. Firestore 업데이트
      await _todosCollection.doc(todoId).update({
        'isCompleted': updatedModel.isCompleted,
        'completedBy': updatedModel.completedBy,
        'completedByName': updatedModel.completedByName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return updatedModel;
    } on TodoException {
      rethrow;
    } on FirebaseException catch (e) {
      throw UpdateTodoException.unknown(e.message);
    } catch (e) {
      if (e is TodoException) rethrow;
      throw UpdateTodoException.unknown(e.toString());
    }
  }

  @override
  Future<TodoModel?> getTodo({required String todoId}) async {
    try {
      final doc = await _todosCollection.doc(todoId).get();
      if (!doc.exists) {
        return null;
      }
      return TodoModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw GetTodoException.unknown(e.message);
    } catch (e) {
      if (e is TodoException) rethrow;
      throw GetTodoException.unknown(e.toString());
    }
  }

  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      final query = await _todosCollection
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => TodoModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw GetTodoException.unknown(e.message);
    } catch (e) {
      if (e is TodoException) rethrow;
      throw GetTodoException.unknown(e.toString());
    }
  }

  @override
  Stream<List<TodoModel>> watchTodos() {
    return _todosCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final todos = <TodoModel>[];
      for (final doc in snapshot.docs) {
        try {
          todos.add(TodoModel.fromFirestore(doc));
        } catch (e) {
          // 개별 문서 변환 실패 시 해당 문서 건너뛰기
          // 프로덕션에서는 적절한 로깅 프레임워크 사용 권장
        }
      }
      return todos;
    }).handleError((error) {
      // 스트림 에러 발생 시 예외로 변환
      if (error is FirebaseException) {
        throw GetTodoException.unknown(error.message);
      }
      throw GetTodoException.unknown(error.toString());
    });
  }

  @override
  Stream<List<TodoModel>> watchTodosByDate({required DateTime date}) {
    // 해당 날짜의 시작과 끝 시간 계산
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    // Note: Firestore 복합 쿼리 사용 시 인덱스 필요
    // 인덱스: /todos - dueDate ASC
    // dueTime은 null일 수 있으므로 orderBy에서 제외하고 클라이언트에서 정렬
    return _todosCollection
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) {
      final todos = <TodoModel>[];
      for (final doc in snapshot.docs) {
        try {
          todos.add(TodoModel.fromFirestore(doc));
        } catch (e) {
          // 개별 문서 변환 실패 시 해당 문서 건너뛰기
        }
      }
      // dueTime으로 클라이언트 측 정렬 (null은 마지막에 배치)
      todos.sort((a, b) {
        if (a.dueTime == null && b.dueTime == null) return 0;
        if (a.dueTime == null) return 1;
        if (b.dueTime == null) return -1;
        return a.dueTime!.compareTo(b.dueTime!);
      });
      return todos;
    }).handleError((error) {
      if (error is FirebaseException) {
        throw GetTodoException.unknown(error.message);
      }
      throw GetTodoException.unknown(error.toString());
    });
  }
}
