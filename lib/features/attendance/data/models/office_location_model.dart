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
