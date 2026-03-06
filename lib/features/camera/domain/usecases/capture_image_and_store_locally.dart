import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/captured_image.dart';
import '../repositories/camera_repository.dart';

class CaptureImageAndStoreLocally implements UseCase<CapturedImage, CameraController> {
  final CameraRepository repository;

  CaptureImageAndStoreLocally(this.repository);

  @override
  Future<Either<Failure, CapturedImage>> call(CameraController controller) {
    return repository.captureImageAndStoreLocally(controller);
  }
}
