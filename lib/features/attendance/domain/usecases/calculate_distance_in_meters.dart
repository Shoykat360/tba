/*
import '../services/geofence_calculator_service.dart';

class CalculateDistanceInMetersParams {
  final double fromLatitude;
  final double fromLongitude;
  final double toLatitude;
  final double toLongitude;

  const CalculateDistanceInMetersParams({
    required this.fromLatitude,
    required this.fromLongitude,
    required this.toLatitude,
    required this.toLongitude,
  });
}

/// Synchronous use case. Delegates to [GeofenceCalculatorService],
/// which is pure Dart with no side effects or I/O.
class CalculateDistanceInMeters {
  final GeofenceCalculatorService _geofenceCalculatorService;

  const CalculateDistanceInMeters({
    required GeofenceCalculatorService geofenceCalculatorService,
  }) : _geofenceCalculatorService = geofenceCalculatorService;

  double call(CalculateDistanceInMetersParams params) {
    return _geofenceCalculatorService.calculateDistanceInMeters(
      fromLatitude: params.fromLatitude,
      fromLongitude: params.fromLongitude,
      toLatitude: params.toLatitude,
      toLongitude: params.toLongitude,
    );
  }
}
*/


import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../services/geofence_calculator_service.dart';

class CalculateDistanceInMeters extends UseCase<double, CalculateDistanceParams> {
  final GeofenceCalculatorService calculatorService;

  CalculateDistanceInMeters(this.calculatorService);

  @override
  Future<Either<Failure, double>> call(CalculateDistanceParams params) async {
    final distance = calculatorService.calculateDistanceInMeters(
      lat1: params.userLat,
      lon1: params.userLon,
      lat2: params.officeLat,
      lon2: params.officeLon,
    );
    return Right(distance);
  }
}

class CalculateDistanceParams extends Equatable {
  final double userLat;
  final double userLon;
  final double officeLat;
  final double officeLon;

  const CalculateDistanceParams({
    required this.userLat,
    required this.userLon,
    required this.officeLat,
    required this.officeLon,
  });

  @override
  List<Object> get props => [userLat, userLon, officeLat, officeLon];
}