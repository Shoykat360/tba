import 'package:geolocator/geolocator.dart' hide LocationServiceDisabledException;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_location_model.dart';

abstract class LocationRemoteDataSource {
  Future<UserLocationModel> fetchLiveGpsLocation();
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  @override
  Future<UserLocationModel> fetchLiveGpsLocation() async {
    await ensureLocationServiceIsEnabled();
    await ensureLocationPermissionIsGranted();

    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: AppConstants.locationTimeoutSeconds),
      );

      return UserLocationModel.fromGeolocatorPosition(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } catch (e) {
      throw LocationFetchException('Failed to fetch GPS location: $e');
    }
  }

  // Checks that the device location service (GPS) is turned on.
  Future<void> ensureLocationServiceIsEnabled() async {
    final bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw const LocationServiceDisabledException();
    }
  }

  // Checks and requests location permission if not already granted.
  Future<void> ensureLocationPermissionIsGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationPermissionException('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionException(
        'Location permission permanently denied. Please enable it in settings.',
      );
    }
  }
}
