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