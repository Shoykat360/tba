import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/captured_image.dart';
import '../repositories/camera_repository.dart';

class CaptureImageAndStoreLocally
    implements UseCase<CapturedImage, NoParams> {
  final CameraRepository _cameraRepository;

  const CaptureImageAndStoreLocally({
    required CameraRepository cameraRepository,
  }) : _cameraRepository = cameraRepository;

  @override
  Future<Either<Failure, CapturedImage>> call(NoParams params) async {
    return await _cameraRepository.captureImageAndStoreLocally();
  }
}
