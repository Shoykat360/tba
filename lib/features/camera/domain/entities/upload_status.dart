/// Represents the lifecycle state of an [ImageBatch] upload.
enum UploadStatus {
  /// Captured and saved locally. Waiting for an upload attempt.
  pending,

  /// Currently being uploaded in this session.
  uploading,

  /// Successfully uploaded to the server.
  uploaded,

  /// Upload failed. Will be retried on next connectivity event.
  failed,
}
