import 'package:equatable/equatable.dart';

/// Represents a single image that has been captured and saved to local storage.
/// Pure Dart — no Flutter or platform imports.
class CapturedImage extends Equatable {
  final String id;

  /// Absolute path to the image file on the device's local storage.
  final String localFilePath;

  final DateTime capturedAt;

  const CapturedImage({
    required this.id,
    required this.localFilePath,
    required this.capturedAt,
  });

  @override
  List<Object?> get props => [id, localFilePath, capturedAt];
}
