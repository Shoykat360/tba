/*class LocationPermissionDeniedException implements Exception {
  final String message;
  const LocationPermissionDeniedException(
      {this.message = 'Location permission denied.'});
}

class LocationPermissionPermanentlyDeniedException implements Exception {
  final String message;
  const LocationPermissionPermanentlyDeniedException(
      {this.message = 'Location permission permanently denied.'});
}

class LocationServiceDisabledException implements Exception {
  final String message;
  const LocationServiceDisabledException(
      {this.message = 'Location services are disabled.'});
}

class LocationFetchException implements Exception {
  final String message;
  const LocationFetchException({required this.message});
}

class LocalStorageException implements Exception {
  final String message;
  const LocalStorageException({required this.message});
}

class NoSavedOfficeLocationException implements Exception {
  final String message;
  const NoSavedOfficeLocationException(
      {this.message = 'No office location saved.'});
}

// =============================================================================
// Camera Feature Exceptions
// =============================================================================

class CameraPermissionDeniedException implements Exception {
  final String message;
  const CameraPermissionDeniedException(
      {this.message = 'Camera permission denied.'});
}

class CameraPermissionPermanentlyDeniedException implements Exception {
  final String message;
  const CameraPermissionPermanentlyDeniedException(
      {this.message = 'Camera permission permanently denied.'});
}

class CameraInitializationException implements Exception {
  final String message;
  const CameraInitializationException({required this.message});
}

class CameraHardwareUnavailableException implements Exception {
  final String message;
  const CameraHardwareUnavailableException(
      {this.message = 'No camera hardware detected.'});
}

class CaptureException implements Exception {
  final String message;
  const CaptureException({required this.message});
}

class ImageStorageException implements Exception {
  final String message;
  const ImageStorageException({required this.message});
}

class UploadException implements Exception {
  final String message;
  const UploadException({required this.message});
}*/


class LocationPermissionException implements Exception {
  final String message;
  const LocationPermissionException(
      [this.message = 'Location permission denied.']);
}

class LocationServiceDisabledException implements Exception {
  final String message;
  const LocationServiceDisabledException(
      [this.message = 'Location services are disabled.']);
}

class LocationFetchException implements Exception {
  final String message;
  const LocationFetchException([this.message = 'Failed to fetch location.']);
}

class LocalStorageException implements Exception {
  final String message;
  const LocalStorageException(
      [this.message = 'Local storage operation failed.']);
}

class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);
}

class CameraHardwareException implements Exception {
  final String message;
  const CameraHardwareException(this.message);
}