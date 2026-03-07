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
