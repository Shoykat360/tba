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


  // Camera / Sync
  static const String imageBatchesKey = 'image_batches_queue';
  static const String backgroundUploadTaskName = 'background_image_upload';
}