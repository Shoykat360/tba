/*
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extensions/either_extensions.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/image_batch.dart';
import '../entities/upload_status.dart';
import '../repositories/image_sync_repository.dart';
import '../../../../core/constants/app_constants.dart';
/// Iterates the pending upload queue and attempts to upload each batch
/// that is not yet [UploadStatus.uploaded].
///
/// Batches that exceed [AppConstants.maxUploadRetryCount] are marked
/// [UploadStatus.failed] and skipped on future runs.
class AttemptUploadForPendingImages implements UseCase<void, NoParams> {
  final ImageSyncRepository _imageSyncRepository;

  const AttemptUploadForPendingImages({
    required ImageSyncRepository imageSyncRepository,
  }) : _imageSyncRepository = imageSyncRepository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    final hasConnection =
        await _imageSyncRepository.checkInternetConnectivity();

    if (!hasConnection) {
      return const Left(ConnectivityFailure());
    }

    final queueResult =
        await _imageSyncRepository.retrievePendingUploadQueue();

    if (queueResult.isLeft()) {
      return Left(queueResult.leftOrThrow);
    }

    final List<ImageBatch> allBatches = queueResult.rightOrThrow;

    final List<ImageBatch> uploadableBatches = allBatches
        .where(
          (batch) =>
              !batch.isUploaded &&
              batch.retryCount < AppConstants.maxUploadRetryCount,
        )
        .toList();

    if (uploadableBatches.isEmpty) {
      return const Right(null);
    }

    for (final ImageBatch batch in uploadableBatches) {
      final ImageBatch uploadingBatch =
          batch.copyWith(uploadStatus: UploadStatus.uploading);
      await _imageSyncRepository.updateBatchStatusInQueue(uploadingBatch);

      final uploadResult =
          await _imageSyncRepository.attemptUploadForBatch(uploadingBatch);

      await uploadResult.fold(
        (failure) async {
          final ImageBatch failedBatch = batch.copyWith(
            uploadStatus: UploadStatus.failed,
            retryCount: batch.retryCount + 1,
            lastErrorMessage: failure.message,
          );
          await _imageSyncRepository.updateBatchStatusInQueue(failedBatch);
        },
        (_) async {
          await _imageSyncRepository.removeBatchFromQueue(batch.id);
        },
      );
    }

    return const Right(null);
  }
}
*/
