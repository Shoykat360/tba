import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/captured_image.dart';
import '../../domain/entities/image_batch.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/repositories/image_sync_repository.dart';
import '../datasources/image_queue_local_datasource.dart';
import '../models/image_batch_model.dart';

class ImageSyncRepositoryImpl implements ImageSyncRepository {
  final ImageQueueLocalDatasource localDatasource;
  final Uuid uuid;

  // Current in-memory batch being built
  List<CapturedImage> _currentBatchImages = [];

  ImageSyncRepositoryImpl({
    required this.localDatasource,
    required this.uuid,
  });

  @override
  Future<Either<Failure, void>> addImageToUploadQueue(CapturedImage image) async {
    try {
      _currentBatchImages.add(image);

      // Create/update a "pending" batch with the new image
      final batchId = image.batchId;
      final batches = await localDatasource.getAllBatches();
      final existing = batches.where((b) => b.id == batchId).toList();

      if (existing.isEmpty) {
        final batch = ImageBatch(
          id: batchId,
          images: [image],
          uploadStatus: UploadStatus.pending,
          createdAt: DateTime.now(),
        );
        await localDatasource.saveBatch(ImageBatchModel.fromEntity(batch));
      } else {
        final existingBatch = existing.first.toEntity();
        final updatedBatch = existingBatch.copyWith(
          images: [...existingBatch.images, image],
        );
        await localDatasource.updateBatch(ImageBatchModel.fromEntity(updatedBatch));
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ImageBatch>>> retrievePendingUploadQueue() async {
    try {
      final models = await localDatasource.getAllBatches();
      final batches = models
          .map((m) => m.toEntity())
          .where((b) => !b.isUploaded)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return Right(batches);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> attemptUploadForPendingImages() async {
    try {
      final models = await localDatasource.getAllBatches();
      final pendingBatches = models
          .map((m) => m.toEntity())
          .where((b) => b.isPending || b.isFailed)
          .toList();

      for (final batch in pendingBatches) {
        // Mark as uploading
        final uploadingBatch = batch.copyWith(uploadStatus: UploadStatus.uploading);
        await localDatasource.updateBatch(ImageBatchModel.fromEntity(uploadingBatch));

        try {
          // NOTE: API call omitted as per spec. Simulate success.
          // In production: await apiDatasource.uploadBatch(batch);
          await Future.delayed(const Duration(milliseconds: 500));

          // Mark as uploaded
          final uploaded = batch.copyWith(uploadStatus: UploadStatus.uploaded);
          await localDatasource.updateBatch(ImageBatchModel.fromEntity(uploaded));
        } catch (_) {
          // Mark as failed, increment retry count
          final failed = batch.copyWith(
            uploadStatus: UploadStatus.failed,
            retryCount: batch.retryCount + 1,
          );
          await localDatasource.updateBatch(ImageBatchModel.fromEntity(failed));
        }
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateBatchStatus(ImageBatch batch) async {
    try {
      await localDatasource.updateBatch(ImageBatchModel.fromEntity(batch));
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> clearUploadedBatches() async {
    try {
      final models = await localDatasource.getAllBatches();
      for (final model in models) {
        if (model.uploadStatusIndex == UploadStatus.uploaded.index) {
          await localDatasource.deleteBatch(model.id);
        }
      }
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
