import '../../domain/entities/image_batch.dart';
import '../../domain/entities/upload_status.dart';
import 'captured_image_model.dart';

class ImageBatchModel {
  final String id;
  final List<Map<String, dynamic>> imagesMap;
  final int uploadStatusIndex;
  final DateTime createdAt;
  final int retryCount;

  ImageBatchModel({
    required this.id,
    required this.imagesMap,
    required this.uploadStatusIndex,
    required this.createdAt,
    required this.retryCount,
  });

  factory ImageBatchModel.fromEntity(ImageBatch entity) {
    return ImageBatchModel(
      id: entity.id,
      imagesMap: entity.images
          .map((img) => CapturedImageModel.fromEntity(img).toMap())
          .toList(),
      uploadStatusIndex: entity.uploadStatus.index,
      createdAt: entity.createdAt,
      retryCount: entity.retryCount,
    );
  }

  ImageBatch toEntity() {
    return ImageBatch(
      id: id,
      images: imagesMap
          .map((m) => CapturedImageModel.fromMap(m).toEntity())
          .toList(),
      uploadStatus: UploadStatus.values[uploadStatusIndex],
      createdAt: createdAt,
      retryCount: retryCount,
    );
  }
}