import 'package:equatable/equatable.dart';

import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/office_location.dart';
import '../../domain/entities/user_location.dart';

enum AttendanceStatus { initial, loading, loaded, failure }

enum LocationSetStatus { notSet, saving, saved, failure }

class AttendanceState extends Equatable {
  final AttendanceStatus status;
  final LocationSetStatus locationSetStatus;

  // Location data
  final UserLocation? userLocation;
  final OfficeLocation? officeLocation;
  final double? distanceFromOfficeInMeters;
  final bool isUserInsideGeofence;

  // Attendance
  final List<AttendanceRecord> attendanceHistory;
  final bool isSavingAttendance;
  final bool attendanceJustMarkedSuccessfully;

  // Errors
  final String? generalErrorMessage;
  final String? locationSaveErrorMessage;

  const AttendanceState({
    this.status = AttendanceStatus.initial,
    this.locationSetStatus = LocationSetStatus.notSet,
    this.userLocation,
    this.officeLocation,
    this.distanceFromOfficeInMeters,
    this.isUserInsideGeofence = false,
    this.attendanceHistory = const [],
    this.isSavingAttendance = false,
    this.attendanceJustMarkedSuccessfully = false,
    this.generalErrorMessage,
    this.locationSaveErrorMessage,
  });

  /// True only when all conditions are met for marking attendance.
  bool get canMarkAttendance =>
      isUserInsideGeofence &&
      officeLocation != null &&
      userLocation != null &&
      !isSavingAttendance;

  AttendanceState copyWith({
    AttendanceStatus? status,
    LocationSetStatus? locationSetStatus,
    UserLocation? userLocation,
    OfficeLocation? officeLocation,
    double? distanceFromOfficeInMeters,
    bool? isUserInsideGeofence,
    List<AttendanceRecord>? attendanceHistory,
    bool? isSavingAttendance,
    bool? attendanceJustMarkedSuccessfully,
    String? generalErrorMessage,
    String? locationSaveErrorMessage,
    bool clearGeneralError = false,
    bool clearLocationSaveError = false,
    bool clearAttendanceSuccessFlag = false,
    bool clearDistanceData = false,
  }) {
    return AttendanceState(
      status: status ?? this.status,
      locationSetStatus: locationSetStatus ?? this.locationSetStatus,
      userLocation: userLocation ?? this.userLocation,
      officeLocation: officeLocation ?? this.officeLocation,
      distanceFromOfficeInMeters: clearDistanceData
          ? null
          : (distanceFromOfficeInMeters ?? this.distanceFromOfficeInMeters),
      isUserInsideGeofence: isUserInsideGeofence ?? this.isUserInsideGeofence,
      attendanceHistory: attendanceHistory ?? this.attendanceHistory,
      isSavingAttendance: isSavingAttendance ?? this.isSavingAttendance,
      attendanceJustMarkedSuccessfully: clearAttendanceSuccessFlag
          ? false
          : (attendanceJustMarkedSuccessfully ??
              this.attendanceJustMarkedSuccessfully),
      generalErrorMessage: clearGeneralError
          ? null
          : (generalErrorMessage ?? this.generalErrorMessage),
      locationSaveErrorMessage: clearLocationSaveError
          ? null
          : (locationSaveErrorMessage ?? this.locationSaveErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        locationSetStatus,
        userLocation,
        officeLocation,
        distanceFromOfficeInMeters,
        isUserInsideGeofence,
        attendanceHistory,
        isSavingAttendance,
        attendanceJustMarkedSuccessfully,
        generalErrorMessage,
        locationSaveErrorMessage,
      ];
}
