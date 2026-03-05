import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/camera_configuration.dart';
import '../repositories/camera_repository.dart';

class InitializeCamera implements UseCase<CameraConfiguration, NoParams> {
  final CameraRepository _cameraRepository;

  /// Exposes the active [CameraController] held in the repository impl.
  ///
  /// [CameraPreview] requires the live controller. Since it is created inside
  /// the data layer, the BLoC retrieves it here after [call] succeeds. Uses a
  /// dynamic accessor to avoid importing camera package types into the domain.
  dynamic get activeCameraController {
    try {
      return (_cameraRepository as dynamic).activeCameraController;
    } catch (_) {
      return null;
    }
  }

  const InitializeCamera({required CameraRepository cameraRepository})
      : _cameraRepository = cameraRepository;

  @override
  Future<Either<Failure, CameraConfiguration>> call(NoParams params) async {
    return await _cameraRepository.initializeCamera();
  }
}
