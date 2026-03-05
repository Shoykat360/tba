/*import '../../domain/entities/captured_image.dart';

/// JSON-serializable data model for [CapturedImage].
/// Stored as part of [ImageBatchModel] in Hive [Box<String>].
class CapturedImageModel {
  final String id;
  final String localFilePath;
  final DateTime capturedAt;

  const CapturedImageModel({
    required this.id,
    required this.localFilePath,
    required this.capturedAt,
  });

  factory CapturedImageModel.fromEntity(CapturedImage entity) {
    return CapturedImageModel(
      id: entity.id,
      localFilePath: entity.localFilePath,
      capturedAt: entity.capturedAt,
    );
  }

  CapturedImage toEntity() {
    return CapturedImage(
      id: id,
      localFilePath: localFilePath,
      capturedAt: capturedAt,
    );
  }

  factory CapturedImageModel.fromMap(Map<String, dynamic> map) {
    return CapturedImageModel(
      id: map['id'] as String,
      localFilePath: map['localFilePath'] as String,
      capturedAt: DateTime.parse(map['capturedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'localFilePath': localFilePath,
      'capturedAt': capturedAt.toIso8601String(),
    };
  }
}*/


