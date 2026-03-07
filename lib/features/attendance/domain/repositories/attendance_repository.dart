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
