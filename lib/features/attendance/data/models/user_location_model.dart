/*
import '../../domain/entities/user_location.dart';

class UserLocationModel {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime fetchedAt;

  const UserLocationModel({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.fetchedAt,
  });

  UserLocation toEntity() {
    return UserLocation(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      fetchedAt: fetchedAt,
    );
  }
}
*/


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