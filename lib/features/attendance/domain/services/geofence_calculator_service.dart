import 'dart:math';

class GeofenceCalculatorService {
  /// Calculates distance in meters between two GPS coordinates
  /// using the Haversine formula.
  double calculateDistanceInMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusMeters = 6371000;

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  bool isWithinRadius({
    required double distanceInMeters,
    required double radiusInMeters,
  }) {
    return distanceInMeters <= radiusInMeters;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}