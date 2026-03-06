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
      // Each image gets its OWN batch with unique ID
      // batchId comes from image.batchId which is set at capture time
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
        debugPrint('[SyncRepo] 📥 New batch: ${batchId.substring(0, 8)}… | image: ${image.id.substring(0, 8)}… → PENDING');
      } else {
        final existingBatch = existing.first.toEntity();
        final updatedBatch = existingBatch.copyWith(
          images: [...existingBatch.images, image],
        );
        await localDatasource.updateBatch(
            ImageBatchModel.fromEntity(updatedBatch));
        debugPrint('[SyncRepo] 📥 Added to batch: ${batchId.substring(0, 8)}… (${updatedBatch.images.length} images total)');
      }
      return const Right(null);
    } on CacheException catch (e) {
      debugPrint('[SyncRepo] ❌ addImageToUploadQueue failed: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      debugPrint('[SyncRepo] ❌ addImageToUploadQueue unexpected: $e');
      return Left(CacheFailure(e.toString()));
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

      debugPrint('[SyncRepo] 📋 Queue: ${batches.length} non-uploaded batches');
      for (final b in batches) {
        debugPrint(
            '  └─ ${b.id.substring(0, 8)}… | ${b.images.length} img | ${b.uploadStatus.name} | retries=${b.retryCount}');
      }

      return Right(batches);
    } on CacheException catch (e) {
      debugPrint('[SyncRepo] ❌ retrievePendingUploadQueue failed: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      debugPrint('[SyncRepo] ❌ retrievePendingUploadQueue unexpected: $e');
      return Left(CacheFailure(e.toString()));
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

      if (pendingBatches.isEmpty) {
        debugPrint('[SyncRepo] ✅ Nothing to upload');
        return const Right(null);
      }

      debugPrint('[SyncRepo] 🚀 Uploading ${pendingBatches.length} batches');

      for (final batch in pendingBatches) {
        // Mark as uploading
        final uploadingBatch =
        batch.copyWith(uploadStatus: UploadStatus.uploading);
        await localDatasource
            .updateBatch(ImageBatchModel.fromEntity(uploadingBatch));
        debugPrint(
            '[SyncRepo] ⬆️  Uploading batch ${batch.id.substring(0, 8)}… (${batch.images.length} images)');

        try {
          // ── API call omitted per spec ─────────────────────────────────
          // Replace with: await apiDatasource.uploadBatch(batch);
          await Future.delayed(const Duration(milliseconds: 800));

          final uploaded =
          batch.copyWith(uploadStatus: UploadStatus.uploaded);
          await localDatasource
              .updateBatch(ImageBatchModel.fromEntity(uploaded));
          debugPrint(
              '[SyncRepo] ✅ Batch ${batch.id.substring(0, 8)}… uploaded successfully');
        } catch (e) {
          final failed = batch.copyWith(
            uploadStatus: UploadStatus.failed,
            retryCount: batch.retryCount + 1,
          );
          await localDatasource
              .updateBatch(ImageBatchModel.fromEntity(failed));
          debugPrint(
              '[SyncRepo] ❌ Batch ${batch.id.substring(0, 8)}… failed (retry #${failed.retryCount}): $e');
          debugPrint('[SyncRepo] 💾 Kept in local queue for retry');
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      debugPrint(
          '[SyncRepo] ❌ attemptUploadForPendingImages failed: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      debugPrint(
          '[SyncRepo] ❌ attemptUploadForPendingImages unexpected: $e');
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBatchStatus(ImageBatch batch) async {
    try {
      await localDatasource.updateBatch(ImageBatchModel.fromEntity(batch));
      debugPrint(
          '[SyncRepo] 🔄 Updated ${batch.id.substring(0, 8)}… → ${batch.uploadStatus.name}');
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> clearUploadedBatches() async {
    try {
      final models = await localDatasource.getAllBatches();
      int cleared = 0;
      for (final model in models) {
        if (model.uploadStatusIndex == UploadStatus.uploaded.index) {
          await localDatasource.deleteBatch(model.id);
          cleared++;
        }
      }
      debugPrint('[SyncRepo] 🗑️  Cleared $cleared uploaded batches');
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
