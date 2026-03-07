import 'dart:math';

class GeofenceCalculatorService {
  /// Calculates the straight-line distance in meters between two GPS points
  /// using the Haversine formula (accounts for Earth's curvature).
  double distanceBetweenTwoCoordinatesInMeters({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) {
    const double earthRadiusInMeters = 6371000;

    final double latitudeDifferenceInRadians =
        convertDegreesToRadians(toLatitude - fromLatitude);
    final double longitudeDifferenceInRadians =
        convertDegreesToRadians(toLongitude - fromLongitude);

    final double haversineIntermediate =
        sin(latitudeDifferenceInRadians / 2) * sin(latitudeDifferenceInRadians / 2) +
            cos(convertDegreesToRadians(fromLatitude)) *
                cos(convertDegreesToRadians(toLatitude)) *
                sin(longitudeDifferenceInRadians / 2) *
                sin(longitudeDifferenceInRadians / 2);

    final double angularDistanceInRadians =
        2 * atan2(sqrt(haversineIntermediate), sqrt(1 - haversineIntermediate));

    return earthRadiusInMeters * angularDistanceInRadians;
  }

  /// Returns true if the given distance falls within the allowed radius.
  bool isUserInsideGeofenceRadius({
    required double distanceInMeters,
    required double allowedRadiusInMeters,
  }) {
    return distanceInMeters <= allowedRadiusInMeters;
  }

  /// Converts a value in degrees to radians.
  double convertDegreesToRadians(double degrees) => degrees * pi / 180;
}
