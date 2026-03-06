import '../../domain/entities/user_location.dart';

class UserLocationModel extends UserLocation {
  const UserLocationModel({
    required super.latitude,
    required super.longitude,
    super.accuracy,
    required super.fetchedAt,
  });

  factory UserLocationModel.fromGeolocator({
    required double latitude,
    required double longitude,
    double? accuracy,
  }) {
    return UserLocationModel(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      fetchedAt: DateTime.now(),
    );
  }
}