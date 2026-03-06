import 'package:dartz/dartz.dart';
import 'package:workmanager/workmanager.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

const kSyncTaskName = 'image_sync_task';
const kSyncTaskUniqueName = 'image_sync_unique';

class ScheduleBackgroundUploadTask implements UseCase<void, NoParams> {
  ScheduleBackgroundUploadTask();

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await Workmanager().registerPeriodicTask(
        kSyncTaskUniqueName,
        kSyncTaskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to schedule background task: $e'));
    }
  }
}
