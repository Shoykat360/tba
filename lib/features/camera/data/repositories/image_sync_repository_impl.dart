/*
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/image_batch.dart';
import '../../domain/entities/upload_status.dart';
import '../../domain/repositories/image_sync_repository.dart';
import '../datasources/image_queue_local_datasource.dart';
import '../models/image_batch_model.dart';

class ImageSyncRepositoryImpl implements ImageSyncRepository {
  final ImageQueueLocalDatasource _imageQueueLocalDatasource;
  final Connectivity _connectivity;

  const ImageSyncRepositoryImpl({
    required ImageQueueLocalDatasource imageQueueLocalDatasource,
    required Connectivity connectivity,
  })  : _imageQueueLocalDatasource = imageQueueLocalDatasource,
        _connectivity = connectivity;

  @override
  Future<Either<Failure, void>> addImageToUploadQueue(
    ImageBatch batch,
  ) async {
    try {
      final ImageBatchModel model = ImageBatchModel.fromEntity(batch);
      await _imageQueueLocalDatasource.saveOrUpdateBatchInQueue(model);
      return const Right(null);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message));
    } catch (e) {
      return Left(
        LocalStorageFailure(
          message: 'Failed to add batch to queue: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ImageBatch>>>
      retrievePendingUploadQueue() async {
    try {
      final List<ImageBatchModel> models =
          await _imageQueueLocalDatasource.getAllBatchesFromQueue();
      return Right(models.map((m) => m.toEntity()).toList());
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message));
    } catch (e) {
      return Left(
        LocalStorageFailure(
          message: 'Failed to retrieve queue: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> attemptUploadForBatch(
    ImageBatch batch,
  ) async {
    try {
      await Future.delayed(
        const Duration(milliseconds: AppConstants.simulatedUploadDurationMs),
      );

      final bool stillConnected = await checkInternetConnectivity();
      if (!stillConnected) {
        return const Left(ConnectivityFailure());
      }

      final bool simulatedSuccess = batch.retryCount < 2;
      if (!simulatedSuccess) {
        return Left(
          UploadFailure(
            message: 'Simulated server error for batch ${batch.id}. Will retry.',
          ),
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(
        UploadFailure(message: 'Upload failed unexpectedly: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateBatchStatusInQueue(
    ImageBatch batch,
  ) async {
    try {
      final ImageBatchModel model = ImageBatchModel.fromEntity(batch);
      await _imageQueueLocalDatasource.saveOrUpdateBatchInQueue(model);
      return const Right(null);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message));
    } catch (e) {
      return Left(
        LocalStorageFailure(
          message: 'Failed to update batch status: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeBatchFromQueue(String batchId) async {
    try {
      await _imageQueueLocalDatasource.removeBatchFromQueue(batchId);
      return const Right(null);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message));
    } catch (e) {
      return Left(
        LocalStorageFailure(
          message: 'Failed to remove batch: ${e.toString()}',
        ),
      );
    }
  }

  // FIX 2: connectivity_plus 5.x checkConnectivity() returns a single
  // ConnectivityResult, not a List. Handle both cases safely.
  @override
  Future<bool> checkInternetConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _isConnected(result);
    } catch (_) {
      return false;
    }
  }

  /// Safely checks a connectivity result regardless of whether the plugin
  /// returns a single [ConnectivityResult] or a [List<ConnectivityResult>].
  bool _isConnected(dynamic result) {
    if (result is List) {
      return (result as List).any(_isOnlineResult);
    }
    if (result is ConnectivityResult) {
      return _isOnlineResult(result);
    }
    return false;
  }

  bool _isOnlineResult(dynamic r) =>
      r == ConnectivityResult.wifi ||
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.ethernet;
}
*/


