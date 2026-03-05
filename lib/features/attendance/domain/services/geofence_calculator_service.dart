/*import 'dart:math';

/// Pure domain service responsible for geofence calculations.
/// Contains no I/O, no Flutter imports, no side effects.
/// Uses the Haversine formula for accurate surface distance calculation.
class GeofenceCalculatorService {
  const GeofenceCalculatorService();

  static const double _earthRadiusInMeters = 6371000.0;

  /// Calculates the straight-line distance in meters between two GPS coordinates
  /// using the Haversine formula.
  double calculateDistanceInMeters({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) {
    final double fromLatRadians = _degreesToRadians(fromLatitude);
    final double toLatRadians = _degreesToRadians(toLatitude);
    final double deltaLatRadians = _degreesToRadians(toLatitude - fromLatitude);
    final double deltaLonRadians = _degreesToRadians(toLongitude - fromLongitude);

    final double haversineA =
        _squaredHalfChord(deltaLatRadians) +
        cos(fromLatRadians) *
            cos(toLatRadians) *
            _squaredHalfChord(deltaLonRadians);

    final double angularDistanceInRadians =
        2 * atan2(sqrt(haversineA), sqrt(1 - haversineA));

    return _earthRadiusInMeters * angularDistanceInRadians;
  }

  /// Returns true if [distanceInMeters] falls within [allowedRadiusInMeters].
  bool checkIfUserIsWithinAllowedRadius({
    required double distanceInMeters,
    required double allowedRadiusInMeters,
  }) {
    return distanceInMeters <= allowedRadiusInMeters;
  }

  double _degreesToRadians(double degrees) => degrees * (pi / 180.0);

  double _squaredHalfChord(double radians) => sin(radians / 2) * sin(radians / 2);
}*/


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