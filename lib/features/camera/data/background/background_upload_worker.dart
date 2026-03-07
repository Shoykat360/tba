import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../domain/usecases/camera_usecases.dart';
import '../datasources/image_queue_local_datasource.dart';
import '../repositories/image_sync_repository_impl.dart';

// Task name constants — must match what is registered in main()
const kBackgroundSyncTaskName = 'image_sync_task';
const kBackgroundSyncUniqueTagPeriodic = 'image_sync_periodic';
const kBackgroundSyncUniqueTagImmediate = 'image_sync_immediate';

/// IMPORTANT: This function MUST be a top-level function (not inside a class).
/// The @pragma annotation is required for release/AOT builds so the Dart
/// compiler does not tree-shake this entry point away.
///
/// WorkManager runs this in a completely separate isolate from the main app,
/// so no Flutter widgets or singletons are available — we re-initialise
/// everything from scratch here.
@pragma('vm:entry-point')
void backgroundWorkerEntryPoint() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('[BGWorker] 🔧 Task received: $taskName');

    if (taskName != kBackgroundSyncTaskName) {
      debugPrint('[BGWorker] ⚠️ Unknown task "$taskName" — skipping');
      return true; // Return true so WorkManager does not retry immediately
    }

    try {
      // Step 1 — verify we actually have internet before doing any work
      final hasInternet = await checkForRealInternet();
      if (!hasInternet) {
        debugPrint('[BGWorker] 📵 No internet — will retry on next schedule');
        return true; // true = success; WorkManager keeps the periodic schedule
      }

      // Step 2 — boot Hive in this isolate (each isolate is independent)
      await openHiveInBackgroundIsolate();

      final box = Hive.box<Map>(kImageBatchBoxName);

      // Step 3 — count batches that still need uploading
      final pendingBatchCount = box.values.where((rawMap) {
        final map = Map<String, dynamic>.from(rawMap);
        final statusIndex = map['uploadStatusIndex'] as int;
        // 0 = pending, 3 = failed
        return statusIndex == 0 || statusIndex == 3;
      }).length;

      if (pendingBatchCount == 0) {
        debugPrint('[BGWorker] ✅ Nothing pending — task done');
        return true;
      }

      debugPrint(
          '[BGWorker] 📦 $pendingBatchCount batch(es) pending — starting upload');

      // Step 4 — wire up the repository chain manually (no DI available here)
      final datasource = ImageQueueLocalDatasourceImpl(box: box);
      final syncRepository = ImageSyncRepositoryImpl(
        localDatasource: datasource,
        uuid: const Uuid(),
      );
      final attemptUploadUseCase =
          AttemptUploadForPendingImages(syncRepository);

      final result = await attemptUploadUseCase(NoParams());

      result.fold(
        (failure) =>
            debugPrint('[BGWorker] ❌ Upload failed: ${failure.message}'),
        (_) => debugPrint('[BGWorker] ✅ Background upload finished'),
      );

      return true;
    } catch (error, stackTrace) {
      debugPrint('[BGWorker] ❌ Exception: $error');
      debugPrint('[BGWorker] Stack: $stackTrace');
      // Return false so WorkManager retries with exponential back-off
      return false;
    } finally {
      // Always close Hive after the task — frees file locks for the main app
      await closeHiveAfterBackgroundTask();
    }
  });
}

/// Opens Hive in the background isolate.
/// Must be called before accessing any Hive box in this isolate.
Future<void> openHiveInBackgroundIsolate() async {
  await Hive.initFlutter();
  if (!Hive.isBoxOpen(kImageBatchBoxName)) {
    await Hive.openBox<Map>(kImageBatchBoxName);
    debugPrint('[BGWorker] ✅ Hive box opened in background isolate');
  }
}

/// Closes the Hive box after the background task completes.
Future<void> closeHiveAfterBackgroundTask() async {
  try {
    if (Hive.isBoxOpen(kImageBatchBoxName)) {
      await Hive.box<Map>(kImageBatchBoxName).close();
      debugPrint('[BGWorker] 🔒 Hive box closed');
    }
  } catch (_) {}
}

/// Checks for real internet connectivity via DNS lookup.
/// Returns false for situations like "WiFi connected but no internet".
Future<bool> checkForRealInternet() async {
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 5));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

/// Manages WorkManager task registration.
/// Call [BackgroundSyncScheduler.initialise] once in main() before runApp().
class BackgroundSyncScheduler {
  BackgroundSyncScheduler._(); // prevent instantiation

  /// Initialise WorkManager. Call once in main() before runApp().
  static Future<void> initialise() async {
    await Workmanager().initialize(
      backgroundWorkerEntryPoint,
      isInDebugMode: kDebugMode,
    );
    debugPrint(
        '[BGScheduler] ✅ WorkManager initialised (debug=$kDebugMode)');
  }

  /// Schedule a periodic task that fires every 15 minutes (Android minimum).
  /// Uses [ExistingWorkPolicy.keep] so re-registrations do not reset the timer.
  static Future<void> schedulePeriodicUploadCheck() async {
    await Workmanager().registerPeriodicTask(
      kBackgroundSyncUniqueTagPeriodic,
      kBackgroundSyncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 1),
    );
    debugPrint('[BGScheduler] ✅ Periodic upload check scheduled (15 min)');
  }

  /// Trigger an immediate one-off upload attempt — use this when the app
  /// detects connectivity is restored or when it comes back to the foreground.
  ///
  /// A timestamp suffix ensures the unique name is always fresh so Android
  /// does not deduplicate it with a previous immediate task.
  static Future<void> triggerImmediateUploadNow() async {
    try {
      final uniqueTag =
          '${kBackgroundSyncUniqueTagImmediate}_${DateTime.now().millisecondsSinceEpoch}';
      await Workmanager().registerOneOffTask(
        uniqueTag,
        kBackgroundSyncTaskName,
        constraints: Constraints(networkType: NetworkType.connected),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(seconds: 30),
      );
      debugPrint('[BGScheduler] 🚀 Immediate upload task queued');
    } catch (e) {
      debugPrint('[BGScheduler] ❌ Could not queue immediate task: $e');
    }
  }

  /// Cancel all pending WorkManager tasks (e.g. on logout).
  static Future<void> cancelAllScheduledTasks() async {
    await Workmanager().cancelAll();
    debugPrint('[BGScheduler] 🗑️ All scheduled tasks cancelled');
  }
}
