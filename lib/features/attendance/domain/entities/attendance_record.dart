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