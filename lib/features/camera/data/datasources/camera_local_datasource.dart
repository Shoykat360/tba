import 'dart:io';
import 'package:camera/camera.dart' hide CameraException;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../models/captured_image_model.dart';

abstract class CameraLocalDatasource {
  Future<List<CameraDescription>> getAvailableCameras();
  Future<CameraController> initializeCameraController(CameraDescription camera);
  Future<CapturedImageModel> captureAndSave(CameraController controller, String batchId);
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
      throw CameraException('Failed to get cameras: $e');
    }
  }

  @override
  Future<CameraController> initializeCameraController(CameraDescription camera) async {
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
      throw CameraException('Failed to initialize camera: $e');
    }
  }

  @override
  Future<CapturedImageModel> captureAndSave(
      CameraController controller, String batchId) async {
    try {
      final xFile = await controller.takePicture();
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory('${appDir.path}/captured_images');
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }
      final imageId = uuid.v4();
      final destPath = '${imageDir.path}/$imageId.jpg';
      await File(xFile.path).copy(destPath);

      return CapturedImageModel(
        id: imageId,
        localPath: destPath,
        capturedAt: DateTime.now(),
        batchId: batchId,
      );
    } catch (e) {
      throw CameraException('Failed to capture image: $e');
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
