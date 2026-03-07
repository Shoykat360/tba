import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/date_time_formatter.dart';
import '../../domain/entities/attendance_record.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../widgets/attendance_action_button.dart';
import '../widgets/distance_indicator_widget.dart';
import '../widgets/set_location_button.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AttendanceBloc>().add(const InitializeAttendanceScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        centerTitle: true,
        actions: [buildRefreshIconButton()],
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: handleBlocSideEffects,
        builder: buildScreenBody,
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  Widget buildRefreshIconButton() {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        return IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh Location',
          onPressed: state.status == AttendanceStatus.loading
              ? null
              : () => context
              .read<AttendanceBloc>()
              .add(const RefreshCurrentUserLocation()),
        );
      },
    );
  }

  // ─── BlocConsumer Callbacks ───────────────────────────────────────────────

  /// Handles one-time side effects.
  /// When attendance is marked successfully, shows a success popup dialog.
  /// When user taps "Back to Home" inside the dialog, it navigates back.
  void handleBlocSideEffects(BuildContext context, AttendanceState state) {
    if (state.attendanceJustMarkedSuccessfully) {
      showAttendanceSuccessDialog(context, state);
    }
  }

  Widget buildScreenBody(BuildContext context, AttendanceState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<AttendanceBloc>()
            .add(const RefreshCurrentUserLocation());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildStatusHeaderCard(context, state),
            const SizedBox(height: 20),
            buildDistanceSection(context, state),
            const SizedBox(height: 24),
            buildOfficeInfoSection(context, state),
            const SizedBox(height: 24),
            SetLocationButton(
              isLoading: state.locationSetStatus == LocationSetStatus.saving,
              hasLocation: state.officeLocation != null,
              onPressed: () => context
                  .read<AttendanceBloc>()
                  .add(const SaveCurrentLocationAsOffice()),
            ),
            const SizedBox(height: 12),
            AttendanceActionButton(
              canMarkAttendance: state.canMarkAttendance,
              isLoading: state.isSavingAttendance,
              onPressed: () => context
                  .read<AttendanceBloc>()
                  .add(const ConfirmAttendanceMarking()),
            ),
            if (state.generalErrorMessage != null) ...[
              const SizedBox(height: 16),
              buildErrorBanner(context, state.generalErrorMessage!),
            ],
            if (state.locationSaveErrorMessage != null) ...[
              const SizedBox(height: 16),
              buildErrorBanner(context, state.locationSaveErrorMessage!),
            ],
            if (state.attendanceHistory.isNotEmpty) ...[
              const SizedBox(height: 28),
              buildAttendanceHistoryList(context, state),
            ],
          ],
        ),
      ),
    );
  }

  // ─── UI Sections ─────────────────────────────────────────────────────────

  Widget buildStatusHeaderCard(BuildContext context, AttendanceState state) {
    final theme = Theme.of(context);
    final bool isLoading = state.status == AttendanceStatus.loading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Geo-Fenced Attendance',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : Icon(
                state.isUserInsideGeofence
                    ? Icons.verified_rounded
                    : Icons.location_on_rounded,
                color: Colors.white,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateTimeFormatter.formatDateTime(DateTime.now()),
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            resolveGeofenceStatusMessage(state),
            style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget buildDistanceSection(BuildContext context, AttendanceState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distance Status',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DistanceIndicatorWidget(
          distanceInMeters: state.officeLocation == null
              ? null
              : state.distanceFromOfficeInMeters,
          isWithinRadius: state.isUserInsideGeofence,
          isLoading: state.status == AttendanceStatus.loading,
        ),
      ],
    );
  }

  Widget buildOfficeInfoSection(BuildContext context, AttendanceState state) {
    final theme = Theme.of(context);

    if (state.officeLocation == null) {
      return buildNoOfficeLocationPlaceholder(context);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Office Location',
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          buildInfoRow(
            context,
            icon: Icons.my_location_rounded,
            label: 'Coordinates',
            value:
            '${state.officeLocation!.latitude.toStringAsFixed(6)}, ${state.officeLocation!.longitude.toStringAsFixed(6)}',
          ),
          const SizedBox(height: 6),
          buildInfoRow(
            context,
            icon: Icons.calendar_today_rounded,
            label: 'Saved at',
            value:
            DateTimeFormatter.formatDateTime(state.officeLocation!.savedAt),
          ),
          if (state.userLocation != null) ...[
            const SizedBox(height: 6),
            buildInfoRow(
              context,
              icon: Icons.person_pin_circle_rounded,
              label: 'Your location',
              value:
              '${state.userLocation!.latitude.toStringAsFixed(6)}, ${state.userLocation!.longitude.toStringAsFixed(6)}',
            ),
          ],
        ],
      ),
    );
  }

  Widget buildNoOfficeLocationPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No office location set. Tap "Set Office Location" to save your current GPS coordinates.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAttendanceHistoryList(
      BuildContext context, AttendanceState state) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance History',
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.attendanceHistory.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final AttendanceRecord record = state.attendanceHistory[index];
            return buildSingleHistoryItem(context, record, theme);
          },
        ),
      ],
    );
  }

  // ─── Small Reusable Widgets ───────────────────────────────────────────────

  Widget buildInfoRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style:
          theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(value, style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }

  Widget buildErrorBanner(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: theme.colorScheme.onErrorContainer,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSingleHistoryItem(
      BuildContext context,
      AttendanceRecord record,
      ThemeData theme,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateTimeFormatter.formatDateTime(record.markedAt),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${record.distanceFromOffice.toStringAsFixed(1)}m from office',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Success Dialog ───────────────────────────────────────────────────────

  /// Shows a success popup with the marked time and distance from office.
  /// Tapping "Back to Home" closes the dialog then pops back to the home screen.
  void showAttendanceSuccessDialog(
      BuildContext context, AttendanceState state) {
    final AttendanceRecord? latestRecord = state.attendanceHistory.isNotEmpty
        ? state.attendanceHistory.first
        : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildSuccessIconCircle(),
                const SizedBox(height: 20),
                buildSuccessTitleText(),
                const SizedBox(height: 8),
                buildSuccessSubtitleText(),
                if (latestRecord != null) ...[
                  const SizedBox(height: 20),
                  buildAttendanceDetailCard(context, latestRecord),
                ],
                const SizedBox(height: 28),
                buildBackToHomeButton(context, dialogContext),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildSuccessIconCircle() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle_rounded,
        color: Colors.green,
        size: 48,
      ),
    );
  }

  Widget buildSuccessTitleText() {
    return const Text(
      'Attendance Marked!',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }

  Widget buildSuccessSubtitleText() {
    return Text(
      'Your attendance has been recorded successfully.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget buildAttendanceDetailCard(
      BuildContext context, AttendanceRecord record) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          buildDetailRow(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: DateTimeFormatter.formatDateTime(record.markedAt),
            theme: theme,
          ),
          const SizedBox(height: 8),
          buildDetailRow(
            icon: Icons.social_distance_rounded,
            label: 'Distance',
            value:
            '${record.distanceFromOffice.toStringAsFixed(1)} m from office',
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.green),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style:
          theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(value, style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }

  /// Closes the dialog first, then pops the attendance screen back to home.
  Widget buildBackToHomeButton(
      BuildContext context, BuildContext dialogContext) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(dialogContext).pop(); // close the dialog
          Navigator.of(context).pop();       // go back to home screen
        },
        icon: const Icon(Icons.home_rounded, size: 20),
        label: const Text(
          'Back to Home',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ─── Pure Helpers ─────────────────────────────────────────────────────────

  /// Returns the correct status message for the header card.
  String resolveGeofenceStatusMessage(AttendanceState state) {
    if (state.officeLocation == null) return 'No office location set';
    if (state.isUserInsideGeofence) return 'You are at the office ✅';
    return 'Outside office zone';
  }
}