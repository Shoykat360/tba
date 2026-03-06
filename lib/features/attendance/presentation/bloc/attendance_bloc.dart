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