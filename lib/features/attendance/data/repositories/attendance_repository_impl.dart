/*
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

/// Implements [AttendanceRepository] by coordinating between the location
/// datasource and the local persistence datasource.
///
/// Distance calculation and geofence logic are NOT implemented here — those
/// are delegated to [GeofenceCalculatorService] in the domain layer.
class AttendanceRepositoryImpl implements AttendanceRepository {
  final LocationRemoteDatasource _locationRemoteDatasource;
  final AttendanceLocalDatasource _attendanceLocalDatasource;

  const AttendanceRepositoryImpl({
    required LocationRemoteDatasource locationRemoteDatasource,
    required AttendanceLocalDatasource attendanceLocalDatasource,
  })  : _locationRemoteDatasource = locationRemoteDatasource,
        _attendanceLocalDatasource = attendanceLocalDatasource;

  @override
  Future<Either<Failure, UserLocation>> fetchCurrentUserLocation() async {
    try {
      final userLocationModel =
          await _locationRemoteDatasource.getCurrentDeviceLocation();
      return Right(userLocationModel.toEntity());
    } on LocationServiceDisabledException {
      return const Left(LocationServiceDisabledFailure());
    } on LocationPermissionDeniedException {
      return const Left(LocationPermissionDeniedFailure());
    } on LocationPermissionPermanentlyDeniedException {
      return const Left(LocationPermissionPermanentlyDeniedFailure());
    } on LocationFetchException catch (e) {
      return Left(LocationFetchFailure(message: e.message));
    } catch (e) {
      return Left(
        LocationFetchFailure(
          message: 'An unexpected error occurred while fetching location: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> saveOfficeLocationLocally(
    OfficeLocation officeLocation,
  ) async {
    try {
      final OfficeLocationModel model =
          OfficeLocationModel.fromEntity(officeLocation);
      await _attendanceLocalDatasource.saveOfficeLocation(model);
      return const Right(null);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message));
    } catch (e) {
      return Left(
        LocalStorageFailure(
          message: 'Failed to save office location: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, OfficeLocation>> loadSavedOfficeLocation() async {
    try {
      final OfficeLocationModel model =
          await _attendanceLocalDatasource.getSavedOfficeLocation();
      return Right(model.toEntity());
    } on NoSavedOfficeLocationException {
      return const Left(NoSavedOfficeLocationFailure());
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message));
    } catch (e) {
      return Left(
        LocalStorageFailure(
          message: 'Failed to load office location: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markAttendanceLocally(
    AttendanceRecord record,
  ) async {
    try {
      final AttendanceRecordModel model =
          AttendanceRecordModel.fromEntity(record);
      await _attendanceLocalDatasource.saveAttendanceRecord(model);
      return const Right(null);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message));
    } catch (e) {
      return Left(
        LocalStorageFailure(
          message: 'Failed to save attendance record: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<AttendanceRecord>>> loadAttendanceRecords() async {
    try {
      final records =
          await _attendanceLocalDatasource.getAllAttendanceRecords();
      return Right(records.map((model) => model.toEntity()).toList());
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(message: e.message));
    } catch (e) {
      return Left(
        LocalStorageFailure(
          message: 'Failed to load attendance records: ${e.toString()}',
        ),
      );
    }
  }
}
*/


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
      final location = await locationDataSource.getCurrentLocation();
      return Right(location);
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
  Future<Either<Failure, Unit>> saveOfficeLocation(OfficeLocation location) async {
    try {
      await localDataSource.saveOfficeLocation(
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
      final model = await localDataSource.loadOfficeLocation();
      return Right(model);
    } on LocalStorageException catch (e) {
      if (e.message.contains('No office location')) {
        return const Left(NoSavedLocationFailure());
      }
      return Left(LocalStorageFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> markAttendance(AttendanceRecord record) async {
    try {
      await localDataSource.saveAttendanceRecord(
        AttendanceRecordModel.fromEntity(record),
      );
      return const Right(unit);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceRecord>>> getAttendanceHistory() async {
    try {
      final records = await localDataSource.getAttendanceRecords();
      return Right(records);
    } on LocalStorageException catch (e) {
      return Left(LocalStorageFailure(e.message));
    }
  }
}