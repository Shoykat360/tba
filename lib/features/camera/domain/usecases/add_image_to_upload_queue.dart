import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/captured_image.dart';
import '../repositories/image_sync_repository.dart';

class AddImageToUploadQueue implements UseCase<void, CapturedImage> {
  final ImageSyncRepository repository;
  AddImageToUploadQueue(this.repository);

  @override
  Future<Either<Failure, void>> call(CapturedImage image) {
    return repository.addImageToUploadQueue(image);
  }
}
