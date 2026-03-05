import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/image_batch.dart';

/// Defines the contract for image queue management and upload sync operations.
abstract class ImageSyncRepository {
  /// Persists a new [ImageBatch] to the local queue.
  /// The batch starts with [UploadStatus.pending].
  Future<Either<Failure, void>> addImageToUploadQueue(ImageBatch batch);

  /// Loads all [ImageBatch] entries from the local queue regardless of status.
  Future<Either<Failure, List<ImageBatch>>> retrievePendingUploadQueue();

  /// Simulates uploading the given [batch] to the server via a fake API call.
  /// On success the batch is marked [UploadStatus.uploaded].
  /// On failure it is marked [UploadStatus.failed] and its retryCount incremented.
  Future<Either<Failure, void>> attemptUploadForBatch(ImageBatch batch);

  /// Updates the persisted status of an existing batch in the queue.
  Future<Either<Failure, void>> updateBatchStatusInQueue(ImageBatch batch);

  /// Removes a batch from the local queue after a successful upload.
  Future<Either<Failure, void>> removeBatchFromQueue(String batchId);

  /// Returns true if the device currently has a usable internet connection.
  Future<bool> checkInternetConnectivity();
}
