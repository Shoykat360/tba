/*
import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/camera_configuration.dart';
import '../../domain/entities/captured_image.dart';
import '../../domain/repositories/camera_repository.dart';
import '../datasources/camera_local_datasource.dart';

class CameraRepositoryImpl implements CameraRepository {
  final CameraLocalDatasource _cameraLocalDatasource;
  final Uuid _uuid;

  /// The active [CameraController] is held here so all subsequent calls
  /// (zoom, focus, capture) reuse the same initialised controller.
  CameraController? _activeCameraController;

  CameraRepositoryImpl({
    required CameraLocalDatasource cameraLocalDatasource,
    required Uuid uuid,
  })  : _cameraLocalDatasource = cameraLocalDatasource,
        _uuid = uuid;

  @override
  Future<Either<Failure, CameraConfiguration>> initializeCamera() async {
    try {
      final CameraController controller =
          await _cameraLocalDatasource.initializeCameraController();

      _activeCameraController = controller;

      final double minZoom =
          await _cameraLocalDatasource.fetchMinimumZoomLevel(controller);
      final double maxZoom =
          await _cameraLocalDatasource.fetchMaximumZoomLevel(controller);
      final List<double> presets =
          await _cameraLocalDatasource.fetchAvailablePresetZoomLevels(
        controller,
      );

      return Right(
        CameraConfiguration(
          currentZoomLevel: minZoom,
          minZoomLevel: minZoom,
          maxZoomLevel: maxZoom,
          availablePresetZoomLevels: presets,
        ),
      );
    } on CameraPermissionDeniedException {
      return const Left(CameraPermissionDeniedFailure());
    } on CameraPermissionPermanentlyDeniedException {
      return const Left(CameraPermissionPermanentlyDeniedFailure());
    } on CameraHardwareUnavailableException {
      return const Left(CameraHardwareUnavailableFailure());
    } on CameraInitializationException catch (e) {
      return Left(CameraInitializationFailure(message: e.message));
    } catch (e) {
      return Left(
        CameraInitializationFailure(
          message: 'Unexpected camera init error: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateZoomLevel(double zoomLevel) async {
    final CameraController? controller = _activeCameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Left(
        CameraInitializationFailure(
          message: 'Camera is not initialised. Call initializeCamera first.',
        ),
      );
    }

    try {
      await _cameraLocalDatasource.applyZoomLevel(
        controller: controller,
        zoomLevel: zoomLevel,
      );
      return const Right(null);
    } on CameraInitializationException catch (e) {
      return Left(CameraInitializationFailure(message: e.message));
    } catch (e) {
      return Left(
        CameraInitializationFailure(
          message: 'Failed to update zoom: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> setManualFocusPoint({
    required double x,
    required double y,
  }) async {
    final CameraController? controller = _activeCameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Left(
        CameraInitializationFailure(
          message: 'Camera is not initialised. Call initializeCamera first.',
        ),
      );
    }

    try {
      await _cameraLocalDatasource.applyManualFocusPoint(
        controller: controller,
        x: x,
        y: y,
      );
      return const Right(null);
    } on CameraInitializationException catch (e) {
      return Left(CameraInitializationFailure(message: e.message));
    } catch (e) {
      return Left(
        CameraInitializationFailure(
          message: 'Failed to set focus: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, CapturedImage>> captureImageAndStoreLocally() async {
    final CameraController? controller = _activeCameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Left(
        CaptureFailure(
          message: 'Camera is not initialised. Cannot capture image.',
        ),
      );
    }

    try {
      final model = await _cameraLocalDatasource.takePictureAndSaveLocally(
        controller: controller,
        imageId: _uuid.v4(),
      );
      return Right(model.toEntity());
    } on CaptureException catch (e) {
      return Left(CaptureFailure(message: e.message));
    } catch (e) {
      return Left(
        CaptureFailure(message: 'Capture failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, double>> fetchMinimumZoomLevel() async {
    final CameraController? controller = _activeCameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Right(1.0);
    }
    try {
      final double min =
          await _cameraLocalDatasource.fetchMinimumZoomLevel(controller);
      return Right(min);
    } on CameraInitializationException catch (e) {
      return Left(CameraInitializationFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, double>> fetchMaximumZoomLevel() async {
    final CameraController? controller = _activeCameraController;
    if (controller == null || !controller.value.isInitialized) {
      return const Right(8.0);
    }
    try {
      final double max =
          await _cameraLocalDatasource.fetchMaximumZoomLevel(controller);
      return Right(max);
    } on CameraInitializationException catch (e) {
      return Left(CameraInitializationFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> disposeCamera() async {
    final CameraController? controller = _activeCameraController;
    if (controller == null) return const Right(null);

    try {
      await _cameraLocalDatasource.disposeCameraController(controller);
      _activeCameraController = null;
      return const Right(null);
    } catch (e) {
      return Left(
        CameraInitializationFailure(
          message: 'Error disposing camera: ${e.toString()}',
        ),
      );
    }
  }

  /// Exposes the raw controller so the presentation layer can pass it to
  /// [CameraPreview] widget. Returns null if camera is not yet initialised.
  CameraController? get activeCameraController => _activeCameraController;
}
*/


