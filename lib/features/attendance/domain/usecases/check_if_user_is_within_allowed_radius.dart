import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../services/geofence_calculator_service.dart';

class CheckIfUserIsWithinAllowedRadius
    extends UseCase<bool, CheckRadiusParams> {
  final GeofenceCalculatorService calculatorService;

  CheckIfUserIsWithinAllowedRadius(this.calculatorService);

  @override
  Future<Either<Failure, bool>> call(CheckRadiusParams params) async {
    final isWithin = calculatorService.isWithinRadius(
      distanceInMeters: params.distanceInMeters,
      radiusInMeters: AppConstants.geofenceRadiusMeters,
    );
    return Right(isWithin);
  }
}

class CheckRadiusParams extends Equatable {
  final double distanceInMeters;

  const CheckRadiusParams(this.distanceInMeters);

  @override
  List<Object> get props => [distanceInMeters];
}