import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/office_location.dart';
import '../repositories/attendance_repository.dart';

class SaveOfficeLocationLocally extends UseCase<Unit, SaveOfficeLocationParams> {
  final AttendanceRepository repository;

  SaveOfficeLocationLocally(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SaveOfficeLocationParams params) {
    return repository.saveOfficeLocation(params.officeLocation);
  }
}

class SaveOfficeLocationParams extends Equatable {
  final OfficeLocation officeLocation;

  const SaveOfficeLocationParams(this.officeLocation);

  @override
  List<Object> get props => [officeLocation];
}
