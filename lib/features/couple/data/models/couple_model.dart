import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/couple.dart';

part 'couple_model.g.dart';

/// Couple 데이터 모델
///
/// Firestore 문서와 도메인 엔티티 간의 데이터 변환을 담당합니다.
/// json_serializable을 사용하여 JSON 직렬화/역직렬화를 자동 생성합니다.
///
/// Firestore 구조:
/// ```
/// /couples/{coupleId}
///   - id: string
///   - inviteCode: string (unique, 6 chars)
///   - members: array<string> (userId list, max 2)
///   - createdAt: timestamp
///   - connectedAt: timestamp? (null until both joined)
/// ```
@JsonSerializable()
class CoupleModel {
  const CoupleModel({
    required this.id,
    required this.inviteCode,
    required this.members,
    required this.createdAt,
    this.connectedAt,
  });

  final String id;
  final String inviteCode;
  final List<String> members;

  @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
  final DateTime createdAt;

  @JsonKey(fromJson: _nullableDateTimeFromTimestamp, toJson: _nullableDateTimeToTimestamp)
  final DateTime? connectedAt;

  /// JSON에서 CoupleModel 생성
  factory CoupleModel.fromJson(Map<String, dynamic> json) =>
      _$CoupleModelFromJson(json);

  /// CoupleModel을 JSON으로 변환
  Map<String, dynamic> toJson() => _$CoupleModelToJson(this);

  /// Firestore DocumentSnapshot에서 CoupleModel 생성
  factory CoupleModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }
    // Firestore에서 id는 문서 ID를 사용
    return CoupleModel.fromJson({...data, 'id': doc.id});
  }

  /// CoupleModel을 Firestore 저장용 Map으로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'inviteCode': inviteCode,
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
      'connectedAt': connectedAt != null ? Timestamp.fromDate(connectedAt!) : null,
    };
  }

  /// Domain Entity에서 CoupleModel 생성
  factory CoupleModel.fromEntity(Couple entity) {
    return CoupleModel(
      id: entity.id,
      inviteCode: entity.inviteCode,
      members: entity.members,
      createdAt: entity.createdAt,
      connectedAt: entity.connectedAt,
    );
  }

  /// CoupleModel을 Domain Entity로 변환
  Couple toEntity() {
    return Couple(
      id: id,
      inviteCode: inviteCode,
      members: List<String>.from(members),
      createdAt: createdAt,
      connectedAt: connectedAt,
    );
  }

  /// 새 커플 생성용 팩토리
  factory CoupleModel.create({
    required String id,
    required String inviteCode,
    required String creatorUserId,
  }) {
    final now = DateTime.now();
    return CoupleModel(
      id: id,
      inviteCode: inviteCode,
      members: [creatorUserId],
      createdAt: now,
      connectedAt: null,
    );
  }

  /// copyWith 메서드
  CoupleModel copyWith({
    String? id,
    String? inviteCode,
    List<String>? members,
    DateTime? createdAt,
    DateTime? connectedAt,
  }) {
    return CoupleModel(
      id: id ?? this.id,
      inviteCode: inviteCode ?? this.inviteCode,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }

  /// 파트너 추가 (커플 합류 시 사용)
  CoupleModel addPartner(String partnerId) {
    if (members.length >= 2) {
      throw Exception('Couple already has 2 members');
    }
    return copyWith(
      members: [...members, partnerId],
      connectedAt: DateTime.now(),
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
