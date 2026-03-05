/*
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/datasources/image_queue_local_datasource.dart';
import '../../data/repositories/image_sync_repository_impl.dart';
import '../../domain/usecases/attempt_upload_for_pending_images.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (taskName == AppConstants.backgroundUploadTaskName) {
        await _runBackgroundUpload();
      }
      return true;
    } catch (_) {
      return false;
    }
  });
}

Future<void> _runBackgroundUpload() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isBoxOpen(AppConstants.imageQueueHiveBoxName)) {
    await Hive.openBox<String>(AppConstants.imageQueueHiveBoxName);
  }

  final datasource = ImageQueueLocalDatasourceImpl(hive: Hive);
  final repository = ImageSyncRepositoryImpl(
    imageQueueLocalDatasource: datasource,
    connectivity: Connectivity(),
  );
  final useCase = AttemptUploadForPendingImages(
    imageSyncRepository: repository,
  );

  // FIX 1: Use NoParams from core/usecases/usecase.dart — not a local _NoParams
  await useCase(const NoParams());
}

Future<void> scheduleBackgroundUploadTask() async {
  await Workmanager().registerOneOffTask(
    AppConstants.backgroundUploadUniqueTaskName,
    AppConstants.backgroundUploadTaskName,
    existingWorkPolicy: ExistingWorkPolicy.replace,
    constraints: Constraints(networkType: NetworkType.connected),
    backoffPolicy: BackoffPolicy.exponential,
    backoffPolicyDelay: const Duration(minutes: 1),
  );
}
*/


