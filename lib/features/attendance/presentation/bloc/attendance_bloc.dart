/*
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extensions/either_extensions.dart';
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
  final FetchCurrentLocation _fetchCurrentLocation;
  final SaveOfficeLocationLocally _saveOfficeLocationLocally;
  final LoadSavedOfficeLocation _loadSavedOfficeLocation;
  final CalculateDistanceInMeters _calculateDistanceInMeters;
  final CheckIfUserIsWithinAllowedRadius _checkIfUserIsWithinAllowedRadius;
  final MarkAttendance _markAttendance;
  final Uuid _uuid;

  AttendanceBloc({
    required FetchCurrentLocation fetchCurrentLocation,
    required SaveOfficeLocationLocally saveOfficeLocationLocally,
    required LoadSavedOfficeLocation loadSavedOfficeLocation,
    required CalculateDistanceInMeters calculateDistanceInMeters,
    required CheckIfUserIsWithinAllowedRadius checkIfUserIsWithinAllowedRadius,
    required MarkAttendance markAttendance,
    required Uuid uuid,
  })  : _fetchCurrentLocation = fetchCurrentLocation,
        _saveOfficeLocationLocally = saveOfficeLocationLocally,
        _loadSavedOfficeLocation = loadSavedOfficeLocation,
        _calculateDistanceInMeters = calculateDistanceInMeters,
        _checkIfUserIsWithinAllowedRadius = checkIfUserIsWithinAllowedRadius,
        _markAttendance = markAttendance,
        _uuid = uuid,
        super(const AttendanceInitialState()) {
    on<AttendanceInitializedEvent>(_onAttendanceInitialized);
    on<FetchAndSaveOfficeLocationRequested>(
      _onFetchAndSaveOfficeLocationRequested,
    );
    on<RefreshCurrentLocationRequested>(_onRefreshCurrentLocationRequested);
    on<MarkAttendanceRequested>(_onMarkAttendanceRequested);
  }

  // ---------------------------------------------------------------------------
  // Event Handlers
  // ---------------------------------------------------------------------------

  /// Loads any previously saved office location on screen startup.
  /// A missing location is a normal first-run condition — not an error.
  Future<void> _onAttendanceInitialized(
    AttendanceInitializedEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const AttendanceLoadingState(
      loadingMessage: 'Loading saved office location...',
    ));

    final savedLocationResult =
        await _loadSavedOfficeLocation(const NoParams());

    savedLocationResult.fold(
      (failure) {
        if (failure is NoSavedOfficeLocationFailure) {
          // Expected on first run — emit an empty loaded state, not an error.
          emit(const AttendanceLoadedState(
            isWithinGeofence: false,
            hasMarkedAttendanceToday: false,
          ));
        } else {
          emit(AttendanceErrorState(errorMessage: failure.message));
        }
      },
      (officeLocation) {
        emit(AttendanceLoadedState(
          savedOfficeLocation: officeLocation,
          isWithinGeofence: false,
          hasMarkedAttendanceToday: false,
        ));
      },
    );
  }

  /// Fetches the user's current GPS coordinates and saves them as the
  /// office location. Because the user is at the office when doing this,
  /// distance is immediately 0 and geofence is satisfied.
  Future<void> _onFetchAndSaveOfficeLocationRequested(
    FetchAndSaveOfficeLocationRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final AttendanceLoadedState? previousState = _resolveCurrentLoadedState();
    _emitRefreshingOrLoading(
      previousState: previousState,
      loadingMessage: 'Fetching your current location...',
      emit: emit,
    );

    final Either<Failure, UserLocation> locationResult =
        await _fetchCurrentLocation(const NoParams());

    if (locationResult.isLeft()) {
      _emitLocationFailureState(locationResult.leftOrThrow, emit);
      return;
    }

    final UserLocation userLocation = locationResult.rightOrThrow;

    final OfficeLocation newOfficeLocation = OfficeLocation(
      latitude: userLocation.latitude,
      longitude: userLocation.longitude,
      savedAt: DateTime.now(),
    );

    final Either<Failure, void> saveResult = await _saveOfficeLocationLocally(
      SaveOfficeLocationLocallyParams(officeLocation: newOfficeLocation),
    );

    if (saveResult.isLeft()) {
      emit(AttendanceErrorState(errorMessage: saveResult.leftOrThrow.message));
      return;
    }

    // The user is standing at the office — distance is 0 and geofence passes.
    emit(AttendanceLoadedState(
      savedOfficeLocation: newOfficeLocation,
      currentUserLocation: userLocation,
      distanceFromOfficeInMeters: 0.0,
      isWithinGeofence: true,
      hasMarkedAttendanceToday: previousState?.hasMarkedAttendanceToday ?? false,
      latestAttendanceRecord: previousState?.latestAttendanceRecord,
    ));
  }

  /// Fetches the user's current GPS position and recalculates their distance
  /// from the saved office location.
  Future<void> _onRefreshCurrentLocationRequested(
    RefreshCurrentLocationRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final AttendanceLoadedState? previousState = _resolveCurrentLoadedState();
    _emitRefreshingOrLoading(
      previousState: previousState,
      loadingMessage: 'Refreshing your location...',
      emit: emit,
    );

    final Either<Failure, UserLocation> locationResult =
        await _fetchCurrentLocation(const NoParams());

    if (locationResult.isLeft()) {
      _emitLocationFailureState(locationResult.leftOrThrow, emit);
      return;
    }

    final UserLocation userLocation = locationResult.rightOrThrow;
    final OfficeLocation? savedOfficeLocation =
        previousState?.savedOfficeLocation;

    // If no office is set, show the live location without computing distance.
    if (savedOfficeLocation == null) {
      emit(AttendanceLoadedState(
        currentUserLocation: userLocation,
        isWithinGeofence: false,
        hasMarkedAttendanceToday:
            previousState?.hasMarkedAttendanceToday ?? false,
      ));
      return;
    }

    emit(_buildRefreshedLoadedState(
      previousState: previousState,
      userLocation: userLocation,
      savedOfficeLocation: savedOfficeLocation,
    ));
  }

  /// Validates business rules then persists the attendance record.
  ///
  /// The UI disables the button when geofence rules are violated, but we still
  /// guard here to prevent any unexpected direct event dispatch from bypassing
  /// the rules silently.
  Future<void> _onMarkAttendanceRequested(
    MarkAttendanceRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    final AttendanceLoadedState? loadedState = _resolveCurrentLoadedState();

    if (loadedState == null) {
      emit(const AttendanceErrorState(
        errorMessage:
            'Cannot mark attendance: screen is not in a valid state. Please restart.',
      ));
      return;
    }

    if (loadedState.currentUserLocation == null) {
      emit(const AttendanceErrorState(
        errorMessage:
            'Your current location is unknown. Please refresh your location first.',
      ));
      return;
    }

    if (!loadedState.isWithinGeofence) {
      emit(AttendanceErrorState(
        errorMessage: 'You are outside the office geofence. Move within '
            '${AppConstants.geofenceRadiusInMeters.toStringAsFixed(0)}m to mark attendance.',
      ));
      return;
    }

    emit(loadedState.asRefreshing());

    final AttendanceRecord newRecord = _buildAttendanceRecord(loadedState);

    final Either<Failure, void> markResult =
        await _markAttendance(MarkAttendanceParams(record: newRecord));

    if (markResult.isLeft()) {
      emit(AttendanceErrorState(errorMessage: markResult.leftOrThrow.message));
      return;
    }

    // One-shot success state — BlocConsumer listener shows the snackbar.
    emit(AttendanceMarkedSuccessState(markedRecord: newRecord));

    // Restore the loaded state with updated flags.
    emit(loadedState.copyWith(
      hasMarkedAttendanceToday: true,
      latestAttendanceRecord: newRecord,
      isRefreshing: false,
    ));
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Returns the current state cast to [AttendanceLoadedState], or null.
  AttendanceLoadedState? _resolveCurrentLoadedState() {
    return state is AttendanceLoadedState
        ? state as AttendanceLoadedState
        : null;
  }

  /// Emits an inline refresh indicator when data is already visible, or a
  /// full-screen loader during the initial fetch before any data exists.
  void _emitRefreshingOrLoading({
    required AttendanceLoadedState? previousState,
    required String loadingMessage,
    required Emitter<AttendanceState> emit,
  }) {
    if (previousState != null) {
      emit(previousState.asRefreshing());
    } else {
      emit(AttendanceLoadingState(loadingMessage: loadingMessage));
    }
  }

  /// Computes distance and geofence status, then returns a fully updated
  /// [AttendanceLoadedState] preserving all previous session data.
  AttendanceLoadedState _buildRefreshedLoadedState({
    required AttendanceLoadedState? previousState,
    required UserLocation userLocation,
    required OfficeLocation savedOfficeLocation,
  }) {
    final double distanceInMeters = _calculateDistanceInMeters(
      CalculateDistanceInMetersParams(
        fromLatitude: userLocation.latitude,
        fromLongitude: userLocation.longitude,
        toLatitude: savedOfficeLocation.latitude,
        toLongitude: savedOfficeLocation.longitude,
      ),
    );

    final bool isWithinGeofence = _checkIfUserIsWithinAllowedRadius(
      CheckIfUserIsWithinAllowedRadiusParams(
        distanceInMeters: distanceInMeters,
        allowedRadiusInMeters: AppConstants.geofenceRadiusInMeters,
      ),
    );

    return AttendanceLoadedState(
      savedOfficeLocation: savedOfficeLocation,
      currentUserLocation: userLocation,
      distanceFromOfficeInMeters: distanceInMeters,
      isWithinGeofence: isWithinGeofence,
      hasMarkedAttendanceToday:
          previousState?.hasMarkedAttendanceToday ?? false,
      latestAttendanceRecord: previousState?.latestAttendanceRecord,
      isRefreshing: false,
    );
  }

  /// Constructs a new [AttendanceRecord] stamped with the user's current GPS
  /// coordinates, current time, and distance from the office.
  AttendanceRecord _buildAttendanceRecord(AttendanceLoadedState loadedState) {
    final UserLocation currentLocation = loadedState.currentUserLocation!;
    return AttendanceRecord(
      id: _uuid.v4(),
      markedAt: DateTime.now(),
      latitude: currentLocation.latitude,
      longitude: currentLocation.longitude,
      distanceFromOfficeInMeters: loadedState.distanceFromOfficeInMeters ?? 0.0,
    );
  }

  /// Maps a location [Failure] subtype to its corresponding typed state.
  void _emitLocationFailureState(
    Failure failure,
    Emitter<AttendanceState> emit,
  ) {
    if (failure is LocationPermissionDeniedFailure) {
      emit(AttendancePermissionDeniedState(
        errorMessage: failure.message,
        isPermanentlyDenied: false,
      ));
    } else if (failure is LocationPermissionPermanentlyDeniedFailure) {
      emit(AttendancePermissionDeniedState(
        errorMessage: failure.message,
        isPermanentlyDenied: true,
      ));
    } else if (failure is LocationServiceDisabledFailure) {
      emit(AttendanceLocationServiceDisabledState(
        errorMessage: failure.message,
      ));
    } else {
      emit(AttendanceErrorState(errorMessage: failure.message));
    }
  }
}
*/


