import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/camera_repository.dart';

class InitializeCamera implements UseCase<CameraController, NoParams> {
  final CameraRepository repository;

  InitializeCamera(this.repository);

  @override
  Future<Either<Failure, CameraController>> call(NoParams params) {
    return repository.initializeCamera();
  }
}
