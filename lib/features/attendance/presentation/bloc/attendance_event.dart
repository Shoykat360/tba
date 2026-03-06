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