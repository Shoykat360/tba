/*
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extensions/either_extensions.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/image_batch.dart';
import '../entities/upload_status.dart';
import '../repositories/image_sync_repository.dart';

/// Resets [UploadStatus.failed] batches back to [UploadStatus.pending] and
/// clears their retry counts so they can be picked up by
/// [AttemptUploadForPendingImages] on the next upload cycle.
///
/// Called when the device transitions from offline to online.
class RetryFailedUploadsWhenConnectionRestored
    implements UseCase<void, NoParams> {
  final ImageSyncRepository _imageSyncRepository;

  const RetryFailedUploadsWhenConnectionRestored({
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

    final List<ImageBatch> failedBatches =
        allBatches.where((batch) => batch.isFailed).toList();

    for (final ImageBatch failedBatch in failedBatches) {
      final ImageBatch resetBatch = failedBatch.copyWith(
        uploadStatus: UploadStatus.pending,
        retryCount: 0,
        clearLastError: true,
      );
      await _imageSyncRepository.updateBatchStatusInQueue(resetBatch);
    }

    return const Right(null);
  }
}
*/
