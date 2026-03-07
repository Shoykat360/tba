import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../models/captured_image_model.dart';

abstract class CameraLocalDatasource {
  Future<List<CameraDescription>> getAvailableCameras();

  Future<CameraController> initializeCameraController(
      CameraDescription camera);

  Future<CapturedImageModel> captureAndSave(
      CameraController controller, String batchId);

  Future<double> getMinZoom(CameraController controller);

  Future<double> getMaxZoom(CameraController controller);
}

class CameraLocalDatasourceImpl implements CameraLocalDatasource {
  final Uuid uuid;

  CameraLocalDatasourceImpl({required this.uuid});

  @override
  Future<List<CameraDescription>> getAvailableCameras() async {
    try {
      return await availableCameras();
    } catch (e) {
      throw CameraHardwareException('Failed to get cameras: $e');
    }
  }

  @override
  Future<CameraController> initializeCameraController(
      CameraDescription camera) async {
    try {
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      return controller;
    } catch (e) {
      throw CameraHardwareException('Failed to initialize camera: $e');
    }
  }

  @override
  Future<CapturedImageModel> captureAndSave(
      CameraController controller, String batchId) async {
    try {
      final xFile = await controller.takePicture();

      // Store in app documents directory — no extra storage permissions needed
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/captured_images');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final imageId = uuid.v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destinationPath =
          '${imageDir.path}/${timestamp}_$imageId.jpg';

      // Copy from temp camera path to permanent location
      await File(xFile.path).copy(destinationPath);

      final savedFile = File(destinationPath);
      if (!await savedFile.exists()) {
        throw CameraHardwareException(
            'Image was not saved correctly at: $destinationPath');
      }

      final fileSizeBytes = await savedFile.length();
      debugPrint(
          '[CameraDS] 📸 Saved image ${imageId.substring(0, 8)} | '
          'size=${fileSizeBytes}b');

      // Clean up temp file created by camera plugin
      try {
        await File(xFile.path).delete();
      } catch (_) {}

      return CapturedImageModel(
        id: imageId,
        localPath: destinationPath,
        capturedAt: DateTime.now(),
        batchId: batchId,
      );
    } catch (e) {
      debugPrint('[CameraDS] ❌ captureAndSave error: $e');
      throw CameraHardwareException('Failed to capture image: $e');
    }
  }

  @override
  Future<double> getMinZoom(CameraController controller) async {
    return controller.getMinZoomLevel();
  }

  @override
  Future<double> getMaxZoom(CameraController controller) async {
    return controller.getMaxZoomLevel();
  }
}
