import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/captured_image.dart';
import '../entities/image_batch.dart';

abstract class ImageSyncRepository {
  Future<Either<Failure, void>> addImageToUploadQueue(CapturedImage image);

  Future<Either<Failure, List<ImageBatch>>> retrievePendingUploadQueue();

  Future<Either<Failure, void>> attemptUploadForPendingImages();

  Future<Either<Failure, void>> updateBatchStatus(ImageBatch batch);

  Future<Either<Failure, void>> clearUploadedBatches();
}