import 'package:equatable/equatable.dart';
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
    on<InitializeAttendanceEvent>(_onInitialize);
    on<SetOfficeLocationEvent>(_onSetOfficeLocation);
    on<RefreshUserLocationEvent>(_onRefreshUserLocation);
    on<MarkAttendanceEvent>(_onMarkAttendance);
  }

  Future<void> _onInitialize(
      InitializeAttendanceEvent event,
      Emitter<AttendanceState> emit,
      ) async {
    emit(state.copyWith(status: AttendanceStatus.loading));

    // Load saved office location
    final savedLocationResult = await loadSavedOfficeLocation(NoParams());
    final savedLocation = savedLocationResult.fold((_) => null, (l) => l);

    // Fetch current user location
    final locationResult = await fetchCurrentLocation(NoParams());

    await locationResult.fold(
          (failure) async {
        emit(state.copyWith(
          status: AttendanceStatus.failure,
          officeLocation: savedLocation,
          locationSetStatus: savedLocation != null
              ? LocationSetStatus.set
              : LocationSetStatus.notSet,
          errorMessage: failure.message,
        ));
      },
          (userLocation) async {
        if (savedLocation != null) {
          await _emitWithDistanceCalc(
            emit,
            userLocation: userLocation,
            officeLocation: savedLocation,
            locationSetStatus: LocationSetStatus.set,
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

  Future<void> _onSetOfficeLocation(
      SetOfficeLocationEvent event,
      Emitter<AttendanceState> emit,
      ) async {
    emit(state.copyWith(locationSetStatus: LocationSetStatus.setting));

    final locationResult = await fetchCurrentLocation(NoParams());

    await locationResult.fold(
          (failure) async {
        emit(state.copyWith(
          locationSetStatus: LocationSetStatus.failure,
          locationSetError: failure.message,
        ));
      },
          (userLocation) async {
        final officeLocation = OfficeLocation(
          latitude: userLocation.latitude,
          longitude: userLocation.longitude,
          savedAt: DateTime.now(),
        );

        final saveResult = await saveOfficeLocationLocally(
          SaveOfficeLocationParams(officeLocation),
        );

        await saveResult.fold(
              (failure) async {
            emit(state.copyWith(
              locationSetStatus: LocationSetStatus.failure,
              locationSetError: failure.message,
            ));
          },
              (_) async {
            await _emitWithDistanceCalc(
              emit,
              userLocation: userLocation,
              officeLocation: officeLocation,
              locationSetStatus: LocationSetStatus.set,
            );
          },
        );
      },
    );
  }

  Future<void> _onRefreshUserLocation(
      RefreshUserLocationEvent event,
      Emitter<AttendanceState> emit,
      ) async {
    emit(state.copyWith(status: AttendanceStatus.loading, clearError: true));

    final locationResult = await fetchCurrentLocation(NoParams());

    await locationResult.fold(
          (failure) async {
        emit(state.copyWith(
          status: AttendanceStatus.failure,
          errorMessage: failure.message,
        ));
      },
          (userLocation) async {
        if (state.officeLocation != null) {
          await _emitWithDistanceCalc(
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

  Future<void> _onMarkAttendance(
      MarkAttendanceEvent event,
      Emitter<AttendanceState> emit,
      ) async {
    if (!state.canMarkAttendance) return;

    emit(state.copyWith(isMarkingAttendance: true, clearAttendanceSuccess: true));

    final record = AttendanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      latitude: state.userLocation!.latitude,
      longitude: state.userLocation!.longitude,
      markedAt: DateTime.now(),
      distanceFromOffice: state.distanceInMeters ?? 0,
    );

    final result = await markAttendance(MarkAttendanceParams(record));

    result.fold(
          (failure) {
        emit(state.copyWith(
          isMarkingAttendance: false,
          errorMessage: failure.message,
        ));
      },
          (_) {
        final updatedHistory = [record, ...state.attendanceHistory];
        emit(state.copyWith(
          isMarkingAttendance: false,
          attendanceMarkedSuccessfully: true,
          attendanceHistory: updatedHistory,
        ));
      },
    );
  }

  Future<void> _emitWithDistanceCalc(
      Emitter<AttendanceState> emit, {
        required UserLocation userLocation,
        required OfficeLocation officeLocation,
        required LocationSetStatus locationSetStatus,
      }) async {
    final distanceResult = await calculateDistanceInMeters(
      CalculateDistanceParams(
        userLat: userLocation.latitude,
        userLon: userLocation.longitude,
        officeLat: officeLocation.latitude,
        officeLon: officeLocation.longitude,
      ),
    );

    final distance = distanceResult.fold((_) => 0.0, (d) => d);

    final withinResult = await checkIfUserIsWithinAllowedRadius(
      CheckRadiusParams(distance),
    );
    final isWithin = withinResult.fold((_) => false, (w) => w);

    emit(state.copyWith(
      status: AttendanceStatus.loaded,
      locationSetStatus: locationSetStatus,
      userLocation: userLocation,
      officeLocation: officeLocation,
      distanceInMeters: distance,
      isWithinRadius: isWithin,
    ));
  }
}