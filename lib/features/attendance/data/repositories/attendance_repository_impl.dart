import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/office_location.dart';
import '../../domain/entities/user_location.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_local_datasource.dart';
import '../datasources/location_remote_datasource.dart';
import '../models/attendance_record_model.dart';
import '../models/office_location_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceLocalDataSource localDataSource;
  final LocationRemoteDataSource locationDataSource;

  AttendanceRepositoryImpl({
    required this.localDataSource,
    required this.locationDataSource,
  });

  @override
  Future<Either<Failure, UserLocation>> fetchCurrentLocation() async {
    try {
      final UserLocation userLocation =
          await locationDataSource.fetchLiveGpsLocation();
      return Right(userLocation);
    } on LocationPermissionException catch (e) {
      return Left(LocationPermissionFailure(e.message));
    } on LocationServiceDisabledException catch (e) {
      return Left(LocationServiceDisabledFailure(e.message));
    } on LocationFetchException catch (e) {
      return Left(LocationFetchFailure(e.message));
    } catch (e) {
      return Left(LocationFetchFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveOfficeLocation(
      OfficeLocation location) async {
    try {
      await localDataSource.saveOfficeLocationToStorage(
        OfficeLocationModel.fromEntity(location),
      );
      return const Right(unit);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, OfficeLocation>> loadSavedOfficeLocation() async {
    try {
      final OfficeLocationModel officeLocation =
          await localDataSource.readOfficeLocationFromStorage();
      return Right(officeLocation);
    } on LocalStorageException catch (e) {
      if (e.message.contains('No office location')) {
        return const Left(NoSavedLocationFailure());
      }
      return Left(LocalStorageFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAttendance(
      AttendanceRecord record) async {
    try {
      await localDataSource.saveAttendanceRecordToStorage(
        AttendanceRecordModel.fromEntity(record),
      );
      return const Right(unit);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceRecord>>>
      getAttendanceHistory() async {
    try {
      final List<AttendanceRecordModel> records =
          await localDataSource.readAllAttendanceRecordsFromStorage();
      return Right(records);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(e.message));
    }
  }
}
