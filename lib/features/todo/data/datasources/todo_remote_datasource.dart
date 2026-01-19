import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/exceptions/todo_exception.dart';
import '../models/todo_model.dart';

/// Todo Remote DataSource 인터페이스
///
/// Cloud Firestore를 사용하는 원격 데이터 소스의 추상 인터페이스입니다.
abstract interface class TodoRemoteDataSource {
  /// 새 Todo 생성
  Future<TodoModel> createTodo({
    required String coupleId,
    required String creatorId,
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  });

  /// Todo 업데이트
  Future<TodoModel> updateTodo({
    required String coupleId,
    required String todoId,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  });

  /// Todo 삭제
  Future<void> deleteTodo({
    required String coupleId,
    required String todoId,
  });

  /// Todo 완료 상태 토글
  Future<TodoModel> toggleComplete({
    required String coupleId,
    required String todoId,
    required String? completedBy,
  });

  /// Todo ID로 단일 Todo 조회
  Future<TodoModel?> getTodo({
    required String coupleId,
    required String todoId,
  });

  /// 커플의 모든 Todo 조회
  Future<List<TodoModel>> getTodos({required String coupleId});

  /// 커플의 Todo 실시간 스트림
  Stream<List<TodoModel>> watchTodos({required String coupleId});

  /// 특정 날짜의 Todo 실시간 스트림
  Stream<List<TodoModel>> watchTodosByDate({
    required String coupleId,
    required DateTime date,
  });
}

/// Todo Remote DataSource 구현체
///
/// Cloud Firestore를 사용하여 Todo 관련 작업을 수행합니다.
class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  TodoRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Firestore couples/{coupleId}/todos 컬렉션 참조
  CollectionReference<Map<String, dynamic>> _todosCollection(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('todos');

  @override
  Future<TodoModel> createTodo({
    required String coupleId,
    required String creatorId,
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  }) async {
    try {
      // 1. 새 Todo 문서 참조 생성
      final docRef = _todosCollection(coupleId).doc();

      // 2. TodoModel 생성
      final todoModel = TodoModel.create(
        id: docRef.id,
        coupleId: coupleId,
        creatorId: creatorId,
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
    required String coupleId,
    required String todoId,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  }) async {
    try {
      // 1. 기존 Todo 조회
      final existing = await getTodo(coupleId: coupleId, todoId: todoId);
      if (existing == null) {
        throw UpdateTodoException.notFound();
      }

      // 2. 업데이트할 필드만 변경
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (dueDate != null) updateData['dueDate'] = Timestamp.fromDate(dueDate);
      if (dueTime != null) updateData['dueTime'] = dueTime;

      // 3. Firestore 업데이트
      await _todosCollection(coupleId).doc(todoId).update(updateData);

      // 4. 업데이트된 Todo 반환
      final updated = await getTodo(coupleId: coupleId, todoId: todoId);
      if (updated == null) {
        throw UpdateTodoException.unknown('Failed to fetch updated todo');
      }

      return updated;
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
  Future<void> deleteTodo({
    required String coupleId,
    required String todoId,
  }) async {
    try {
      // 1. Todo 존재 확인
      final existing = await getTodo(coupleId: coupleId, todoId: todoId);
      if (existing == null) {
        throw DeleteTodoException.notFound();
      }

      // 2. Firestore에서 삭제
      await _todosCollection(coupleId).doc(todoId).delete();
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
    required String coupleId,
    required String todoId,
    required String? completedBy,
  }) async {
    try {
      // 1. 기존 Todo 조회
      final existing = await getTodo(coupleId: coupleId, todoId: todoId);
      if (existing == null) {
        throw UpdateTodoException.notFound();
      }

      // 2. 완료 상태 토글
      final updatedModel = existing.toggleComplete(completedBy);

      // 3. Firestore 업데이트
      await _todosCollection(coupleId).doc(todoId).update({
        'isCompleted': updatedModel.isCompleted,
        'completedBy': updatedModel.completedBy,
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
  Future<TodoModel?> getTodo({
    required String coupleId,
    required String todoId,
  }) async {
    try {
      final doc = await _todosCollection(coupleId).doc(todoId).get();
      if (!doc.exists) {
        return null;
      }
      return TodoModel.fromFirestore(doc, coupleId: coupleId);
    } on FirebaseException catch (e) {
      throw GetTodoException.unknown(e.message);
    }
  }

  @override
  Future<List<TodoModel>> getTodos({required String coupleId}) async {
    try {
      final query = await _todosCollection(coupleId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs
          .map((doc) => TodoModel.fromFirestore(doc, coupleId: coupleId))
          .toList();
    } on FirebaseException catch (e) {
      throw GetTodoException.unknown(e.message);
    }
  }

  @override
  Stream<List<TodoModel>> watchTodos({required String coupleId}) {
    return _todosCollection(coupleId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TodoModel.fromFirestore(doc, coupleId: coupleId))
            .toList());
  }

  @override
  Stream<List<TodoModel>> watchTodosByDate({
    required String coupleId,
    required DateTime date,
  }) {
    // 해당 날짜의 시작과 끝 시간 계산
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    return _todosCollection(coupleId)
        .where('dueDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('dueDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('dueDate')
        .orderBy('dueTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TodoModel.fromFirestore(doc, coupleId: coupleId))
            .toList());
  }
}
