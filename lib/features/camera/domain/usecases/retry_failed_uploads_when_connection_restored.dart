import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/image_sync_repository.dart';

class RetryFailedUploadsWhenConnectionRestored implements UseCase<void, NoParams> {
  final ImageSyncRepository repository;
  RetryFailedUploadsWhenConnectionRestored(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.attemptUploadForPendingImages();
  }
}
