/*
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class DistanceIndicatorWidget extends StatelessWidget {
  final double distanceInMeters;

  const DistanceIndicatorWidget({
    super.key,
    required this.distanceInMeters,
  });

  bool get _isWithinGeofence =>
      distanceInMeters <= AppConstants.geofenceRadiusInMeters;

  Color _buildIndicatorColor() {
    if (distanceInMeters <= AppConstants.geofenceRadiusInMeters) {
      return Colors.green;
    } else if (distanceInMeters <= 200) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _buildDistanceLabel() {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(2)}km';
    }
  }

  String _buildStatusMessage() {
    if (_isWithinGeofence) {
      return 'You are within the office area ✓';
    }
    return 'You are ${_buildDistanceLabel()} away from the office';
  }

  @override
  Widget build(BuildContext context) {
    final Color indicatorColor = _buildIndicatorColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: indicatorColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isWithinGeofence
                    ? Icons.location_on
                    : Icons.location_searching,
                color: indicatorColor,
                size: 20.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Distance from Office',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: indicatorColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            _buildDistanceLabel(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: indicatorColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4.0),
          Text(
            _buildStatusMessage(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: indicatorColor.withOpacity(0.85),
                ),
          ),
          const SizedBox(height: 12.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: LinearProgressIndicator(
              value: _isWithinGeofence
                  ? 1.0
                  : (AppConstants.geofenceRadiusInMeters /
                          distanceInMeters.clamp(
                              AppConstants.geofenceRadiusInMeters, 500))
                      .clamp(0.0, 1.0),
              backgroundColor: indicatorColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              minHeight: 8.0,
            ),
          ),
        ],
      ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class DistanceIndicatorWidget extends StatelessWidget {
  final double? distanceInMeters;
  final bool isWithinRadius;
  final bool isLoading;

  const DistanceIndicatorWidget({
    super.key,
    required this.distanceInMeters,
    required this.isWithinRadius,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return _buildCard(
        context,
        icon: Icons.location_searching,
        iconColor: theme.colorScheme.primary,
        title: 'Fetching location...',
        subtitle: 'Please wait',
        progressValue: null,
        progressColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
      );
    }

    if (distanceInMeters == null) {
      return _buildCard(
        context,
        icon: Icons.location_off_rounded,
        iconColor: theme.colorScheme.outline,
        title: 'Location unavailable',
        subtitle: 'Tap refresh to retry',
        progressValue: 0,
        progressColor: theme.colorScheme.outline,
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.4),
      );
    }

    final distance = distanceInMeters!;
    final double clampedProgress =
    (1 - (distance / AppConstants.geofenceRadiusMeters)).clamp(0.0, 1.0);
    final color = isWithinRadius ? Colors.green : theme.colorScheme.error;
    final formattedDistance = distance >= 1000
        ? '${(distance / 1000).toStringAsFixed(2)} km'
        : '${distance.toStringAsFixed(1)} m';

    return _buildCard(
      context,
      icon: isWithinRadius
          ? Icons.check_circle_rounded
          : Icons.location_on_rounded,
      iconColor: color,
      title: isWithinRadius
          ? '✅ You are within the office zone'
          : 'You are $formattedDistance away from the office',
      subtitle: isWithinRadius
          ? 'You can mark attendance now'
          : 'Move within ${AppConstants.geofenceRadiusMeters.toStringAsFixed(0)}m to mark attendance',
      progressValue: isWithinRadius ? 1.0 : clampedProgress,
      progressColor: color,
      backgroundColor:
      (isWithinRadius ? Colors.green : theme.colorScheme.error)
          .withOpacity(0.08),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required IconData icon,
        required Color iconColor,
        required String title,
        required String subtitle,
        required double? progressValue,
        required Color progressColor,
        required Color backgroundColor,
      }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: progressColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: progressValue == null
                ? LinearProgressIndicator(
              color: progressColor,
              backgroundColor: progressColor.withOpacity(0.2),
              minHeight: 6,
            )
                : TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progressValue),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (_, val, __) => LinearProgressIndicator(
                value: val,
                color: progressColor,
                backgroundColor: progressColor.withOpacity(0.2),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}