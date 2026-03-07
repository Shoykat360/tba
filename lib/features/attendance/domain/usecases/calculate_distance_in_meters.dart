import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../services/geofence_calculator_service.dart';

class CalculateDistanceInMeters extends UseCase<double, CalculateDistanceParams> {
  final GeofenceCalculatorService geofenceCalculatorService;

  CalculateDistanceInMeters(this.geofenceCalculatorService);

  @override
  Future<Either<Failure, double>> call(CalculateDistanceParams params) async {
    final double distanceInMeters =
        geofenceCalculatorService.distanceBetweenTwoCoordinatesInMeters(
      fromLatitude: params.userLatitude,
      fromLongitude: params.userLongitude,
      toLatitude: params.officeLatitude,
      toLongitude: params.officeLongitude,
    );
    return Right(distanceInMeters);
  }
}

class CalculateDistanceParams extends Equatable {
  final double userLatitude;
  final double userLongitude;
  final double officeLatitude;
  final double officeLongitude;

  const CalculateDistanceParams({
    required this.userLatitude,
    required this.userLongitude,
    required this.officeLatitude,
    required this.officeLongitude,
  });

  @override
  List<Object> get props => [
        userLatitude,
        userLongitude,
        officeLatitude,
        officeLongitude,
      ];
}
