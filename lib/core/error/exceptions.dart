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