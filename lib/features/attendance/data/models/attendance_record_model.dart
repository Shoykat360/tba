/*
import '../../domain/entities/attendance_record.dart';

/// Data model for [AttendanceRecord].
///
/// Serializes to/from a plain Map for JSON encoding into Hive [Box<String>].
/// No Hive type adapters or code generation are needed since we store
/// all data as JSON strings — not native Hive objects.
class AttendanceRecordModel {
  final String id;
  final DateTime markedAt;
  final double latitude;
  final double longitude;
  final double distanceFromOfficeInMeters;

  const AttendanceRecordModel({
    required this.id,
    required this.markedAt,
    required this.latitude,
    required this.longitude,
    required this.distanceFromOfficeInMeters,
  });

  factory AttendanceRecordModel.fromEntity(AttendanceRecord entity) {
    return AttendanceRecordModel(
      id: entity.id,
      markedAt: entity.markedAt,
      latitude: entity.latitude,
      longitude: entity.longitude,
      distanceFromOfficeInMeters: entity.distanceFromOfficeInMeters,
    );
  }

  AttendanceRecord toEntity() {
    return AttendanceRecord(
      id: id,
      markedAt: markedAt,
      latitude: latitude,
      longitude: longitude,
      distanceFromOfficeInMeters: distanceFromOfficeInMeters,
    );
  }

  factory AttendanceRecordModel.fromMap(Map<String, dynamic> map) {
    return AttendanceRecordModel(
      id: map['id'] as String,
      markedAt: DateTime.parse(map['markedAt'] as String),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      distanceFromOfficeInMeters:
          (map['distanceFromOfficeInMeters'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'markedAt': markedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'distanceFromOfficeInMeters': distanceFromOfficeInMeters,
    };
  }
}
*/
import '../../domain/entities/attendance_record.dart';

class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.id,
    required super.latitude,
    required super.longitude,
    required super.markedAt,
    required super.distanceFromOffice,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      markedAt: DateTime.parse(json['markedAt'] as String),
      distanceFromOffice: json['distanceFromOffice'] as double,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'latitude': latitude,
    'longitude': longitude,
    'markedAt': markedAt.toIso8601String(),
    'distanceFromOffice': distanceFromOffice,
  };

  factory AttendanceRecordModel.fromEntity(AttendanceRecord entity) {
    return AttendanceRecordModel(
      id: entity.id,
      latitude: entity.latitude,
      longitude: entity.longitude,
      markedAt: entity.markedAt,
      distanceFromOffice: entity.distanceFromOffice,
    );
  }
}