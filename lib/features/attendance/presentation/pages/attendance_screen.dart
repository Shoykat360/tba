/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_time_formatter.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/office_location.dart';
import '../../domain/entities/user_location.dart';
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
    context.read<AttendanceBloc>().add(const AttendanceInitializedEvent());
  }

  // ---------------------------------------------------------------------------
  // User Intent Dispatchers — zero logic, only event dispatch
  // ---------------------------------------------------------------------------

  void _onSetOfficeLocationTapped() {
    context
        .read<AttendanceBloc>()
        .add(const FetchAndSaveOfficeLocationRequested());
  }

  void _onRefreshLocationTapped() {
    context
        .read<AttendanceBloc>()
        .add(const RefreshCurrentLocationRequested());
  }

  void _onMarkAttendanceTapped() {
    context.read<AttendanceBloc>().add(const MarkAttendanceRequested());
  }

  Future<void> _onOpenAppSettingsTapped() async {
    await ph.openAppSettings();
  }

  // ---------------------------------------------------------------------------
  // Side-Effect Listener
  // ---------------------------------------------------------------------------

  void _handleStateListener(BuildContext context, AttendanceState state) {
    if (state is AttendanceMarkedSuccessState) {
      _showSuccessSnackBar(context, state.markedRecord);
    }
    if (state is AttendanceErrorState) {
      _showErrorSnackBar(context, state.errorMessage);
    }
  }

  void _showSuccessSnackBar(BuildContext context, AttendanceRecord record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Attendance marked at ${DateTimeFormatter.formatToReadableDateTime(record.markedAt)}',
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Builder
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        centerTitle: true,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: _handleStateListener,
        builder: (context, state) {
          if (state is AttendanceInitialState) {
            return _buildFullScreenLoader('Initializing...');
          }
          if (state is AttendanceLoadingState) {
            return _buildFullScreenLoader(state.loadingMessage);
          }
          if (state is AttendancePermissionDeniedState) {
            return _buildPermissionDeniedView(state);
          }
          if (state is AttendanceLocationServiceDisabledState) {
            return _buildLocationServiceDisabledView(state.errorMessage);
          }
          if (state is AttendanceErrorState) {
            return _buildGenericErrorView(state.errorMessage);
          }
          if (state is AttendanceLoadedState) {
            return _buildLoadedView(state);
          }
          // AttendanceMarkedSuccessState is intentionally handled by the
          // listener only — the builder falls through to avoid a blank frame.
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top-Level State Views
  // ---------------------------------------------------------------------------

  Widget _buildFullScreenLoader(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16.0),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView(AttendancePermissionDeniedState state) {
    return _buildErrorCenteredView(
      icon: Icons.location_off,
      iconColor: Colors.orange.shade400,
      title: 'Location Permission Required',
      message: state.errorMessage,
      actionLabel: state.isPermanentlyDenied ? 'Open App Settings' : 'Retry',
      actionIcon: state.isPermanentlyDenied ? Icons.settings : Icons.refresh,
      onActionTapped: state.isPermanentlyDenied
          ? _onOpenAppSettingsTapped
          : _onSetOfficeLocationTapped,
    );
  }

  Widget _buildLocationServiceDisabledView(String message) {
    return _buildErrorCenteredView(
      icon: Icons.gps_off,
      iconColor: Colors.red.shade400,
      title: 'GPS is Disabled',
      message: message,
      actionLabel: 'Retry After Enabling GPS',
      actionIcon: Icons.refresh,
      onActionTapped: _onSetOfficeLocationTapped,
    );
  }

  Widget _buildGenericErrorView(String message) {
    return _buildErrorCenteredView(
      icon: Icons.error_outline,
      iconColor: Colors.red,
      title: 'Something went wrong',
      message: message,
      actionLabel: 'Retry',
      actionIcon: Icons.refresh,
      onActionTapped: () => context
          .read<AttendanceBloc>()
          .add(const AttendanceInitializedEvent()),
    );
  }

  Widget _buildLoadedView(AttendanceLoadedState state) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.hasMarkedAttendanceToday)
                _AttendanceSuccessBanner(record: state.latestAttendanceRecord),

              _SectionLabel(label: 'Office Location'),
              const SizedBox(height: 8.0),
              _OfficeLocationCard(officeLocation: state.savedOfficeLocation),
              const SizedBox(height: 16.0),

              SetLocationButton(
                onPressed: _onSetOfficeLocationTapped,
                isLoading: state.isRefreshing,
                hasExistingLocation: state.savedOfficeLocation != null,
              ),

              const SizedBox(height: 24.0),
              const Divider(),
              const SizedBox(height: 16.0),

              _CurrentLocationHeader(
                hasSavedOffice: state.savedOfficeLocation != null,
                isRefreshing: state.isRefreshing,
                onRefreshTapped: _onRefreshLocationTapped,
              ),
              const SizedBox(height: 8.0),

              if (state.currentUserLocation != null)
                _CurrentLocationCard(userLocation: state.currentUserLocation!)
              else if (state.savedOfficeLocation != null)
                _FetchLocationPrompt(
                  isRefreshing: state.isRefreshing,
                  onFetchTapped: _onRefreshLocationTapped,
                ),

              if (state.distanceFromOfficeInMeters != null) ...[
                const SizedBox(height: 20.0),
                _SectionLabel(label: 'Distance from Office'),
                const SizedBox(height: 8.0),
                DistanceIndicatorWidget(
                  distanceInMeters: state.distanceFromOfficeInMeters!,
                ),
              ],

              const SizedBox(height: 28.0),

              if (state.savedOfficeLocation != null) ...[
                AttendanceActionButton(
                  onPressed: _onMarkAttendanceTapped,
                  isLoading: state.isRefreshing,
                  isEnabled: state.isWithinGeofence,
                  hasMarkedAttendance: state.hasMarkedAttendanceToday,
                ),
                const SizedBox(height: 8.0),
                if (!state.isWithinGeofence &&
                    state.distanceFromOfficeInMeters != null)
                  const _GeofenceHintText(),
              ],

              // Bottom padding so FAB/nav bars don't overlap content
              const SizedBox(height: 32.0),
            ],
          ),
        ),

        // Inline refresh indicator — shown at top of screen without
        // destroying the already-visible data below.
        if (state.isRefreshing)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Reusable Error Layout
  // ---------------------------------------------------------------------------

  Widget _buildErrorCenteredView({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required String actionLabel,
    required IconData actionIcon,
    required VoidCallback onActionTapped,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72.0, color: iconColor),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: onActionTapped,
              icon: Icon(actionIcon),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Private Sub-Widgets — scoped to this screen file, no business logic
// =============================================================================

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _OfficeLocationCard extends StatelessWidget {
  final OfficeLocation? officeLocation;
  const _OfficeLocationCard({required this.officeLocation});

  @override
  Widget build(BuildContext context) {
    if (officeLocation == null) {
      return _buildNoLocationPlaceholder(context);
    }
    return _buildLocationDetails(context, officeLocation!);
  }

  Widget _buildNoLocationPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade600),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'No office location set. Tap "Set Office Location" to save your current GPS coordinates.',
              style: TextStyle(color: Colors.blue.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetails(BuildContext context, OfficeLocation location) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business, color: Colors.blueGrey),
              const SizedBox(width: 8.0),
              Text(
                'Saved Office Coordinates',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text('Lat: ${location.latitude.toStringAsFixed(6)}'),
          Text('Long: ${location.longitude.toStringAsFixed(6)}'),
          const SizedBox(height: 4.0),
          Text(
            'Saved on: ${DateTimeFormatter.formatToReadableDateTime(location.savedAt)}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _CurrentLocationHeader extends StatelessWidget {
  final bool hasSavedOffice;
  final bool isRefreshing;
  final VoidCallback onRefreshTapped;

  const _CurrentLocationHeader({
    required this.hasSavedOffice,
    required this.isRefreshing,
    required this.onRefreshTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Your Current Location',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (hasSavedOffice)
          TextButton.icon(
            onPressed: isRefreshing ? null : onRefreshTapped,
            icon: const Icon(Icons.refresh, size: 18.0),
            label: const Text('Refresh'),
          ),
      ],
    );
  }
}

class _CurrentLocationCard extends StatelessWidget {
  final UserLocation userLocation;
  const _CurrentLocationCard({required this.userLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lat: ${userLocation.latitude.toStringAsFixed(6)}'),
          Text('Long: ${userLocation.longitude.toStringAsFixed(6)}'),
          if (userLocation.accuracy != null)
            Text(
              'Accuracy: ±${userLocation.accuracy!.toStringAsFixed(1)}m',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }
}

class _FetchLocationPrompt extends StatelessWidget {
  final bool isRefreshing;
  final VoidCallback onFetchTapped;
  const _FetchLocationPrompt({
    required this.isRefreshing,
    required this.onFetchTapped,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isRefreshing ? null : onFetchTapped,
      icon: const Icon(Icons.gps_fixed),
      label: const Text('Fetch My Location'),
    );
  }
}

class _AttendanceSuccessBanner extends StatelessWidget {
  final AttendanceRecord? record;
  const _AttendanceSuccessBanner({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 28.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Marked Successfully',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                ),
                if (record != null)
                  Text(
                    'Time: ${DateTimeFormatter.formatToReadableDateTime(record!.markedAt)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.green.shade700),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _GeofenceHintText extends StatelessWidget {
  const _GeofenceHintText();

  @override
  Widget build(BuildContext context) {
    final int radiusInMeters = AppConstants.geofenceRadiusInMeters.toInt();
    return Center(
      child: Text(
        'You must be within ${radiusInMeters}m of the office to mark attendance.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.grey.shade600),
      ),
    );
  }
}
*/


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