/*
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';

import '../constants/app_constants.dart';

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
import '../../features/camera/data/background/background_upload_worker.dart';
import '../../features/camera/data/datasources/camera_local_datasource.dart';
import '../../features/camera/data/datasources/image_queue_local_datasource.dart';
import '../../features/camera/data/repositories/camera_repository_impl.dart';
import '../../features/camera/data/repositories/image_sync_repository_impl.dart';
import '../../features/camera/domain/repositories/camera_repository.dart';
import '../../features/camera/domain/repositories/image_sync_repository.dart';
import '../../features/camera/domain/usecases/add_image_to_upload_queue.dart';
import '../../features/camera/domain/usecases/attempt_upload_for_pending_images.dart';
import '../../features/camera/domain/usecases/capture_image_and_store_locally.dart';
import '../../features/camera/domain/usecases/initialize_camera.dart';
import '../../features/camera/domain/usecases/retrieve_pending_upload_queue.dart';
import '../../features/camera/domain/usecases/retry_failed_uploads_when_connection_restored.dart';
import '../../features/camera/domain/usecases/set_camera_zoom_level.dart';
import '../../features/camera/domain/usecases/set_manual_focus_point.dart';
import '../../features/camera/presentation/bloc/camera_bloc.dart';
import '../../features/camera/presentation/bloc/sync_bloc.dart';

final GetIt serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  await _initializeHive();
  await _initializeWorkManager();
  _registerExternalDependencies();
  _registerAttendanceFeatureDependencies();
  _registerCameraFeatureDependencies();
}

Future<void> _initializeHive() async {
  await Hive.initFlutter();

  if (!Hive.isBoxOpen(AppConstants.officeLocationHiveBoxName)) {
    await Hive.openBox<String>(AppConstants.officeLocationHiveBoxName);
  }
  if (!Hive.isBoxOpen(AppConstants.attendanceHiveBoxName)) {
    await Hive.openBox<String>(AppConstants.attendanceHiveBoxName);
  }
  if (!Hive.isBoxOpen(AppConstants.imageQueueHiveBoxName)) {
    await Hive.openBox<String>(AppConstants.imageQueueHiveBoxName);
  }
}

Future<void> _initializeWorkManager() async {
  // Wrapped in try/catch — WorkManager.initialize() throws on emulators
  // without Google Play Services. The app must not crash or show black screen.
  try {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  } catch (e) {
    debugPrint('[WorkManager] init failed (emulator/no GPS?): $e');
  }
}

void _registerExternalDependencies() {
  serviceLocator.registerLazySingleton<HiveInterface>(() => Hive);
  serviceLocator.registerLazySingleton<Uuid>(() => const Uuid());
  serviceLocator.registerLazySingleton<Connectivity>(() => Connectivity());
}

void _registerAttendanceFeatureDependencies() {
  // --- Data Sources ---
  serviceLocator.registerLazySingleton<LocationRemoteDatasource>(
    () => const LocationRemoteDatasourceImpl(),
  );
  serviceLocator.registerLazySingleton<AttendanceLocalDatasource>(
    () => AttendanceLocalDatasourceImpl(
      hive: serviceLocator<HiveInterface>(),
    ),
  );

  // --- Repository ---
  serviceLocator.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      locationRemoteDatasource: serviceLocator<LocationRemoteDatasource>(),
      attendanceLocalDatasource: serviceLocator<AttendanceLocalDatasource>(),
    ),
  );

  // --- Domain Services ---
  serviceLocator.registerLazySingleton<GeofenceCalculatorService>(
    () => const GeofenceCalculatorService(),
  );

  // --- Use Cases ---
  serviceLocator.registerLazySingleton<FetchCurrentLocation>(
    () => FetchCurrentLocation(
      attendanceRepository: serviceLocator<AttendanceRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<SaveOfficeLocationLocally>(
    () => SaveOfficeLocationLocally(
      attendanceRepository: serviceLocator<AttendanceRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<LoadSavedOfficeLocation>(
    () => LoadSavedOfficeLocation(
      attendanceRepository: serviceLocator<AttendanceRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<CalculateDistanceInMeters>(
    () => CalculateDistanceInMeters(
      geofenceCalculatorService: serviceLocator<GeofenceCalculatorService>(),
    ),
  );
  serviceLocator.registerLazySingleton<CheckIfUserIsWithinAllowedRadius>(
    () => CheckIfUserIsWithinAllowedRadius(
      geofenceCalculatorService: serviceLocator<GeofenceCalculatorService>(),
    ),
  );
  serviceLocator.registerLazySingleton<MarkAttendance>(
    () => MarkAttendance(
      attendanceRepository: serviceLocator<AttendanceRepository>(),
    ),
  );

  // --- BLoC ---
  serviceLocator.registerFactory<AttendanceBloc>(
    () => AttendanceBloc(
      fetchCurrentLocation: serviceLocator<FetchCurrentLocation>(),
      saveOfficeLocationLocally: serviceLocator<SaveOfficeLocationLocally>(),
      loadSavedOfficeLocation: serviceLocator<LoadSavedOfficeLocation>(),
      calculateDistanceInMeters: serviceLocator<CalculateDistanceInMeters>(),
      checkIfUserIsWithinAllowedRadius:
          serviceLocator<CheckIfUserIsWithinAllowedRadius>(),
      markAttendance: serviceLocator<MarkAttendance>(),
      uuid: serviceLocator<Uuid>(),
    ),
  );
}

void _registerCameraFeatureDependencies() {
  // --- Data Sources ---
  serviceLocator.registerLazySingleton<CameraLocalDatasource>(
    () => const CameraLocalDatasourceImpl(),
  );
  serviceLocator.registerLazySingleton<ImageQueueLocalDatasource>(
    () => ImageQueueLocalDatasourceImpl(
      hive: serviceLocator<HiveInterface>(),
    ),
  );

  // --- Repositories ---
  // CameraRepositoryImpl is registered as a LazySingleton so the
  // CameraController it holds remains alive across use case calls.
  serviceLocator.registerLazySingleton<CameraRepositoryImpl>(
    () => CameraRepositoryImpl(
      cameraLocalDatasource: serviceLocator<CameraLocalDatasource>(),
      uuid: serviceLocator<Uuid>(),
    ),
  );
  serviceLocator.registerLazySingleton<CameraRepository>(
    () => serviceLocator<CameraRepositoryImpl>(),
  );
  serviceLocator.registerLazySingleton<ImageSyncRepository>(
    () => ImageSyncRepositoryImpl(
      imageQueueLocalDatasource: serviceLocator<ImageQueueLocalDatasource>(),
      connectivity: serviceLocator<Connectivity>(),
    ),
  );

  // --- Use Cases ---
  serviceLocator.registerLazySingleton<InitializeCamera>(
    () => InitializeCamera(
      cameraRepository: serviceLocator<CameraRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<CaptureImageAndStoreLocally>(
    () => CaptureImageAndStoreLocally(
      cameraRepository: serviceLocator<CameraRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<SetCameraZoomLevel>(
    () => SetCameraZoomLevel(
      cameraRepository: serviceLocator<CameraRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<SetManualFocusPoint>(
    () => SetManualFocusPoint(
      cameraRepository: serviceLocator<CameraRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<AddImageToUploadQueue>(
    () => AddImageToUploadQueue(
      imageSyncRepository: serviceLocator<ImageSyncRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<RetrievePendingUploadQueue>(
    () => RetrievePendingUploadQueue(
      imageSyncRepository: serviceLocator<ImageSyncRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<AttemptUploadForPendingImages>(
    () => AttemptUploadForPendingImages(
      imageSyncRepository: serviceLocator<ImageSyncRepository>(),
    ),
  );
  serviceLocator.registerLazySingleton<RetryFailedUploadsWhenConnectionRestored>(
    () => RetryFailedUploadsWhenConnectionRestored(
      imageSyncRepository: serviceLocator<ImageSyncRepository>(),
    ),
  );

  // --- BLoCs ---
  serviceLocator.registerFactory<CameraBloc>(
    () => CameraBloc(
      initializeCamera: serviceLocator<InitializeCamera>(),
      captureImageAndStoreLocally:
          serviceLocator<CaptureImageAndStoreLocally>(),
      setCameraZoomLevel: serviceLocator<SetCameraZoomLevel>(),
      setManualFocusPoint: serviceLocator<SetManualFocusPoint>(),
      cameraRepositoryImpl: serviceLocator<CameraRepositoryImpl>(),
    ),
  );
  serviceLocator.registerFactory<SyncBloc>(
    () => SyncBloc(
      addImageToUploadQueue: serviceLocator<AddImageToUploadQueue>(),
      retrievePendingUploadQueue:
          serviceLocator<RetrievePendingUploadQueue>(),
      attemptUploadForPendingImages:
          serviceLocator<AttemptUploadForPendingImages>(),
      retryFailedUploadsWhenConnectionRestored:
          serviceLocator<RetryFailedUploadsWhenConnectionRestored>(),
      imageSyncRepository: serviceLocator<ImageSyncRepository>(),
      connectivity: serviceLocator<Connectivity>(),
      uuid: serviceLocator<Uuid>(),
    ),
  );
}
*/


import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // ─── Attendance Feature ──────────────────────────────────────────────────

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

  // Use Cases
  sl.registerLazySingleton(() => FetchCurrentLocation(sl()));
  sl.registerLazySingleton(() => SaveOfficeLocationLocally(sl()));
  sl.registerLazySingleton(() => LoadSavedOfficeLocation(sl()));
  sl.registerLazySingleton(() => CalculateDistanceInMeters(sl()));
  sl.registerLazySingleton(() => CheckIfUserIsWithinAllowedRadius(sl()));
  sl.registerLazySingleton(() => MarkAttendance(sl()));

  // Repository
  sl.registerLazySingleton<AttendanceRepository>(
        () => AttendanceRepositoryImpl(
      localDataSource: sl(),
      locationDataSource: sl(),
    ),
  );

  // Data Sources
  sl.registerLazySingleton<AttendanceLocalDataSource>(
        () => AttendanceLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<LocationRemoteDataSource>(
        () => LocationRemoteDataSourceImpl(),
  );

  // Services
  sl.registerLazySingleton(() => GeofenceCalculatorService());
}