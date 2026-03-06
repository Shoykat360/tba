import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../domain/usecases/attempt_upload_for_pending_images.dart';
import '../datasources/image_queue_local_datasource.dart';
import '../repositories/image_sync_repository_impl.dart';

const kSyncTaskName = 'image_sync_task';
const kSyncTaskUniqueName = 'image_sync_unique';
const kSyncTaskImmediateName = 'image_sync_immediate';

/// MUST be top-level function with @pragma for release mode
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('[WorkManager] 🔧 Task: $taskName');

    if (taskName != kSyncTaskName) {
      debugPrint('[WorkManager] ⚠️ Unknown task: $taskName');
      return true;
    }

    try {
      // Always check real internet first
      final hasInternet = await _hasRealInternet();
      if (!hasInternet) {
        debugPrint('[WorkManager] 📵 No internet — will retry later');
        return true; // true = success, WorkManager reschedules periodic
      }

      // Initialize Hive in this background isolate
      // Background isolates are completely separate from main isolate
      await _initHiveForBackground();

      final box = Hive.box<Map>(kImageBatchBoxName);

      // Check if there's anything to upload before doing work
      final pendingCount = box.values
          .where((v) {
        final map = Map<String, dynamic>.from(v);
        final statusIndex = map['uploadStatusIndex'] as int;
        // 0 = pending, 3 = failed
        return statusIndex == 0 || statusIndex == 3;
      })
          .length;

      if (pendingCount == 0) {
        debugPrint('[WorkManager] ✅ Nothing pending — task complete');
        return true;
      }

      debugPrint('[WorkManager] 📦 Found $pendingCount pending batches — uploading');

      final datasource = ImageQueueLocalDatasourceImpl(box: box);
      final repo = ImageSyncRepositoryImpl(
        localDatasource: datasource,
        uuid: const Uuid(),
      );
      final usecase = AttemptUploadForPendingImages(repo);
      final result = await usecase(NoParams());

      result.fold(
            (failure) {
          debugPrint('[WorkManager] ❌ Sync failed: ${failure.message}');
        },
            (_) {
          debugPrint('[WorkManager] ✅ Background sync completed successfully');
        },
      );

      return true;
    } catch (e, stack) {
      debugPrint('[WorkManager] ❌ Exception: $e');
      debugPrint('[WorkManager] Stack: $stack');
      return false; // false = failure, WorkManager retries with backoff
    } finally {
      // Always close Hive after background task to free resources
      try {
        if (Hive.isBoxOpen(kImageBatchBoxName)) {
          await Hive.box<Map>(kImageBatchBoxName).close();
        }
      } catch (_) {}
    }
  });
}

/// Initialize Hive specifically for background isolate
Future<void> _initHiveForBackground() async {
  await Hive.initFlutter();
  if (!Hive.isBoxOpen(kImageBatchBoxName)) {
    await Hive.openBox<Map>(kImageBatchBoxName);
    debugPrint('[WorkManager] ✅ Hive box opened in background isolate');
  }
}

/// Real internet check via DNS lookup
Future<bool> _hasRealInternet() async {
  try {
    final result = await InternetAddress.lookup('google.com')
        .timeout(const Duration(seconds: 5));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}

class BackgroundUploadWorker {
  /// Call once in main() before runApp
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    debugPrint('[WorkManager] ✅ Initialized (debug=$kDebugMode)');
  }

  /// Periodic task — fires every 15 min (Android minimum)
  static Future<void> schedulePeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      kSyncTaskUniqueName,
      kSyncTaskName,
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
    debugPrint('[WorkManager] ✅ Periodic sync scheduled (every 15min)');
  }

  /// One-off immediate task — fires as soon as network available
  /// Use this when app resumes or connectivity restores
  static Future<void> triggerImmediateSync() async {
    try {
      await Workmanager().registerOneOffTask(
        // Unique name with timestamp prevents duplicate tasks
        '${kSyncTaskImmediateName}_${DateTime.now().millisecondsSinceEpoch}',
        kSyncTaskName,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(seconds: 30),
      );
      debugPrint('[WorkManager] 🚀 One-off sync task registered');
    } catch (e) {
      debugPrint('[WorkManager] ❌ Failed to register one-off task: $e');
    }
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
    debugPrint('[WorkManager] 🗑️ All tasks cancelled');
  }
}
