/*
import 'package:hive/hive.dart';
import '../../domain/entities/captured_image.dart';

part 'captured_image_model.g.dart';

@HiveType(typeId: 10)
class CapturedImageModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String localPath;

  @HiveField(2)
  final DateTime capturedAt;

  @HiveField(3)
  final String batchId;

  CapturedImageModel({
    required this.id,
    required this.localPath,
    required this.capturedAt,
    required this.batchId,
  });

  factory CapturedImageModel.fromEntity(CapturedImage entity) {
    return CapturedImageModel(
      id: entity.id,
      localPath: entity.localPath,
      capturedAt: entity.capturedAt,
      batchId: entity.batchId,
    );
  }

  CapturedImage toEntity() {
    return CapturedImage(
      id: id,
      localPath: localPath,
      capturedAt: capturedAt,
      batchId: batchId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'localPath': localPath,
      'capturedAt': capturedAt.toIso8601String(),
      'batchId': batchId,
    };
  }

  factory CapturedImageModel.fromMap(Map<String, dynamic> map) {
    return CapturedImageModel(
      id: map['id'],
      localPath: map['localPath'],
      capturedAt: DateTime.parse(map['capturedAt']),
      batchId: map['batchId'],
    );
  }
}
*/


import '../../domain/entities/captured_image.dart';

class CapturedImageModel {
  final String id;
  final String localPath;
  final DateTime capturedAt;
  final String batchId;

  CapturedImageModel({
    required this.id,
    required this.localPath,
    required this.capturedAt,
    required this.batchId,
  });

  factory CapturedImageModel.fromEntity(CapturedImage entity) {
    return CapturedImageModel(
      id: entity.id,
      localPath: entity.localPath,
      capturedAt: entity.capturedAt,
      batchId: entity.batchId,
    );
  }

  CapturedImage toEntity() {
    return CapturedImage(
      id: id,
      localPath: localPath,
      capturedAt: capturedAt,
      batchId: batchId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'localPath': localPath,
      'capturedAt': capturedAt.toIso8601String(),
      'batchId': batchId,
    };
  }

  factory CapturedImageModel.fromMap(Map<String, dynamic> map) {
    return CapturedImageModel(
      id: map['id'],
      localPath: map['localPath'],
      capturedAt: DateTime.parse(map['capturedAt']),
      batchId: map['batchId'],
    );
  }
}