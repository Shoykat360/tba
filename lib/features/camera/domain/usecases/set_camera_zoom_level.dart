import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/camera_repository.dart';

class SetCameraZoomLevelParams {
  final double zoomLevel;
  const SetCameraZoomLevelParams({required this.zoomLevel});
}

class SetCameraZoomLevel implements UseCase<void, SetCameraZoomLevelParams> {
  final CameraRepository _cameraRepository;

  const SetCameraZoomLevel({required CameraRepository cameraRepository})
      : _cameraRepository = cameraRepository;

  @override
  Future<Either<Failure, void>> call(SetCameraZoomLevelParams params) async {
    return await _cameraRepository.updateZoomLevel(params.zoomLevel);
  }
}
