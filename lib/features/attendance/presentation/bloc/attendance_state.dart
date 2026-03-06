import 'package:equatable/equatable.dart';

import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/office_location.dart';
import '../../domain/entities/user_location.dart';

enum AttendanceStatus { initial, loading, loaded, success, failure }
enum LocationSetStatus { notSet, setting, set, failure }

class AttendanceState extends Equatable {
  final AttendanceStatus status;
  final LocationSetStatus locationSetStatus;

  // Location data
  final UserLocation? userLocation;
  final OfficeLocation? officeLocation;
  final double? distanceInMeters;
  final bool isWithinRadius;

  // Attendance
  final List<AttendanceRecord> attendanceHistory;
  final bool isMarkingAttendance;
  final bool attendanceMarkedSuccessfully;

  // Error
  final String? errorMessage;
  final String? locationSetError;

  const AttendanceState({
    this.status = AttendanceStatus.initial,
    this.locationSetStatus = LocationSetStatus.notSet,
    this.userLocation,
    this.officeLocation,
    this.distanceInMeters,
    this.isWithinRadius = false,
    this.attendanceHistory = const [],
    this.isMarkingAttendance = false,
    this.attendanceMarkedSuccessfully = false,
    this.errorMessage,
    this.locationSetError,
  });

  bool get canMarkAttendance =>
      isWithinRadius &&
          officeLocation != null &&
          userLocation != null &&
          !isMarkingAttendance;

  AttendanceState copyWith({
    AttendanceStatus? status,
    LocationSetStatus? locationSetStatus,
    UserLocation? userLocation,
    OfficeLocation? officeLocation,
    double? distanceInMeters,
    bool? isWithinRadius,
    List<AttendanceRecord>? attendanceHistory,
    bool? isMarkingAttendance,
    bool? attendanceMarkedSuccessfully,
    String? errorMessage,
    String? locationSetError,
    bool clearError = false,
    bool clearLocationSetError = false,
    bool clearAttendanceSuccess = false,
    bool clearDistance = false,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      locationSetStatus: locationSetStatus ?? this.locationSetStatus,
      userLocation: userLocation ?? this.userLocation,
      officeLocation: officeLocation ?? this.officeLocation,
      distanceInMeters: clearDistance ? null : (distanceInMeters ?? this.distanceInMeters),
      isWithinRadius: isWithinRadius ?? this.isWithinRadius,
      attendanceHistory: attendanceHistory ?? this.attendanceHistory,
      isMarkingAttendance: isMarkingAttendance ?? this.isMarkingAttendance,
      attendanceMarkedSuccessfully: clearAttendanceSuccess
          ? false
          : (attendanceMarkedSuccessfully ?? this.attendanceMarkedSuccessfully),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      locationSetError: clearLocationSetError
          ? null
          : (locationSetError ?? this.locationSetError),
    );
  }

  @override
  List<Object?> get props => [
    status,
    locationSetStatus,
    userLocation,
    officeLocation,
    distanceInMeters,
    isWithinRadius,
    attendanceHistory,
    isMarkingAttendance,
    attendanceMarkedSuccessfully,
    errorMessage,
    locationSetError,
  ];
}