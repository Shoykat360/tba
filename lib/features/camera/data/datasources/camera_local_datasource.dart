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

      // Use app documents directory — no storage permissions needed
      // This directory persists even when app is backgrounded/killed
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/captured_images');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // Unique filename with timestamp prevents collisions
      final imageId = uuid.v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destPath = '${imageDir.path}/${timestamp}_$imageId.jpg';

      // Copy to permanent location — temp xFile path may be cleared by OS
      await File(xFile.path).copy(destPath);

      // Verify file was written successfully before recording in DB
      final savedFile = File(destPath);
      if (!await savedFile.exists()) {
        throw CameraHardwareException('Image file not saved correctly: $destPath');
      }

      final fileSize = await savedFile.length();
      debugPrint('[CameraDS] 📸 Saved: ${imageId.substring(0, 8)}… | size=${fileSize}b | path=$destPath');

      // Clean up temp camera file
      try {
        await File(xFile.path).delete();
      } catch (_) {}

      return CapturedImageModel(
        id: imageId,
        localPath: destPath,
        capturedAt: DateTime.now(),
        batchId: batchId,
      );
    } catch (e) {
      debugPrint('[CameraDS] ❌ captureAndSave failed: $e');
      throw CameraHardwareException('Failed to capture image: $e');
    }
  }

  @override
  Future<double> getMinZoom(CameraController controller) async {
    return await controller.getMinZoomLevel();
  }

  @override
  Future<double> getMaxZoom(CameraController controller) async {
    return await controller.getMaxZoomLevel();
  }
}
