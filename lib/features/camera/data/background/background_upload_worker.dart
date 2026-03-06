import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/usecases/attempt_upload_for_pending_images.dart';
import '../../domain/usecases/schedule_background_upload_task.dart';
import '../datasources/image_queue_local_datasource.dart';
import '../repositories/image_sync_repository_impl.dart';
import '../../../../core/usecases/usecase.dart';

/// Called by WorkManager in background isolate
/*@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == kSyncTaskName) {
      try {
        // Re-initialize Hive in background isolate
        await Hive.initFlutter();
        if (!Hive.isBoxOpen(kImageBatchBoxName)) {
          await Hive.openBox<Map>(kImageBatchBoxName);
        }
        final box = Hive.box<Map>(kImageBatchBoxName);

        final datasource = ImageQueueLocalDatasourceImpl(box: box);
        final repo = ImageSyncRepositoryImpl(
          localDatasource: datasource,
          uuid: const Uuid(),
        );
        final usecase = AttemptUploadForPendingImages(repo);
        await usecase(NoParams());
        return Future.value(true);
      } catch (_) {
        return Future.value(false);
      }
    }
    return Future.value(false);
  });
}*/

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == kSyncTaskName) {
      try {
        await Hive.initFlutter();
        if (!Hive.isBoxOpen(kImageBatchBoxName)) {
          await Hive.openBox<Map>(kImageBatchBoxName);
        }
        final box = Hive.box<Map>(kImageBatchBoxName);
        final datasource = ImageQueueLocalDatasourceImpl(box: box);
        final repo = ImageSyncRepositoryImpl(
          localDatasource: datasource,
          uuid: const Uuid(),
        );
        final usecase = AttemptUploadForPendingImages(repo);
        await usecase(NoParams());
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  });
}

class BackgroundUploadWorker {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> schedulePeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      kSyncTaskUniqueName,
      kSyncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
