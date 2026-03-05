import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/image_batch.dart';
import '../repositories/image_sync_repository.dart';

class AddImageToUploadQueueParams {
  final ImageBatch batch;
  const AddImageToUploadQueueParams({required this.batch});
}

class AddImageToUploadQueue
    implements UseCase<void, AddImageToUploadQueueParams> {
  final ImageSyncRepository _imageSyncRepository;

  const AddImageToUploadQueue({
    required ImageSyncRepository imageSyncRepository,
  }) : _imageSyncRepository = imageSyncRepository;

  @override
  Future<Either<Failure, void>> call(
    AddImageToUploadQueueParams params,
  ) async {
    return await _imageSyncRepository.addImageToUploadQueue(params.batch);
  }
}
