import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/office_location.dart';
import '../repositories/attendance_repository.dart';

/*class LoadSavedOfficeLocation implements UseCase<OfficeLocation, NoParams> {
  final AttendanceRepository _attendanceRepository;

  const LoadSavedOfficeLocation({
    required AttendanceRepository attendanceRepository,
  }) : _attendanceRepository = attendanceRepository;

  @override
  Future<Either<Failure, OfficeLocation>> call(NoParams params) async {
    return await _attendanceRepository.loadSavedOfficeLocation();
  }
}*/


import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/office_location.dart';
import '../repositories/attendance_repository.dart';

class LoadSavedOfficeLocation extends UseCase<OfficeLocation, NoParams> {
  final AttendanceRepository repository;

  LoadSavedOfficeLocation(this.repository);

  @override
  Future<Either<Failure, OfficeLocation>> call(NoParams params) {
    return repository.loadSavedOfficeLocation();
  }
}