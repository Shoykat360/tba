/*
import 'package:equatable/equatable.dart';

class AttendanceRecord extends Equatable {
  final String id;
  final DateTime markedAt;
  final double latitude;
  final double longitude;
  final double distanceFromOfficeInMeters;

  const AttendanceRecord({
    required this.id,
    required this.markedAt,
    required this.latitude,
    required this.longitude,
    required this.distanceFromOfficeInMeters,
  });

  @override
  List<Object?> get props => [
        id,
        markedAt,
        latitude,
        longitude,
        distanceFromOfficeInMeters,
      ];
}
*/
import 'package:equatable/equatable.dart';

class AttendanceRecord extends Equatable {
  final String id;
  final double latitude;
  final double longitude;
  final DateTime markedAt;
  final double distanceFromOffice;

  const AttendanceRecord({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.markedAt,
    required this.distanceFromOffice,
  });

  @override
  List<Object> get props => [id, latitude, longitude, markedAt, distanceFromOffice];
}