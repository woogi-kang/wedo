import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// User 데이터 모델
///
/// Firestore 문서와 도메인 엔티티 간의 데이터 변환을 담당합니다.
/// json_serializable을 사용하여 JSON 직렬화/역직렬화를 자동 생성합니다.
///
/// Firestore 구조:
/// ```
/// /users/{userId}
///   - uid: string
///   - email: string
///   - displayName: string
///   - coupleId: string?
///   - partnerId: string?
///   - fcmToken: string?
///   - createdAt: timestamp
///   - updatedAt: timestamp
/// ```
@JsonSerializable()
class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.coupleId,
    this.partnerId,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String email;
  final String displayName;
  final String? coupleId;
  final String? partnerId;
  final String? fcmToken;

  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;

  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime updatedAt;

  /// JSON에서 UserModel 생성
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// UserModel을 JSON으로 변환
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Firestore DocumentSnapshot에서 UserModel 생성
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }
    return UserModel.fromJson(data);
  }

  /// UserModel을 Firestore 저장용 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'coupleId': coupleId,
      'partnerId': partnerId,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Domain Entity에서 UserModel 생성
  factory UserModel.fromEntity(User entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      coupleId: entity.coupleId,
      partnerId: entity.partnerId,
      fcmToken: entity.fcmToken,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// UserModel을 Domain Entity로 변환
  User toEntity() {
    return User(
      uid: uid,
      email: email,
      displayName: displayName,
      coupleId: coupleId,
      partnerId: partnerId,
      fcmToken: fcmToken,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// 새 사용자 생성용 팩토리
  factory UserModel.create({
    required String uid,
    required String email,
    required String displayName,
  }) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// copyWith 메서드
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? coupleId,
    String? partnerId,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      coupleId: coupleId ?? this.coupleId,
      partnerId: partnerId ?? this.partnerId,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
