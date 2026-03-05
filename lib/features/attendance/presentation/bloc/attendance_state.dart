/*
import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/office_location.dart';
import '../../domain/entities/user_location.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded on startup.
class AttendanceInitialState extends AttendanceState {
  const AttendanceInitialState();
}

/// Emitted only during the initial load on startup — replaces the full screen.
/// For subsequent operations (refresh, mark) we use [AttendanceLoadedState.isRefreshing]
/// so the screen does not flash back to a loader after data is already visible.
class AttendanceLoadingState extends AttendanceState {
  final String loadingMessage;

  const AttendanceLoadingState({required this.loadingMessage});

  @override
  List<Object?> get props => [loadingMessage];
}

/// Primary data-bearing state. Emitted after initial load and on every
/// successful location refresh or attendance operation.
///
/// [isRefreshing] is true while a background operation is in progress but
/// data is already visible — the UI shows an inline indicator instead of
/// replacing the entire screen with a loader.
class AttendanceLoadedState extends AttendanceState {
  /// The last known office location. Null if never set.
  final OfficeLocation? savedOfficeLocation;

  /// The user's current GPS location. Null if not yet fetched.
  final UserLocation? currentUserLocation;

  /// Calculated distance in meters from user to office.
  /// Null if either location is missing.
  final double? distanceFromOfficeInMeters;

  /// Whether the user is inside the 50-meter geofence.
  final bool isWithinGeofence;

  /// Whether attendance has been successfully marked in this session.
  final bool hasMarkedAttendanceToday;

  /// Most recently marked attendance record, if any.
  final AttendanceRecord? latestAttendanceRecord;

  /// True while a background async operation (refresh, save, mark) is running.
  /// The screen remains visible with an inline loading indicator.
  final bool isRefreshing;

  const AttendanceLoadedState({
    this.savedOfficeLocation,
    this.currentUserLocation,
    this.distanceFromOfficeInMeters,
    required this.isWithinGeofence,
    required this.hasMarkedAttendanceToday,
    this.latestAttendanceRecord,
    this.isRefreshing = false,
  });

  AttendanceLoadedState copyWith({
    OfficeLocation? savedOfficeLocation,
    UserLocation? currentUserLocation,
    double? distanceFromOfficeInMeters,
    bool? isWithinGeofence,
    bool? hasMarkedAttendanceToday,
    AttendanceRecord? latestAttendanceRecord,
    bool? isRefreshing,
  }) {
    return AttendanceLoadedState(
      savedOfficeLocation: savedOfficeLocation ?? this.savedOfficeLocation,
      currentUserLocation: currentUserLocation ?? this.currentUserLocation,
      distanceFromOfficeInMeters:
          distanceFromOfficeInMeters ?? this.distanceFromOfficeInMeters,
      isWithinGeofence: isWithinGeofence ?? this.isWithinGeofence,
      hasMarkedAttendanceToday:
          hasMarkedAttendanceToday ?? this.hasMarkedAttendanceToday,
      latestAttendanceRecord:
          latestAttendanceRecord ?? this.latestAttendanceRecord,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  /// Returns a copy with [isRefreshing] set to true.
  /// Used to trigger an inline loading indicator without destroying screen state.
  AttendanceLoadedState asRefreshing() => copyWith(isRefreshing: true);

  /// Returns a copy with [isRefreshing] set to false.
  AttendanceLoadedState asIdle() => copyWith(isRefreshing: false);

  @override
  List<Object?> get props => [
        savedOfficeLocation,
        currentUserLocation,
        distanceFromOfficeInMeters,
        isWithinGeofence,
        hasMarkedAttendanceToday,
        latestAttendanceRecord,
        isRefreshing,
      ];
}

/// One-shot state emitted immediately after a successful attendance mark.
/// The BlocConsumer listener handles the snackbar, then the BLoC emits
/// [AttendanceLoadedState] to restore the view.
class AttendanceMarkedSuccessState extends AttendanceState {
  final AttendanceRecord markedRecord;

  const AttendanceMarkedSuccessState({required this.markedRecord});

  @override
  List<Object?> get props => [markedRecord];
}

/// Emitted when the user has denied location permission.
class AttendancePermissionDeniedState extends AttendanceState {
  final String errorMessage;

  /// True when the system will no longer show the permission dialog.
  /// The UI should prompt the user to open app settings instead of retrying.
  final bool isPermanentlyDenied;

  const AttendancePermissionDeniedState({
    required this.errorMessage,
    required this.isPermanentlyDenied,
  });

  @override
  List<Object?> get props => [errorMessage, isPermanentlyDenied];
}

/// Emitted when the device's location service (GPS) is switched off.
class AttendanceLocationServiceDisabledState extends AttendanceState {
  final String errorMessage;

  const AttendanceLocationServiceDisabledState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

/// Emitted for all other recoverable errors (storage failures, GPS timeout, etc.).
class AttendanceErrorState extends AttendanceState {
  final String errorMessage;

  const AttendanceErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
*/



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