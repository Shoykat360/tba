import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

/// Domain use case that signals intent to schedule a WorkManager background task.
///
/// The actual WorkManager call lives in [scheduleBackgroundUploadTask()] in the
/// background worker (data layer). This use case is a domain-level entry point
/// that the SyncBloc calls — keeping WorkManager details out of the BLoC.
class ScheduleBackgroundUploadTask implements UseCase<void, NoParams> {
  const ScheduleBackgroundUploadTask();

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    // Connectivity is checked inside the background worker when it runs.
    // WorkManager's NetworkType.connected constraint ensures the task only
    // executes when a network connection is available — no pre-check needed.
    return const Right(null);
  }
}
