import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

/// Fired once when the attendance screen is first opened.
/// Loads saved office location and fetches the user's current GPS position.
class InitializeAttendanceScreen extends AttendanceEvent {
  const InitializeAttendanceScreen();
}

/// Fired when the user taps "Set Office Location".
/// Saves the current GPS coordinates as the office location.
class SaveCurrentLocationAsOffice extends AttendanceEvent {
  const SaveCurrentLocationAsOffice();
}

/// Fired when the user pulls to refresh or taps the refresh icon.
/// Re-fetches the user's current GPS position.
class RefreshCurrentUserLocation extends AttendanceEvent {
  const RefreshCurrentUserLocation();
}

/// Fired when the user taps "Mark Attendance".
/// Saves a new attendance record if the user is inside the geofence.
class ConfirmAttendanceMarking extends AttendanceEvent {
  const ConfirmAttendanceMarking();
}
