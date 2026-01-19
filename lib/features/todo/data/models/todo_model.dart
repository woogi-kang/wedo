import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/todo.dart';

part 'todo_model.g.dart';

/// Todo 데이터 모델
///
/// Firestore 문서와 도메인 엔티티 간의 데이터 변환을 담당합니다.
/// json_serializable을 사용하여 JSON 직렬화/역직렬화를 자동 생성합니다.
///
/// Firestore 구조:
/// ```
/// /couples/{coupleId}/todos/{todoId}
///   - id: string
///   - coupleId: string
///   - creatorId: string
///   - title: string
///   - description: string?
///   - category: string?
///   - dueDate: timestamp?
///   - dueTime: string? ("HH:mm" format)
///   - isCompleted: boolean
///   - completedBy: string?
///   - createdAt: timestamp
///   - updatedAt: timestamp
/// ```
@JsonSerializable()
class TodoModel {
  const TodoModel({
    required this.id,
    required this.coupleId,
    required this.creatorId,
    required this.title,
    this.description,
    this.category,
    this.dueDate,
    this.dueTime,
    required this.isCompleted,
    this.completedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String coupleId;
  final String creatorId;
  final String title;
  final String? description;
  final String? category;

  @JsonKey(fromJson: _nullableDateTimeFromTimestamp, toJson: _nullableDateTimeToTimestamp)
  final DateTime? dueDate;

  final String? dueTime;
  final bool isCompleted;
  final String? completedBy;

  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;

  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime updatedAt;

  /// JSON에서 TodoModel 생성
  factory TodoModel.fromJson(Map<String, dynamic> json) =>
      _$TodoModelFromJson(json);

  /// TodoModel을 JSON으로 변환
  Map<String, dynamic> toJson() => _$TodoModelToJson(this);

  /// Firestore DocumentSnapshot에서 TodoModel 생성
  factory TodoModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String coupleId,
  }) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }
    // Firestore에서 id는 문서 ID를 사용
    return TodoModel.fromJson({...data, 'id': doc.id, 'coupleId': coupleId});
  }

  /// TodoModel을 Firestore 저장용 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'coupleId': coupleId,
      'creatorId': creatorId,
      'title': title,
      'description': description,
      'category': category,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'dueTime': dueTime,
      'isCompleted': isCompleted,
      'completedBy': completedBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Domain Entity에서 TodoModel 생성
  factory TodoModel.fromEntity(Todo entity) {
    return TodoModel(
      id: entity.id,
      coupleId: entity.coupleId,
      creatorId: entity.creatorId,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      dueDate: entity.dueDate,
      dueTime: entity.dueTime,
      isCompleted: entity.isCompleted,
      completedBy: entity.completedBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// TodoModel을 Domain Entity로 변환
  Todo toEntity() {
    return Todo(
      id: id,
      coupleId: coupleId,
      creatorId: creatorId,
      title: title,
      description: description,
      category: category,
      dueDate: dueDate,
      dueTime: dueTime,
      isCompleted: isCompleted,
      completedBy: completedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// 새 Todo 생성용 팩토리
  factory TodoModel.create({
    required String id,
    required String coupleId,
    required String creatorId,
    required String title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
  }) {
    final now = DateTime.now();
    return TodoModel(
      id: id,
      coupleId: coupleId,
      creatorId: creatorId,
      title: title,
      description: description,
      category: category,
      dueDate: dueDate,
      dueTime: dueTime,
      isCompleted: false,
      completedBy: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// copyWith 메서드
  TodoModel copyWith({
    String? id,
    String? coupleId,
    String? creatorId,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? dueTime,
    bool? isCompleted,
    String? completedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      coupleId: coupleId ?? this.coupleId,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedBy: completedBy ?? this.completedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 완료 상태 토글
  TodoModel toggleComplete(String? userId) {
    final newIsCompleted = !isCompleted;
    return copyWith(
      isCompleted: newIsCompleted,
      completedBy: newIsCompleted ? userId : null,
      updatedAt: DateTime.now(),
    );
  }
}

/// Firestore Timestamp를 DateTime으로 변환
DateTime _dateTimeFromTimestamp(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  } else if (value is DateTime) {
    return value;
  } else if (value is String) {
    return DateTime.parse(value);
  }
  throw ArgumentError('Invalid timestamp format: $value');
}

/// DateTime을 Firestore Timestamp로 변환
dynamic _dateTimeToTimestamp(DateTime dateTime) {
  return Timestamp.fromDate(dateTime);
}

/// Nullable Firestore Timestamp를 DateTime으로 변환
DateTime? _nullableDateTimeFromTimestamp(dynamic value) {
  if (value == null) return null;
  return _dateTimeFromTimestamp(value);
}

/// Nullable DateTime을 Firestore Timestamp로 변환
dynamic _nullableDateTimeToTimestamp(DateTime? dateTime) {
  if (dateTime == null) return null;
  return Timestamp.fromDate(dateTime);
}
