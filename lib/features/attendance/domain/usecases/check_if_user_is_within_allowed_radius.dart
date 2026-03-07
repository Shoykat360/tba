import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../services/geofence_calculator_service.dart';

class CheckIfUserIsWithinAllowedRadius
    extends UseCase<bool, CheckAllowedRadiusParams> {
  final GeofenceCalculatorService geofenceCalculatorService;

  CheckIfUserIsWithinAllowedRadius(this.geofenceCalculatorService);

  @override
  Future<Either<Failure, bool>> call(CheckAllowedRadiusParams params) async {
    final bool isInsideRadius =
        geofenceCalculatorService.isUserInsideGeofenceRadius(
      distanceInMeters: params.distanceInMeters,
      allowedRadiusInMeters: AppConstants.geofenceRadiusMeters,
    );
    return Right(isInsideRadius);
  }
}

class CheckAllowedRadiusParams extends Equatable {
  final double distanceInMeters;

  const CheckAllowedRadiusParams(this.distanceInMeters);

  @override
  List<Object> get props => [distanceInMeters];
}
