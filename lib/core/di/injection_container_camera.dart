// ─────────────────────────────────────────────────────────────
// ADD THIS to your existing injection_container.dart
// inside the initDependencies() function
// ─────────────────────────────────────────────────────────────
//
// This snippet registers all camera & sync dependencies.
// Your existing sl (GetIt instance) and SharedPreferences
// registration are assumed to already be set up.

/*

// ── Camera datasources ────────────────────────────────────────
sl.registerLazySingleton<CameraLocalDatasource>(
  () => CameraLocalDatasourceImpl(),
);

sl.registerLazySingleton<ImageQueueLocalDatasource>(
  () => ImageQueueLocalDatasourceImpl(prefs: sl()),
);

// ── Camera repositories ───────────────────────────────────────
sl.registerLazySingleton<CameraRepository>(
  () => CameraRepositoryImpl(localDatasource: sl()),
);

sl.registerLazySingleton<ImageSyncRepository>(
  () => ImageSyncRepositoryImpl(localDatasource: sl()),
);

// ── Camera use cases ──────────────────────────────────────────
sl.registerLazySingleton(() => InitializeCamera(sl()));
sl.registerLazySingleton(() => CaptureImageAndStoreLocally(sl()));
sl.registerLazySingleton(() => SetCameraZoomLevel(sl()));
sl.registerLazySingleton(() => SetManualFocusPoint(sl()));
sl.registerLazySingleton(() => AddImageToUploadQueue(sl()));
sl.registerLazySingleton(() => RetrievePendingUploadQueue(sl()));
sl.registerLazySingleton(() => AttemptUploadForPendingImages(sl()));
sl.registerLazySingleton(() => RetryFailedUploadsWhenConnectionRestored(sl()));
sl.registerLazySingleton(() => const ScheduleBackgroundUploadTask());

// ── Camera BLoCs ──────────────────────────────────────────────
sl.registerFactory(() => CameraBloc(
  initializeCamera: sl(),
  captureImage: sl(),
  setZoomLevel: sl(),
  setFocusPoint: sl(),
  addImageToQueue: sl(),
  cameraRepository: sl(),
  scheduleBackground: sl(),
));

sl.registerFactory(() => SyncBloc(
  retrievePendingQueue: sl(),
  attemptUpload: sl(),
  retryFailedUploads: sl(),
));

*/

// ─────────────────────────────────────────────────────────────
// Also initialise workmanager in main.dart BEFORE runApp():
//
//   await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
//
// ─────────────────────────────────────────────────────────────