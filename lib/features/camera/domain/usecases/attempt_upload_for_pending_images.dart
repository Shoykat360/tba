import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/image_sync_repository.dart';

class AttemptUploadForPendingImages implements UseCase<void, NoParams> {
  final ImageSyncRepository repository;
  AttemptUploadForPendingImages(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.attemptUploadForPendingImages();
  }
}
