import 'upload_status.dart';
import 'captured_image.dart';

class ImageBatch {
  final String id;
  final List<CapturedImage> images;
  final UploadStatus uploadStatus;
  final DateTime createdAt;
  final int retryCount;

  const ImageBatch({
    required this.id,
    required this.images,
    required this.uploadStatus,
    required this.createdAt,
    this.retryCount = 0,
  });

  ImageBatch copyWith({
    String? id,
    List<CapturedImage>? images,
    UploadStatus? uploadStatus,
    DateTime? createdAt,
    int? retryCount,
  }) {
    return ImageBatch(
      id: id ?? this.id,
      images: images ?? this.images,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  bool get isPending => uploadStatus == UploadStatus.pending;
  bool get isFailed => uploadStatus == UploadStatus.failed;
  bool get isUploaded => uploadStatus == UploadStatus.uploaded;
  bool get isUploading => uploadStatus == UploadStatus.uploading;
}
