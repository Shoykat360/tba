import 'package:equatable/equatable.dart';

/*class OfficeLocation extends Equatable {
  final double latitude;
  final double longitude;
  final DateTime savedAt;

  const OfficeLocation({
    required this.latitude,
    required this.longitude,
    required this.savedAt,
  });

  @override
  List<Object?> get props => [latitude, longitude, savedAt];
}*/


class OfficeLocation extends Equatable {
  final double latitude;
  final double longitude;
  final DateTime savedAt;

  const OfficeLocation({
    required this.latitude,
    required this.longitude,
    required this.savedAt,
  });

  @override
  List<Object> get props => [latitude, longitude, savedAt];
}