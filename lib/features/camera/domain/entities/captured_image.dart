class CapturedImage {
  final String id;
  final String localPath;
  final DateTime capturedAt;
  final String batchId;

  const CapturedImage({
    required this.id,
    required this.localPath,
    required this.capturedAt,
    required this.batchId,
  });
}
