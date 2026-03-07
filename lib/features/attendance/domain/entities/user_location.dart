import 'package:equatable/equatable.dart';

class UserLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime fetchedAt;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.fetchedAt,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracy, fetchedAt];
}
