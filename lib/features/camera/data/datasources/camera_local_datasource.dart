/*
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/captured_image_model.dart';
import 'package:flutter/material.dart';
abstract class CameraLocalDatasource {
  /// Requests camera permission, discovers available cameras, and initialises
  /// the rear-facing [CameraController]. Returns the controller on success.
  Future<CameraController> initializeCameraController();

  /// Updates the camera controller's zoom level.
  Future<void> applyZoomLevel({
    required CameraController controller,
    required double zoomLevel,
  });

  /// Instructs the camera to focus at the given normalised point.
  Future<void> applyManualFocusPoint({
    required CameraController controller,
    required double x,
    required double y,
  });

  /// Takes a picture, saves it to the app's documents directory, and returns
  /// the model with the persisted local file path.
  Future<CapturedImageModel> takePictureAndSaveLocally({
    required CameraController controller,
    required String imageId,
  });

  /// Returns the minimum zoom level supported by the active camera.
  Future<double> fetchMinimumZoomLevel(CameraController controller);

  /// Returns the maximum zoom level supported by the active camera.
  Future<double> fetchMaximumZoomLevel(CameraController controller);

  /// Returns the zoom level preset values derived from available camera lenses.
  Future<List<double>> fetchAvailablePresetZoomLevels(
    CameraController controller,
  );

  /// Disposes the controller and releases camera hardware.
  Future<void> disposeCameraController(CameraController controller);
}

class CameraLocalDatasourceImpl implements CameraLocalDatasource {
  const CameraLocalDatasourceImpl();

  @override
  Future<CameraController> initializeCameraController() async {
    await _requestCameraPermission();

    final List<CameraDescription> cameras = await availableCameras();

    if (cameras.isEmpty) {
      throw const CameraHardwareUnavailableException();
    }

    // Prefer the first back camera; fall back to the first available camera.
    final CameraDescription selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final CameraController controller = CameraController(
      selectedCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      return controller;
    } on CameraException catch (e) {
      throw CameraInitializationException(
        message: 'Camera initialization failed: ${e.description ?? e.code}',
      );
    } catch (e) {
      throw CameraInitializationException(
        message: 'Unexpected error during camera init: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> applyZoomLevel({
    required CameraController controller,
    required double zoomLevel,
  }) async {
    try {
      await controller.setZoomLevel(zoomLevel);
    } on CameraException catch (e) {
      throw CameraInitializationException(
        message: 'Failed to set zoom level: ${e.description ?? e.code}',
      );
    }
  }

  @override
  Future<void> applyManualFocusPoint({
    required CameraController controller,
    required double x,
    required double y,
  }) async {
    try {
      final Offset focusOffset = Offset(x, y);
      await controller.setFocusPoint(focusOffset);
      await controller.setFocusMode(FocusMode.locked);
    } on CameraException catch (e) {
      throw CameraInitializationException(
        message: 'Failed to set focus point: ${e.description ?? e.code}',
      );
    }
  }

  @override
  Future<CapturedImageModel> takePictureAndSaveLocally({
    required CameraController controller,
    required String imageId,
  }) async {
    try {
      final XFile rawFile = await controller.takePicture();

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String capturedImagesPath =
          '${appDocDir.path}/${AppConstants.capturedImagesDirName}';
      final Directory capturedImagesDir = Directory(capturedImagesPath);

      if (!capturedImagesDir.existsSync()) {
        await capturedImagesDir.create(recursive: true);
      }

      final String destinationPath = '$capturedImagesPath/$imageId.jpg';
      await File(rawFile.path).copy(destinationPath);

      return CapturedImageModel(
        id: imageId,
        localFilePath: destinationPath,
        capturedAt: DateTime.now(),
      );
    } on CameraException catch (e) {
      throw CaptureException(
        message: 'Failed to capture image: ${e.description ?? e.code}',
      );
    } catch (e) {
      throw CaptureException(
        message: 'Unexpected error during capture: ${e.toString()}',
      );
    }
  }

  @override
  Future<double> fetchMinimumZoomLevel(CameraController controller) async {
    try {
      return await controller.getMinZoomLevel();
    } on CameraException catch (e) {
      throw CameraInitializationException(
        message: 'Failed to fetch min zoom: ${e.description ?? e.code}',
      );
    }
  }

  @override
  Future<double> fetchMaximumZoomLevel(CameraController controller) async {
    try {
      return await controller.getMaxZoomLevel();
    } on CameraException catch (e) {
      throw CameraInitializationException(
        message: 'Failed to fetch max zoom: ${e.description ?? e.code}',
      );
    }
  }

  @override
  Future<List<double>> fetchAvailablePresetZoomLevels(
    CameraController controller,
  ) async {
    final double minZoom = await fetchMinimumZoomLevel(controller);
    final double maxZoom = await fetchMaximumZoomLevel(controller);

    // Build discrete preset steps based on the available zoom range.
    final List<double> presets = <double>[];

    const List<double> candidatePresets = [0.5, 1.0, 2.0, 3.0, 5.0];
    for (final double candidate in candidatePresets) {
      if (candidate >= minZoom && candidate <= maxZoom) {
        presets.add(candidate);
      }
    }

    // Always include at least the minimum zoom level.
    if (presets.isEmpty) {
      presets.add(minZoom);
    }

    return presets;
  }

  @override
  Future<void> disposeCameraController(CameraController controller) async {
    if (controller.value.isInitialized) {
      await controller.dispose();
    }
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  Future<void> _requestCameraPermission() async {
    final PermissionStatus status = await Permission.camera.status;

    if (status.isDenied) {
      final PermissionStatus requested = await Permission.camera.request();
      if (requested.isDenied) {
        throw const CameraPermissionDeniedException();
      }
      if (requested.isPermanentlyDenied) {
        throw const CameraPermissionPermanentlyDeniedException();
      }
    }

    if (status.isPermanentlyDenied) {
      throw const CameraPermissionPermanentlyDeniedException();
    }
  }
}
*/


