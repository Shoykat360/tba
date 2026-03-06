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