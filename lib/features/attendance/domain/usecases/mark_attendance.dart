/*
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class MarkAttendanceParams {
  final AttendanceRecord record;

  const MarkAttendanceParams({required this.record});
}

class MarkAttendance implements UseCase<void, MarkAttendanceParams> {
  final AttendanceRepository _attendanceRepository;

  const MarkAttendance({
    required AttendanceRepository attendanceRepository,
  }) : _attendanceRepository = attendanceRepository;

  @override
  Future<Either<Failure, void>> call(MarkAttendanceParams params) async {
    return await _attendanceRepository.markAttendanceLocally(params.record);
  }
}
*/


import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class MarkAttendance extends UseCase<Unit, MarkAttendanceParams> {
  final AttendanceRepository repository;

  MarkAttendance(this.repository);

  @override
  Future<Either<Failure, Unit>> call(MarkAttendanceParams params) {
    return repository.markAttendance(params.record);
  }
}

class MarkAttendanceParams extends Equatable {
  final AttendanceRecord record;
  const MarkAttendanceParams(this.record);

  @override
  List<Object> get props => [record];
}