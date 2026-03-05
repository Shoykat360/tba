/*
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attendance_record.dart';
import '../entities/office_location.dart';
import '../entities/user_location.dart';

/// Defines the contract for all attendance data operations.
///
/// Pure computation (distance calculation, geofence checks) is intentionally
/// excluded — those responsibilities belong to [GeofenceCalculatorService].
/// This repository handles only I/O: location fetching and local persistence.
abstract class AttendanceRepository {
  /// Fetches the current GPS coordinates of the user.
  /// Handles location permission and service checks internally.
  Future<Either<Failure, UserLocation>> fetchCurrentUserLocation();

  /// Persists the given [officeLocation] to local storage.
  Future<Either<Failure, void>> saveOfficeLocationLocally(
    OfficeLocation officeLocation,
  );

  /// Retrieves the previously saved office location from local storage.
  /// Returns [NoSavedOfficeLocationFailure] if none exists.
  Future<Either<Failure, OfficeLocation>> loadSavedOfficeLocation();

  /// Saves an attendance record locally.
  Future<Either<Failure, void>> markAttendanceLocally(
    AttendanceRecord record,
  );

  /// Retrieves all saved attendance records from local storage.
  Future<Either<Failure, List<AttendanceRecord>>> loadAttendanceRecords();
}
*/


import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attendance_record.dart';
import '../entities/office_location.dart';
import '../entities/user_location.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, UserLocation>> fetchCurrentLocation();
  Future<Either<Failure, Unit>> saveOfficeLocation(OfficeLocation location);
  Future<Either<Failure, OfficeLocation>> loadSavedOfficeLocation();
  Future<Either<Failure, Unit>> markAttendance(AttendanceRecord record);
  Future<Either<Failure, List<AttendanceRecord>>> getAttendanceHistory();
}