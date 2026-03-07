import 'package:camera/camera.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/captured_image.dart';
import '../entities/image_batch.dart';
import '../repositories/camera_repository.dart';
import '../repositories/image_sync_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Camera Use Cases
// ─────────────────────────────────────────────────────────────────────────────

class InitializeCamera implements UseCase<CameraController, NoParams> {
  final CameraRepository repository;
  InitializeCamera(this.repository);

  @override
  Future<Either<Failure, CameraController>> call(NoParams params) {
    return repository.initializeCamera();
  }
}

class CaptureImageAndStoreLocally
    implements UseCase<CapturedImage, CameraController> {
  final CameraRepository repository;
  CaptureImageAndStoreLocally(this.repository);

  @override
  Future<Either<Failure, CapturedImage>> call(CameraController controller) {
    return repository.captureImageAndStoreLocally(controller);
  }
}

// Params wrapper for zoom — keeps call sites readable
class ZoomLevelParams {
  final CameraController controller;
  final double zoom;
  ZoomLevelParams({required this.controller, required this.zoom});
}

class SetCameraZoomLevel {
  final CameraRepository repository;
  SetCameraZoomLevel(this.repository);

  Future<Either<Failure, void>> call(ZoomLevelParams params) {
    return repository.setZoomLevel(params.controller, params.zoom);
  }
}

// Params wrapper for focus point
class FocusPointParams {
  final CameraController controller;
  final Offset point;
  FocusPointParams({required this.controller, required this.point});
}

class SetManualFocusPoint {
  final CameraRepository repository;
  SetManualFocusPoint(this.repository);

  Future<Either<Failure, void>> call(FocusPointParams params) {
    return repository.setFocusPoint(params.controller, params.point);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sync / Queue Use Cases
// ─────────────────────────────────────────────────────────────────────────────

class AddImageToUploadQueue implements UseCase<void, CapturedImage> {
  final ImageSyncRepository repository;
  AddImageToUploadQueue(this.repository);

  @override
  Future<Either<Failure, void>> call(CapturedImage image) {
    return repository.addImageToUploadQueue(image);
  }
}

class RetrievePendingUploadQueue
    implements UseCase<List<ImageBatch>, NoParams> {
  final ImageSyncRepository repository;
  RetrievePendingUploadQueue(this.repository);

  @override
  Future<Either<Failure, List<ImageBatch>>> call(NoParams params) {
    return repository.retrievePendingUploadQueue();
  }
}

class AttemptUploadForPendingImages implements UseCase<void, NoParams> {
  final ImageSyncRepository repository;
  AttemptUploadForPendingImages(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.attemptUploadForPendingImages();
  }
}

class RetryFailedUploadsWhenConnectionRestored
    implements UseCase<void, NoParams> {
  final ImageSyncRepository repository;
  RetryFailedUploadsWhenConnectionRestored(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.attemptUploadForPendingImages();
  }
}

class ScheduleBackgroundUploadTask implements UseCase<void, NoParams> {
  ScheduleBackgroundUploadTask();

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await Workmanager().registerPeriodicTask(
        'image_sync_unique',
        'image_sync_task',
        frequency: const Duration(minutes: 15),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to schedule background task: $e'));
    }
  }
}
