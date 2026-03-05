/*class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // Attendance Feature
  // ---------------------------------------------------------------------------

  static const double geofenceRadiusInMeters = 50.0;

  static const String officeLocationHiveBoxName = 'office_location_box';
  static const String officeLocationHiveKey = 'saved_office_location';

  static const String attendanceHiveBoxName = 'attendance_box';

  /// Prefix used to namespace individual attendance record keys in Hive.
  static const String attendanceRecordKeyPrefix = 'attendance_record:';

  static const int locationTimeoutSeconds = 15;

  // ---------------------------------------------------------------------------
  // Camera Feature
  // ---------------------------------------------------------------------------

  static const String imageQueueHiveBoxName = 'image_queue_box';
  static const String imageQueueHiveKey = 'pending_image_queue';

  static const String capturedImagesDirName = 'captured_images';

  /// Simulated upload duration for the fake API call.
  static const int simulatedUploadDurationMs = 1500;

  /// Maximum consecutive upload retries before a batch is marked failed.
  static const int maxUploadRetryCount = 3;

  /// WorkManager registered callback name — must match callbackDispatcher.
  static const String backgroundUploadTaskName =
      'com.example.tba_task.background_upload';

  /// Unique task name prevents duplicate background tasks in WorkManager queue.
  static const String backgroundUploadUniqueTaskName =
      'tba_task_upload_task';

  static const double cameraMinZoomLevel = 1.0;
  static const double cameraMaxZoomFallback = 8.0;
}*/
class AppConstants {
  AppConstants._();

  // Geofence
  static const double geofenceRadiusMeters = 50.0;

  // Storage Keys
  static const String officeLocationKey = 'office_location';
  static const String attendanceBoxName = 'attendance_box';
  static const String attendanceRecordsKey = 'attendance_records';

  // Location
  static const int locationTimeoutSeconds = 15;

  // Attendance
  static const double allowedRadiusMeters = 50.0;

  // Camera / Sync
  static const String imageBatchesKey = 'image_batches_queue';
  static const String backgroundUploadTaskName = 'background_image_upload';
}