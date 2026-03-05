/*
import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the screen initializes — loads any previously saved office location.
class AttendanceInitializedEvent extends AttendanceEvent {
  const AttendanceInitializedEvent();
}

/// Fired when user taps "Set Office Location".
/// Fetches current GPS coordinates and saves them as the office location.
class FetchAndSaveOfficeLocationRequested extends AttendanceEvent {
  const FetchAndSaveOfficeLocationRequested();
}

/// Fired to refresh the user's current GPS position and recalculate distance.
class RefreshCurrentLocationRequested extends AttendanceEvent {
  const RefreshCurrentLocationRequested();
}

/// Fired when user taps "Mark Attendance".
class MarkAttendanceRequested extends AttendanceEvent {
  const MarkAttendanceRequested();
}
*/




import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class InitializeAttendanceEvent extends AttendanceEvent {
  const InitializeAttendanceEvent();
}

class SetOfficeLocationEvent extends AttendanceEvent {
  const SetOfficeLocationEvent();
}

class RefreshUserLocationEvent extends AttendanceEvent {
  const RefreshUserLocationEvent();
}

class MarkAttendanceEvent extends AttendanceEvent {
  const MarkAttendanceEvent();
}