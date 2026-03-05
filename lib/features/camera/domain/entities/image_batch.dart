import 'package:equatable/equatable.dart';
import 'captured_image.dart';
import 'upload_status.dart';

/// A named collection of [CapturedImage]s that are treated as a single
/// upload unit. Each batch tracks its own [UploadStatus] independently.
class ImageBatch extends Equatable {
  final String id;
  final String batchName;
  final List<CapturedImage> images;
  final UploadStatus uploadStatus;
  final DateTime createdAt;

  /// Number of consecutive upload attempts. Reset to 0 on success.
  final int retryCount;

  /// The error message from the most recent failed upload attempt, if any.
  final String? lastErrorMessage;

  const ImageBatch({
    required this.id,
    required this.batchName,
    required this.images,
    required this.uploadStatus,
    required this.createdAt,
    this.retryCount = 0,
    this.lastErrorMessage,
  });

  ImageBatch copyWith({
    String? batchName,
    List<CapturedImage>? images,
    UploadStatus? uploadStatus,
    int? retryCount,
    String? lastErrorMessage,
    bool clearLastError = false,
  }) {
    return ImageBatch(
      id: id,
      batchName: batchName ?? this.batchName,
      images: images ?? this.images,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      createdAt: createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastErrorMessage:
          clearLastError ? null : (lastErrorMessage ?? this.lastErrorMessage),
    );
  }

  int get imageCount => images.length;

  bool get isPending => uploadStatus == UploadStatus.pending;

  bool get isUploading => uploadStatus == UploadStatus.uploading;

  bool get isUploaded => uploadStatus == UploadStatus.uploaded;

  bool get isFailed => uploadStatus == UploadStatus.failed;

  @override
  List<Object?> get props => [
        id,
        batchName,
        images,
        uploadStatus,
        createdAt,
        retryCount,
        lastErrorMessage,
      ];
}
