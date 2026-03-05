/*
import '../../domain/entities/image_batch.dart';
import '../../domain/entities/upload_status.dart';
import 'captured_image_model.dart';

/// JSON-serializable data model for [ImageBatch].
/// Stored as a JSON-encoded string in Hive [Box<String>].
class ImageBatchModel {
  final String id;
  final String batchName;
  final List<CapturedImageModel> images;
  final String uploadStatusRaw;
  final DateTime createdAt;
  final int retryCount;
  final String? lastErrorMessage;

  const ImageBatchModel({
    required this.id,
    required this.batchName,
    required this.images,
    required this.uploadStatusRaw,
    required this.createdAt,
    required this.retryCount,
    this.lastErrorMessage,
  });

  factory ImageBatchModel.fromEntity(ImageBatch entity) {
    return ImageBatchModel(
      id: entity.id,
      batchName: entity.batchName,
      images: entity.images
          .map(CapturedImageModel.fromEntity)
          .toList(),
      uploadStatusRaw: _uploadStatusToString(entity.uploadStatus),
      createdAt: entity.createdAt,
      retryCount: entity.retryCount,
      lastErrorMessage: entity.lastErrorMessage,
    );
  }

  ImageBatch toEntity() {
    return ImageBatch(
      id: id,
      batchName: batchName,
      images: images.map((m) => m.toEntity()).toList(),
      uploadStatus: _uploadStatusFromString(uploadStatusRaw),
      createdAt: createdAt,
      retryCount: retryCount,
      lastErrorMessage: lastErrorMessage,
    );
  }

  factory ImageBatchModel.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawImages = map['images'] as List<dynamic>;
    return ImageBatchModel(
      id: map['id'] as String,
      batchName: map['batchName'] as String,
      images: rawImages
          .map((e) => CapturedImageModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      uploadStatusRaw: map['uploadStatus'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      retryCount: (map['retryCount'] as num).toInt(),
      lastErrorMessage: map['lastErrorMessage'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batchName': batchName,
      'images': images.map((m) => m.toMap()).toList(),
      'uploadStatus': uploadStatusRaw,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'lastErrorMessage': lastErrorMessage,
    };
  }

  static String _uploadStatusToString(UploadStatus status) {
    switch (status) {
      case UploadStatus.pending:
        return 'pending';
      case UploadStatus.uploading:
        return 'uploading';
      case UploadStatus.uploaded:
        return 'uploaded';
      case UploadStatus.failed:
        return 'failed';
    }
  }

  static UploadStatus _uploadStatusFromString(String raw) {
    switch (raw) {
      case 'uploading':
        // On app restart, any batch stuck in 'uploading' is reset to 'pending'
        // because the upload was interrupted and must be retried.
        return UploadStatus.pending;
      case 'uploaded':
        return UploadStatus.uploaded;
      case 'failed':
        return UploadStatus.failed;
      case 'pending':
      default:
        return UploadStatus.pending;
    }
  }
}
*/


