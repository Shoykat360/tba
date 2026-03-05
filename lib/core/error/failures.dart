import 'package:equatable/equatable.dart';

/*abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

class LocationPermissionDeniedFailure extends Failure {
  const LocationPermissionDeniedFailure()
      : super(message: 'Location permission has been denied.');
}

class LocationPermissionPermanentlyDeniedFailure extends Failure {
  const LocationPermissionPermanentlyDeniedFailure()
      : super(
            message:
                'Location permission is permanently denied. Please enable it from app settings.');
}

class LocationServiceDisabledFailure extends Failure {
  const LocationServiceDisabledFailure()
      : super(
            message:
                'Location services are disabled. Please enable GPS on your device.');
}

class LocationFetchFailure extends Failure {
  const LocationFetchFailure({required super.message});
}

class LocalStorageFailure extends Failure {
  const LocalStorageFailure({required super.message});
}

/// Returned when no office location has been persisted yet.
/// This is an expected first-run condition, not a fatal error.
class NoSavedOfficeLocationFailure extends Failure {
  const NoSavedOfficeLocationFailure()
      : super(message: 'No office location has been saved yet.');
}

class AttendanceAlreadyMarkedFailure extends Failure {
  const AttendanceAlreadyMarkedFailure()
      : super(message: 'Attendance has already been marked for today.');
}

class OutsideGeofenceFailure extends Failure {
  const OutsideGeofenceFailure({required super.message});
}

class InvalidGeofenceStateFailure extends Failure {
  const InvalidGeofenceStateFailure({required super.message});
}

// =============================================================================
// Camera Feature Failures
// =============================================================================

class CameraPermissionDeniedFailure extends Failure {
  const CameraPermissionDeniedFailure()
      : super(message: 'Camera permission has been denied.');
}

class CameraPermissionPermanentlyDeniedFailure extends Failure {
  const CameraPermissionPermanentlyDeniedFailure()
      : super(
            message:
                'Camera permission is permanently denied. Please enable it from app settings.');
}

class CameraInitializationFailure extends Failure {
  const CameraInitializationFailure({required super.message});
}

class CameraHardwareUnavailableFailure extends Failure {
  const CameraHardwareUnavailableFailure()
      : super(message: 'No camera hardware was detected on this device.');
}

class CaptureFailure extends Failure {
  const CaptureFailure({required super.message});
}

class ImageStorageFailure extends Failure {
  const ImageStorageFailure({required super.message});
}

class UploadFailure extends Failure {
  const UploadFailure({required super.message});
}

class ConnectivityFailure extends Failure {
  const ConnectivityFailure()
      : super(
            message:
                'No internet connection. Image will be queued for later upload.');
}

class EmptyQueueFailure extends Failure {
  const EmptyQueueFailure()
      : super(message: 'No pending images in the upload queue.');
}*/


abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure(
      [super.message = 'Location permission denied.']);
}

class LocationServiceDisabledFailure extends Failure {
  const LocationServiceDisabledFailure(
      [super.message = 'Location services are disabled.']);
}

class LocationFetchFailure extends Failure {
  const LocationFetchFailure([super.message = 'Failed to fetch location.']);
}

class LocalStorageFailure extends Failure {
  const LocalStorageFailure([super.message = 'Local storage operation failed.']);
}

class NoSavedLocationFailure extends Failure {
  const NoSavedLocationFailure(
      [super.message = 'No office location has been saved.']);
}

