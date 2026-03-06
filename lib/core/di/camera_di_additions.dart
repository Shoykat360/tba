// ─── Camera Feature DI additions ───────────────────────────────────────────
// Add these registrations inside your existing initDependencies() function
// in injection_container.dart

/*
  // ── Hive Box ──────────────────────────────────────────────────────────────
  // Open this box before calling initDependencies():
  //   await Hive.initFlutter();
  //   await Hive.openBox<Map>(kImageBatchBoxName);

  final imageBatchBox = Hive.box<Map>(kImageBatchBoxName);

  // ── External ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => const Uuid());
  sl.registerLazySingleton(() => Connectivity());

  // ── Datasources ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<CameraLocalDatasource>(
    () => CameraLocalDatasourceImpl(uuid: sl()),
  );
  sl.registerLazySingleton<ImageQueueLocalDatasource>(
    () => ImageQueueLocalDatasourceImpl(box: imageBatchBox),
  );

  // ── Repositories ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<CameraRepository>(
    () => CameraRepositoryImpl(localDatasource: sl(), uuid: sl()),
  );
  sl.registerLazySingleton<ImageSyncRepository>(
    () => ImageSyncRepositoryImpl(localDatasource: sl(), uuid: sl()),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => InitializeCamera(sl()));
  sl.registerLazySingleton(() => CaptureImageAndStoreLocally(sl()));
  sl.registerLazySingleton(() => SetCameraZoomLevel(sl()));
  sl.registerLazySingleton(() => SetManualFocusPoint(sl()));
  sl.registerLazySingleton(() => AddImageToUploadQueue(sl()));
  sl.registerLazySingleton(() => RetrievePendingUploadQueue(sl()));
  sl.registerLazySingleton(() => AttemptUploadForPendingImages(sl()));
  sl.registerLazySingleton(() => RetryFailedUploadsWhenConnectionRestored(sl()));
  sl.registerLazySingleton(() => ScheduleBackgroundUploadTask());

  // ── BLoCs ─────────────────────────────────────────────────────────────────
  sl.registerFactory(() => CameraBloc(
        initializeCamera: sl(),
        captureImage: sl(),
        setZoomLevel: sl(),
        setFocusPoint: sl(),
        addToQueue: sl(),
        cameraRepository: sl(),
      ));

  sl.registerFactory(() => SyncBloc(
        retrievePending: sl(),
        attemptUpload: sl(),
        connectivity: sl(),
      ));
*/
