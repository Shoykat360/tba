import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure([super.message = 'Location permission denied.']);
}

class LocationServiceDisabledFailure extends Failure {
  const LocationServiceDisabledFailure([super.message = 'Location services are disabled.']);
}

class LocationFetchFailure extends Failure {
  const LocationFetchFailure([super.message = 'Failed to fetch location.']);
}

class LocalStorageFailure extends Failure {
  const LocalStorageFailure([super.message = 'Local storage operation failed.']);
}

class NoSavedLocationFailure extends Failure {
  const NoSavedLocationFailure([super.message = 'No office location has been saved.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache operation failed.']);
}

class CameraFailure extends Failure {
  const CameraFailure([super.message = 'Camera operation failed.']);
}
