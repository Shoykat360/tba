import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';

class DistanceIndicatorWidget extends StatelessWidget {
  final double? distanceInMeters;
  final bool isWithinRadius;
  final bool isLoading;

  const DistanceIndicatorWidget({
    super.key,
    required this.distanceInMeters,
    required this.isWithinRadius,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return buildLoadingPlaceholder(theme);
    }

    if (distanceInMeters == null) {
      return buildNoDataPlaceholder(theme);
    }

    return buildDistanceCard(theme);
  }

  // ─── States ───────────────────────────────────────────────────────────────

  Widget buildLoadingPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: buildCardDecoration(theme.colorScheme.surfaceVariant.withOpacity(0.4)),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Fetching your location...',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget buildNoDataPlaceholder(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: buildCardDecoration(theme.colorScheme.surfaceVariant.withOpacity(0.4)),
      child: Text(
        'Set an office location to see your distance.',
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget buildDistanceCard(ThemeData theme) {
    final Color statusColor = isWithinRadius ? Colors.green : Colors.orange;
    final double progressValue =
    (distanceInMeters! / AppConstants.geofenceRadiusMeters).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: buildCardDecoration(statusColor.withOpacity(0.08)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDistanceRow(theme, statusColor),
          const SizedBox(height: 10),
          buildProgressBar(progressValue, statusColor),
          const SizedBox(height: 6),
          buildRadiusLabel(theme),
        ],
      ),
    );
  }

  // ─── Sub-widgets ──────────────────────────────────────────────────────────

  Widget buildDistanceRow(ThemeData theme, Color statusColor) {
    return Row(
      children: [
        Icon(
          isWithinRadius
              ? Icons.where_to_vote_rounded
              : Icons.directions_walk_rounded,
          color: statusColor,
          size: 22,
        ),
        const SizedBox(width: 10),
        Text(
          formatDistanceLabel(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
        const Spacer(),
        buildStatusBadge(theme, statusColor),
      ],
    );
  }

  Widget buildStatusBadge(ThemeData theme, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isWithinRadius ? 'Inside zone' : 'Outside zone',
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildProgressBar(double progressValue, Color statusColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: isWithinRadius ? 1.0 : progressValue,
        minHeight: 6,
        backgroundColor: statusColor.withOpacity(0.15),
        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
      ),
    );
  }

  Widget buildRadiusLabel(ThemeData theme) {
    return Text(
      'Allowed radius: ${AppConstants.geofenceRadiusMeters.toStringAsFixed(0)}m',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  BoxDecoration buildCardDecoration(Color backgroundColor) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
    );
  }

  String formatDistanceLabel() {
    if (distanceInMeters! < 1000) {
      return '${distanceInMeters!.toStringAsFixed(1)} m away';
    }
    return '${(distanceInMeters! / 1000).toStringAsFixed(2)} km away';
  }
}