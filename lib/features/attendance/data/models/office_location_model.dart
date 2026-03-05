/*
import '../../domain/entities/office_location.dart';

/// Data model for [OfficeLocation].
///
/// Serializes to/from a plain Map for JSON encoding into Hive [Box<String>].
/// No Hive type adapters or code generation are needed since we store
/// all data as JSON strings — not native Hive objects.
class OfficeLocationModel {
  final double latitude;
  final double longitude;
  final DateTime savedAt;

  const OfficeLocationModel({
    required this.latitude,
    required this.longitude,
    required this.savedAt,
  });

  factory OfficeLocationModel.fromEntity(OfficeLocation entity) {
    return OfficeLocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      savedAt: entity.savedAt,
    );
  }

  OfficeLocation toEntity() {
    return OfficeLocation(
      latitude: latitude,
      longitude: longitude,
      savedAt: savedAt,
    );
  }

  factory OfficeLocationModel.fromMap(Map<String, dynamic> map) {
    return OfficeLocationModel(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      savedAt: DateTime.parse(map['savedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'savedAt': savedAt.toIso8601String(),
    };
  }
}
*/


import '../../domain/entities/office_location.dart';

class OfficeLocationModel extends OfficeLocation {
  const OfficeLocationModel({
    required super.latitude,
    required super.longitude,
    required super.savedAt,
  });

  factory OfficeLocationModel.fromJson(Map<String, dynamic> json) {
    return OfficeLocationModel(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'savedAt': savedAt.toIso8601String(),
  };

  factory OfficeLocationModel.fromEntity(OfficeLocation entity) {
    return OfficeLocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      savedAt: entity.savedAt,
    );
  }
}