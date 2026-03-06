import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/camera_repository.dart';

class SetCameraZoomLevelParams {
  final CameraController controller;
  final double zoom;
  SetCameraZoomLevelParams({required this.controller, required this.zoom});
}

class SetCameraZoomLevel {
  final CameraRepository repository;
  SetCameraZoomLevel(this.repository);

  Future<Either<Failure, void>> call(SetCameraZoomLevelParams params) {
    return repository.setZoomLevel(params.controller, params.zoom);
  }
}
