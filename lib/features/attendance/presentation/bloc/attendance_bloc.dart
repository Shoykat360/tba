import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/office_location.dart';
import '../../domain/entities/user_location.dart';
import '../../domain/usecases/calculate_distance_in_meters.dart';
import '../../domain/usecases/check_if_user_is_within_allowed_radius.dart';
import '../../domain/usecases/fetch_current_location.dart';
import '../../domain/usecases/load_saved_office_location.dart';
import '../../domain/usecases/mark_attendance.dart';
import '../../domain/usecases/save_office_location_locally.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final FetchCurrentLocation fetchCurrentLocation;
  final SaveOfficeLocationLocally saveOfficeLocationLocally;
  final LoadSavedOfficeLocation loadSavedOfficeLocation;
  final CalculateDistanceInMeters calculateDistanceInMeters;
  final CheckIfUserIsWithinAllowedRadius checkIfUserIsWithinAllowedRadius;
  final MarkAttendance markAttendance;

  AttendanceBloc({
    required this.fetchCurrentLocation,
    required this.saveOfficeLocationLocally,
    required this.loadSavedOfficeLocation,
    required this.calculateDistanceInMeters,
    required this.checkIfUserIsWithinAllowedRadius,
    required this.markAttendance,
  }) : super(const AttendanceState()) {
    on<InitializeAttendanceScreen>(handleScreenInitialization);
    on<SaveCurrentLocationAsOffice>(handleSaveCurrentLocationAsOffice);
    on<RefreshCurrentUserLocation>(handleRefreshCurrentUserLocation);
    on<ConfirmAttendanceMarking>(handleConfirmAttendanceMarking);
  }

  // ─── Event Handlers ──────────────────────────────────────────────────────

  /// Runs once when the screen opens.
  /// Loads any previously saved office location, then fetches the live GPS position.
  Future<void> handleScreenInitialization(
    InitializeAttendanceScreen event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(status: AttendanceStatus.loading));

    final savedOfficeLocation = await loadOfficeLocationFromStorage();

    final locationResult = await fetchCurrentLocation(NoParams());

    await locationResult.fold(
      (failure) async {
        emit(state.copyWith(
          status: AttendanceStatus.failure,
          officeLocation: savedOfficeLocation,
          locationSetStatus: savedOfficeLocation != null
              ? LocationSetStatus.saved
              : LocationSetStatus.notSet,
          generalErrorMessage: failure.message,
        ));
      },
      (userLocation) async {
        if (savedOfficeLocation != null) {
          await calculateDistanceAndEmitUpdatedState(
            emit,
            userLocation: userLocation,
            officeLocation: savedOfficeLocation,
            locationSetStatus: LocationSetStatus.saved,
          );
        } else {
          emit(state.copyWith(
            status: AttendanceStatus.loaded,
            userLocation: userLocation,
            locationSetStatus: LocationSetStatus.notSet,
          ));
        }
      },
    );
  }

  /// Handles the user tapping "Set Office Location".
  /// Fetches the current GPS position and saves it as the office coordinates.
  Future<void> handleSaveCurrentLocationAsOffice(
    SaveCurrentLocationAsOffice event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(locationSetStatus: LocationSetStatus.saving));

    final locationResult = await fetchCurrentLocation(NoParams());

    await locationResult.fold(
      (failure) async {
        emit(state.copyWith(
          locationSetStatus: LocationSetStatus.failure,
          locationSaveErrorMessage: failure.message,
        ));
      },
      (userLocation) async {
        final OfficeLocation newOfficeLocation = buildOfficeLocationFromUserPosition(userLocation);

        final saveResult = await saveOfficeLocationLocally(
          SaveOfficeLocationParams(newOfficeLocation),
        );

        await saveResult.fold(
          (failure) async {
            emit(state.copyWith(
              locationSetStatus: LocationSetStatus.failure,
              locationSaveErrorMessage: failure.message,
            ));
          },
          (_) async {
            await calculateDistanceAndEmitUpdatedState(
              emit,
              userLocation: userLocation,
              officeLocation: newOfficeLocation,
              locationSetStatus: LocationSetStatus.saved,
            );
          },
        );
      },
    );
  }

  /// Handles the user pulling to refresh or tapping the refresh icon.
  /// Re-fetches GPS and recalculates distance from the saved office.
  Future<void> handleRefreshCurrentUserLocation(
    RefreshCurrentUserLocation event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(state.copyWith(
      status: AttendanceStatus.loading,
      clearGeneralError: true,
    ));

    final locationResult = await fetchCurrentLocation(NoParams());

    await locationResult.fold(
      (failure) async {
        emit(state.copyWith(
          status: AttendanceStatus.failure,
          generalErrorMessage: failure.message,
        ));
      },
      (userLocation) async {
        if (state.officeLocation != null) {
          await calculateDistanceAndEmitUpdatedState(
            emit,
            userLocation: userLocation,
            officeLocation: state.officeLocation!,
            locationSetStatus: state.locationSetStatus,
          );
        } else {
          emit(state.copyWith(
            status: AttendanceStatus.loaded,
            userLocation: userLocation,
          ));
        }
      },
    );
  }

  /// Handles the user tapping "Mark Attendance".
  /// Validates the geofence condition, saves the record, and updates history.
  Future<void> handleConfirmAttendanceMarking(
    ConfirmAttendanceMarking event,
    Emitter<AttendanceState> emit,
  ) async {
    if (!state.canMarkAttendance) return;

    emit(state.copyWith(
      isSavingAttendance: true,
      clearAttendanceSuccessFlag: true,
    ));

    final AttendanceRecord newRecord = buildAttendanceRecordFromCurrentState();

    final result = await markAttendance(MarkAttendanceParams(newRecord));

    result.fold(
      (failure) {
        emit(state.copyWith(
          isSavingAttendance: false,
          generalErrorMessage: failure.message,
        ));
      },
      (_) {
        final List<AttendanceRecord> updatedHistory = [
          newRecord,
          ...state.attendanceHistory,
        ];
        emit(state.copyWith(
          isSavingAttendance: false,
          attendanceJustMarkedSuccessfully: true,
          attendanceHistory: updatedHistory,
        ));
      },
    );
  }

  // ─── Private Helpers ─────────────────────────────────────────────────────

  /// Loads the saved office location from storage.
  /// Returns null if nothing has been saved yet.
  Future<OfficeLocation?> loadOfficeLocationFromStorage() async {
    final result = await loadSavedOfficeLocation(NoParams());
    return result.fold((_) => null, (location) => location);
  }

  /// Builds an OfficeLocation entity from a live UserLocation snapshot.
  OfficeLocation buildOfficeLocationFromUserPosition(UserLocation userLocation) {
    return OfficeLocation(
      latitude: userLocation.latitude,
      longitude: userLocation.longitude,
      savedAt: DateTime.now(),
    );
  }

  /// Builds an AttendanceRecord from the current BLoC state.
  AttendanceRecord buildAttendanceRecordFromCurrentState() {
    return AttendanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      latitude: state.userLocation!.latitude,
      longitude: state.userLocation!.longitude,
      markedAt: DateTime.now(),
      distanceFromOffice: state.distanceFromOfficeInMeters ?? 0,
    );
  }

  /// Calculates the distance between the user and the office,
  /// checks whether the user is inside the geofence
  Future<void> calculateDistanceAndEmitUpdatedState(
    Emitter<AttendanceState> emit, {
    required UserLocation userLocation,
    required OfficeLocation officeLocation,
    required LocationSetStatus locationSetStatus,
  }) async {
    final distanceResult = await calculateDistanceInMeters(
      CalculateDistanceParams(
        userLatitude: userLocation.latitude,
        userLongitude: userLocation.longitude,
        officeLatitude: officeLocation.latitude,
        officeLongitude: officeLocation.longitude,
      ),
    );

    final double distanceInMeters =
        distanceResult.fold((_) => 0.0, (distance) => distance);

    final geofenceResult = await checkIfUserIsWithinAllowedRadius(
      CheckAllowedRadiusParams(distanceInMeters),
    );
    final bool isInsideGeofence =
        geofenceResult.fold((_) => false, (isInside) => isInside);

    emit(state.copyWith(
      status: AttendanceStatus.loaded,
      locationSetStatus: locationSetStatus,
      userLocation: userLocation,
      officeLocation: officeLocation,
      distanceFromOfficeInMeters: distanceInMeters,
      isUserInsideGeofence: isInsideGeofence,
    ));
  }
}
