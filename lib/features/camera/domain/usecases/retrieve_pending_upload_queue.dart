import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/image_batch.dart';
import '../repositories/image_sync_repository.dart';

class RetrievePendingUploadQueue implements UseCase<List<ImageBatch>, NoParams> {
  final ImageSyncRepository repository;
  RetrievePendingUploadQueue(this.repository);

  @override
  Future<Either<Failure, List<ImageBatch>>> call(NoParams params) {
    return repository.retrievePendingUploadQueue();
  }
}
