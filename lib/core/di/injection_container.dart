import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Attendance
import '../../features/attendance/data/datasources/attendance_local_datasource.dart';
import '../../features/attendance/data/datasources/location_remote_datasource.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/domain/services/geofence_calculator_service.dart';
import '../../features/attendance/domain/usecases/calculate_distance_in_meters.dart';
import '../../features/attendance/domain/usecases/check_if_user_is_within_allowed_radius.dart';
import '../../features/attendance/domain/usecases/fetch_current_location.dart';
import '../../features/attendance/domain/usecases/load_saved_office_location.dart';
import '../../features/attendance/domain/usecases/mark_attendance.dart';
import '../../features/attendance/domain/usecases/save_office_location_locally.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';

// Camera
import '../../features/camera/data/datasources/camera_local_datasource.dart';
import '../../features/camera/data/datasources/image_queue_local_datasource.dart';
import '../../features/camera/data/repositories/camera_repository_impl.dart';
import '../../features/camera/data/repositories/image_sync_repository_impl.dart';
import '../../features/camera/domain/repositories/camera_repository.dart';
import '../../features/camera/domain/repositories/image_sync_repository.dart';
import '../../features/camera/domain/usecases/camera_usecases.dart';
import '../../features/camera/presentation/bloc/camera_bloc.dart';
import '../../features/camera/presentation/bloc/sync_bloc.dart';

final sl = GetIt.instance;

Future<void> initialiseDependencies() async {
  // ── External ──────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<Uuid>(() => const Uuid());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // ── Attendance Feature ────────────────────────────────────────────────────

  // Data Sources
  sl.registerLazySingleton<AttendanceLocalDataSource>(
        () => AttendanceLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<LocationRemoteDataSource>(
        () => LocationRemoteDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<AttendanceRepository>(
        () => AttendanceRepositoryImpl(
      localDataSource: sl(),
      locationDataSource: sl(),
    ),
  );

  // Services
  sl.registerLazySingleton(() => GeofenceCalculatorService());

  // Use Cases
  sl.registerLazySingleton(() => FetchCurrentLocation(sl()));
  sl.registerLazySingleton(() => SaveOfficeLocationLocally(sl()));
  sl.registerLazySingleton(() => LoadSavedOfficeLocation(sl()));
  sl.registerLazySingleton(() => CalculateDistanceInMeters(sl()));
  sl.registerLazySingleton(() => CheckIfUserIsWithinAllowedRadius(sl()));
  sl.registerLazySingleton(() => MarkAttendance(sl()));

  // BLoC
  sl.registerFactory<AttendanceBloc>(
        () => AttendanceBloc(
      fetchCurrentLocation: sl(),
      saveOfficeLocationLocally: sl(),
      loadSavedOfficeLocation: sl(),
      calculateDistanceInMeters: sl(),
      checkIfUserIsWithinAllowedRadius: sl(),
      markAttendance: sl(),
    ),
  );

  // ── Camera Feature ────────────────────────────────────────────────────────

  // Reopen Hive box if it was closed (can happen after backgrounding)
  if (!Hive.isBoxOpen(kImageBatchBoxName)) {
    await Hive.openBox<Map>(kImageBatchBoxName);
    debugPrint('[DI] ✅ Hive box reopened during DI init');
  }

  // Data Sources
  sl.registerLazySingleton<CameraLocalDatasource>(
        () => CameraLocalDatasourceImpl(uuid: sl()),
  );
  sl.registerLazySingleton<ImageQueueLocalDatasource>(
        () => ImageQueueLocalDatasourceImpl(
      box: Hive.box<Map>(kImageBatchBoxName),
    ),
  );

  // Repositories
  sl.registerLazySingleton<CameraRepository>(
        () => CameraRepositoryImpl(localDatasource: sl(), uuid: sl()),
  );
  sl.registerLazySingleton<ImageSyncRepository>(
        () => ImageSyncRepositoryImpl(localDatasource: sl(), uuid: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => InitializeCamera(sl()));
  sl.registerLazySingleton(() => CaptureImageAndStoreLocally(sl()));
  sl.registerLazySingleton(() => SetCameraZoomLevel(sl()));
  sl.registerLazySingleton(() => SetManualFocusPoint(sl()));
  sl.registerLazySingleton(() => AddImageToUploadQueue(sl()));
  sl.registerLazySingleton(() => RetrievePendingUploadQueue(sl()));
  sl.registerLazySingleton(() => AttemptUploadForPendingImages(sl()));
  sl.registerLazySingleton(() => RetryFailedUploadsWhenConnectionRestored(sl()));

  // BLoCs
  sl.registerFactory<CameraBloc>(
        () => CameraBloc(
      initializeCameraUseCase: sl(),
      captureImageUseCase: sl(),
      setZoomLevelUseCase: sl(),
      setFocusPointUseCase: sl(),
      addImageToQueueUseCase: sl(),
      cameraRepository: sl(),
    ),
  );
  sl.registerFactory<SyncBloc>(
        () => SyncBloc(
      retrievePendingQueueUseCase: sl(),
      attemptUploadUseCase: sl(),
      connectivity: sl(),
    ),
  );

  debugPrint('[DI] ✅ All dependencies registered');
}