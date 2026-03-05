/*
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart' as Error;
import '../models/user_location_model.dart';

abstract class LocationRemoteDatasource {
  /// Checks permissions, then fetches the device's current GPS coordinates.
  Future<UserLocationModel> getCurrentDeviceLocation();
}

class LocationRemoteDatasourceImpl implements LocationRemoteDatasource {
  const LocationRemoteDatasourceImpl();

  @override
  Future<UserLocationModel> getCurrentDeviceLocation() async {
    await _assertLocationServiceIsEnabled();
    await _assertLocationPermissionIsGranted();
    return await _fetchDevicePosition();
  }

  Future<void> _assertLocationServiceIsEnabled() async {
    final bool isLocationServiceEnabled =
    await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      throw const LocationServiceDisabledException();
    }
  }

  /// Checks and, if needed, requests location permission.
  ///
  /// Throws [LocationPermissionPermanentlyDeniedException] if the system has
  /// permanently blocked the permission dialog (must redirect to app settings).
  /// Throws [LocationPermissionDeniedException] if the user actively denied the
  /// one-time prompt.
  Future<void> _assertLocationPermissionIsGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();

    // Guard permanently-denied BEFORE attempting to request, so we never try
    // to show the dialog when the OS has already blocked it.
    if (permission == LocationPermission.deniedForever) {
      throw const Error.LocationPermissionPermanentlyDeniedException();
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      // After requesting, the user may have chosen "never ask again", which
      // causes requestPermission() to return deniedForever, not just denied.
      if (permission == LocationPermission.deniedForever) {
        throw const Error.LocationPermissionPermanentlyDeniedException();
      }

      if (permission == LocationPermission.denied) {
        throw const Error.LocationPermissionDeniedException();
      }
    }
  }

  Future<UserLocationModel> _fetchDevicePosition() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(
          seconds: AppConstants.locationTimeoutSeconds,
        ),
      );
      return UserLocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        fetchedAt: DateTime.now(),
      );
    } catch (e) {
      throw Error.LocationFetchException(
        message: 'Failed to fetch current location: ${e.toString()}',
      );
    }
  }
}
*/


import 'package:geolocator/geolocator.dart' hide LocationServiceDisabledException;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_location_model.dart';

abstract class LocationRemoteDataSource {
  Future<UserLocationModel> getCurrentLocation();
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  @override
  Future<UserLocationModel> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationPermissionException('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionException(
          'Location permission permanently denied. Please enable it in settings.');
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: AppConstants.locationTimeoutSeconds),
      );

      return UserLocationModel.fromGeolocator(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } catch (e) {
      throw LocationFetchException('Failed to fetch GPS location: $e');
    }
  }
}