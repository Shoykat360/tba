import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/camera_configuration.dart';
import '../entities/captured_image.dart';

/// Defines the contract for all camera hardware operations.
/// All I/O and platform-specific details are in the data layer.
abstract class CameraRepository {
  /// Checks camera permissions, initialises the camera controller, and returns
  /// the initial [CameraConfiguration] reflecting hardware capabilities.
  Future<Either<Failure, CameraConfiguration>> initializeCamera();

  /// Updates the active zoom level on the camera hardware.
  Future<Either<Failure, void>> updateZoomLevel(double zoomLevel);

  /// Points the camera's auto-focus system at the given normalised offset.
  /// [x] and [y] are in the range 0.0–1.0 relative to the preview frame.
  Future<Either<Failure, void>> setManualFocusPoint({
    required double x,
    required double y,
  });

  /// Captures a still image and saves it to local storage.
  /// Returns the [CapturedImage] entity with the persisted file path.
  Future<Either<Failure, CapturedImage>> captureImageAndStoreLocally();

  /// Retrieves the minimum supported zoom level from the camera hardware.
  Future<Either<Failure, double>> fetchMinimumZoomLevel();

  /// Retrieves the maximum supported zoom level from the camera hardware.
  Future<Either<Failure, double>> fetchMaximumZoomLevel();

  /// Releases the camera controller and frees hardware resources.
  Future<Either<Failure, void>> disposeCamera();
}
