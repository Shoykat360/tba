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