import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/date_time_formatter.dart';
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
    context.read<AttendanceBloc>().add(const InitializeAttendanceEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        centerTitle: true,
        actions: [
          BlocBuilder<AttendanceBloc, AttendanceState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Location',
                onPressed: state.status == AttendanceStatus.loading
                    ? null
                    : () => context
                    .read<AttendanceBloc>()
                    .add(const RefreshUserLocationEvent()),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state.attendanceMarkedSuccessfully) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Attendance marked successfully!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }

          if (state.locationSetStatus == LocationSetStatus.set &&
              state.errorMessage == null) {
            final prevStatus = context.read<AttendanceBloc>().state.locationSetStatus;
            if (prevStatus == LocationSetStatus.setting) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Office location saved!'),
                    ],
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<AttendanceBloc>()
                  .add(const RefreshUserLocationEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(context, state),
                  const SizedBox(height: 20),
                  _buildDistanceSection(context, state),
                  const SizedBox(height: 24),
                  _buildOfficeInfoSection(context, state),
                  const SizedBox(height: 24),
                  SetLocationButton(
                    isLoading:
                    state.locationSetStatus == LocationSetStatus.setting,
                    hasLocation: state.officeLocation != null,
                    onPressed: () => context
                        .read<AttendanceBloc>()
                        .add(const SetOfficeLocationEvent()),
                  ),
                  const SizedBox(height: 12),
                  AttendanceActionButton(
                    canMarkAttendance: state.canMarkAttendance,
                    isLoading: state.isMarkingAttendance,
                    onPressed: () => context
                        .read<AttendanceBloc>()
                        .add(const MarkAttendanceEvent()),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorBanner(context, state.errorMessage!),
                  ],
                  if (state.locationSetError != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorBanner(context, state.locationSetError!),
                  ],
                  if (state.attendanceHistory.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _buildAttendanceHistory(context, state),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, AttendanceState state) {
    final theme = Theme.of(context);
    final isLoading = state.status == AttendanceStatus.loading;

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
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              else
                Icon(
                  state.isWithinRadius
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
            style: theme.textTheme.bodySmall
                ?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            state.officeLocation == null
                ? 'No office location set'
                : state.isWithinRadius
                ? 'You are at the office ✅'
                : 'Outside office zone',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceSection(BuildContext context, AttendanceState state) {
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
              : state.distanceInMeters,
          isWithinRadius: state.isWithinRadius,
          isLoading: state.status == AttendanceStatus.loading,
        ),
      ],
    );
  }

  Widget _buildOfficeInfoSection(BuildContext context, AttendanceState state) {
    final theme = Theme.of(context);

    if (state.officeLocation == null) {
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
                'No office location set. Tap "Set Office Location" to save your current GPS coordinates as the office.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      );
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
          _buildInfoRow(
            context,
            icon: Icons.my_location_rounded,
            label: 'Coordinates',
            value:
            '${state.officeLocation!.latitude.toStringAsFixed(6)}, ${state.officeLocation!.longitude.toStringAsFixed(6)}',
          ),
          const SizedBox(height: 6),
          _buildInfoRow(
            context,
            icon: Icons.calendar_today_rounded,
            label: 'Saved at',
            value: DateTimeFormatter.formatDateTime(state.officeLocation!.savedAt),
          ),
          if (state.userLocation != null) ...[
            const SizedBox(height: 6),
            _buildInfoRow(
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

  Widget _buildInfoRow(
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
          style: theme.textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistory(BuildContext context, AttendanceState state) {
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
            final record = state.attendanceHistory[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.green.withOpacity(0.3)),
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
          },
        ),
      ],
    );
  }
}