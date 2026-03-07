import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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

  ImageSyncRepositoryImpl({
    required this.localDatasource,
    required this.uuid,
  });

  @override
  Future<Either<Failure, void>> addImageToUploadQueue(
      CapturedImage image) async {
    try {
      final batchId = image.batchId;
      final allBatches = await localDatasource.getAllBatches();
      final existingBatches =
      allBatches.where((b) => b.id == batchId).toList();

      if (existingBatches.isEmpty) {
        final newBatch = ImageBatch(
          id: batchId,
          images: [image],
          uploadStatus: UploadStatus.pending,
          createdAt: DateTime.now(),
        );
        await localDatasource.saveBatch(ImageBatchModel.fromEntity(newBatch));
        debugPrint('[SyncRepo] 📥 New batch ${batchId.substring(0, 8)} created');
      } else {
        final currentBatch = existingBatches.first.toEntity();
        final updatedBatch = currentBatch.copyWith(
          images: [...currentBatch.images, image],
        );
        await localDatasource
            .updateBatch(ImageBatchModel.fromEntity(updatedBatch));
        debugPrint(
            '[SyncRepo] 📥 Image added to batch ${batchId.substring(0, 8)} '
                '(${updatedBatch.images.length} total)');
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ImageBatch>>> retrievePendingUploadQueue() async {
    try {
      final models = await localDatasource.getAllBatches();

      // BUG FIX #2 — On app restart, any batch that was left in "uploading"
      // status (because the app was killed mid-upload) must be reset back to
      // "pending" so it is retried. Without this, they stay stuck as
      // "uploading" forever and never appear in the retry queue.
      for (final model in models) {
        if (model.uploadStatusIndex == UploadStatus.uploading.index) {
          debugPrint(
              '[SyncRepo] 🔄 Resetting stuck "uploading" batch '
                  '${model.id.substring(0, 8)} → pending');
          final resetBatch = model.toEntity().copyWith(
            uploadStatus: UploadStatus.pending,
          );
          await localDatasource
              .updateBatch(ImageBatchModel.fromEntity(resetBatch));
        }
      }

      // Re-read after the reset so the list reflects updated statuses
      final refreshedModels = await localDatasource.getAllBatches();
      final nonUploadedBatches = refreshedModels
          .map((m) => m.toEntity())
          .where((b) => !b.isUploaded)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      debugPrint('[SyncRepo] 📋 ${nonUploadedBatches.length} batches in queue');
      return Right(nonUploadedBatches);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> attemptUploadForPendingImages() async {
    try {
      final models = await localDatasource.getAllBatches();

      // BUG FIX #2 (background isolate path) — also reset any stuck
      // "uploading" batches here, since the background worker calls this
      // method directly without calling retrievePendingUploadQueue first.
      for (final model in models) {
        if (model.uploadStatusIndex == UploadStatus.uploading.index) {
          debugPrint(
              '[SyncRepo] 🔄 Resetting stuck "uploading" batch '
                  '${model.id.substring(0, 8)} → pending (background path)');
          final resetBatch = model.toEntity().copyWith(
            uploadStatus: UploadStatus.pending,
          );
          await localDatasource
              .updateBatch(ImageBatchModel.fromEntity(resetBatch));
        }
      }

      // Re-read fresh list after reset
      final freshModels = await localDatasource.getAllBatches();
      final batchesToUpload = freshModels
          .map((m) => m.toEntity())
          .where((b) => b.isPending || b.isFailed)
          .toList();

      if (batchesToUpload.isEmpty) {
        debugPrint('[SyncRepo] ✅ No batches need uploading');
        return const Right(null);
      }

      debugPrint('[SyncRepo] 🚀 Uploading ${batchesToUpload.length} batches');

      for (final batch in batchesToUpload) {
        // Mark as uploading so the UI shows a spinner
        final uploadingBatch =
        batch.copyWith(uploadStatus: UploadStatus.uploading);
        await localDatasource
            .updateBatch(ImageBatchModel.fromEntity(uploadingBatch));

        try {
          // ── Dummy upload — replace with real API call ────────────────
          // Each image in the batch is uploaded individually here so the
          // progress is accurate. The dummy delay scales with image count
          // so the UI shows something realistic.
          //
          // Real implementation example:
          //   for (final image in batch.images) {
          //     await apiDatasource.uploadImage(image);
          //   }
          final imageCount = batch.images.length;
          debugPrint(
              '[SyncRepo] ⬆️  Uploading batch ${batch.id.substring(0, 8)} '
                  '($imageCount image${imageCount != 1 ? 's' : ''})');

          // BUG FIX #1 — The old code used a fixed 800 ms delay regardless
          // of image count, so every upload felt the same. Now the dummy
          // delay is proportional: 600 ms per image, so batches with more
          // images take visibly longer — matching real upload behaviour.
          await Future.delayed(Duration(milliseconds: 600 * imageCount));

          final uploadedBatch =
          batch.copyWith(uploadStatus: UploadStatus.uploaded);
          await localDatasource
              .updateBatch(ImageBatchModel.fromEntity(uploadedBatch));
          debugPrint(
              '[SyncRepo] ✅ Batch ${batch.id.substring(0, 8)} uploaded '
                  '($imageCount image${imageCount != 1 ? 's' : ''})');
        } catch (uploadError) {
          // Upload failed — reset to pending (not failed on first attempt)
          // so it is retried on the next cycle rather than needing manual
          // intervention. Only mark as failed after exceeding retry limit.
          const maxRetries = 3;
          final newRetryCount = batch.retryCount + 1;
          final nextStatus = newRetryCount >= maxRetries
              ? UploadStatus.failed
              : UploadStatus.pending;

          final failedBatch = batch.copyWith(
            uploadStatus: nextStatus,
            retryCount: newRetryCount,
          );
          await localDatasource
              .updateBatch(ImageBatchModel.fromEntity(failedBatch));
          debugPrint(
              '[SyncRepo] ❌ Batch ${batch.id.substring(0, 8)} error '
                  '(attempt $newRetryCount/$maxRetries → ${nextStatus.name}): '
                  '$uploadError');
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
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
      int deletedCount = 0;
      for (final model in models) {
        if (model.uploadStatusIndex == UploadStatus.uploaded.index) {
          await localDatasource.deleteBatch(model.id);
          deletedCount++;
        }
      }
      debugPrint('[SyncRepo] 🗑️ Cleared $deletedCount uploaded batches');
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}