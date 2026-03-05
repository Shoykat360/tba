/*import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_location.dart';
import '../repositories/attendance_repository.dart';

class FetchCurrentLocation implements UseCase<UserLocation, NoParams> {
  final AttendanceRepository _attendanceRepository;

  const FetchCurrentLocation({
    required AttendanceRepository attendanceRepository,
  }) : _attendanceRepository = attendanceRepository;

  @override
  Future<Either<Failure, UserLocation>> call(NoParams params) async {
    return await _attendanceRepository.fetchCurrentUserLocation();
  }
}*/
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_location.dart';
import '../repositories/attendance_repository.dart';

class FetchCurrentLocation extends UseCase<UserLocation, NoParams> {
  final AttendanceRepository repository;

  FetchCurrentLocation(this.repository);

  @override
  Future<Either<Failure, UserLocation>> call(NoParams params) {
    return repository.fetchCurrentLocation();
  }
}