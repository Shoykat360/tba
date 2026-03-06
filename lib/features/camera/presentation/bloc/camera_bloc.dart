/*
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/either_extensions.dart';
import '../../domain/usecases/initialize_camera.dart';
import '../../domain/usecases/capture_image_and_store_locally.dart';
import '../../domain/usecases/set_camera_zoom_level.dart';
import '../../domain/usecases/set_manual_focus_point.dart';
import '../../domain/usecases/add_image_to_upload_queue.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../../../core/usecases/usecase.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final InitializeCamera initializeCamera;
  final CaptureImageAndStoreLocally captureImage;
  final SetCameraZoomLevel setZoomLevel;
  final SetManualFocusPoint setFocusPoint;
  final AddImageToUploadQueue addToQueue;
  final CameraRepository cameraRepository;

  Timer? _focusTimer;

  CameraBloc({
    required this.initializeCamera,
    required this.captureImage,
    required this.setZoomLevel,
    required this.setFocusPoint,
    required this.addToQueue,
    required this.cameraRepository,
  }) : super(const CameraInitial()) {
    on<InitializeCameraEvent>(_onInitialize);
    on<CaptureImageEvent>(_onCapture);
    on<SetZoomLevelEvent>(_onSetZoom);
    on<SetFocusPointEvent>(_onSetFocus);
    on<DisposeCameraEvent>(_onDispose);
    on<ClearFocusIndicatorEvent>(_onClearFocus);
  }

  Future<void> _onInitialize(
      InitializeCameraEvent event, Emitter<CameraState> emit) async {
    emit(const CameraLoading());

    final result = await initializeCamera(NoParams());

    if (result.leftOrNull != null) {
      emit(CameraError(result.leftOrNull?.message ?? 'Camera initialization failed'));
      return;
    }

    final controller = result.rightOrNull!;

    final configResult = await cameraRepository.getCameraConfiguration(controller);

    if (configResult.leftOrNull != null) {
      emit(CameraError(configResult.leftOrNull?.message ?? 'Failed to get camera config'));
      return;
    }

    emit(CameraReady(
      controller: controller,
      configuration: configResult.rightOrNull!,
    ));
  }

  Future<void> _onCapture(
      CaptureImageEvent event, Emitter<CameraState> emit) async {
    final current = state;
    if (current is! CameraReady) return;

    emit(CameraCapturing(
      controller: current.controller,
      configuration: current.configuration,
    ));

    final result = await captureImage(current.controller);

    if (result.leftOrNull != null) {
      emit(CameraError(result.leftOrNull?.message ?? 'Capture failed'));
      return;
    }

    final image = result.rightOrNull!;
    await addToQueue(image);

    emit(CameraReady(
      controller: current.controller,
      configuration: current.configuration,
    ));
  }

  */
/*Future<void> _onSetZoom(
      SetZoomLevelEvent event, Emitter<CameraState> emit) async {
    final current = state;
    if (current is! CameraReady) return;

    final clampedZoom = event.zoom.clamp(
      current.configuration.minZoom,
      current.configuration.maxZoom,
    );

    final result = await setZoomLevel(SetCameraZoomLevelParams(
      controller: current.controller,
      zoom: clampedZoom,
    ));

    if (result.rightOrNull != null) {
      emit(current.copyWith(
        configuration: current.configuration.copyWith(currentZoom: clampedZoom),
      ));
    }
  }*//*


  Future<void> _onSetZoom(
      SetZoomLevelEvent event, Emitter<CameraState> emit) async {
    final current = state;
    if (current is! CameraReady) return;

    final clampedZoom = event.zoom.clamp(
      current.configuration.minZoom,
      current.configuration.maxZoom,
    );

    final result = await setZoomLevel(SetCameraZoomLevelParams(
      controller: current.controller,
      zoom: clampedZoom,
    ));

    // Only update state if zoom succeeded (no failure)
    if (result.leftOrNull == null) {
      emit(current.copyWith(
        configuration: current.configuration.copyWith(currentZoom: clampedZoom),
      ));
    }
  }

  Future<void> _onSetFocus(
      SetFocusPointEvent event, Emitter<CameraState> emit) async {
    final current = state;
    if (current is! CameraReady) return;

    final result = await setFocusPoint(SetManualFocusPointParams(
      controller: current.controller,
      point: event.point,
    ));

    if (result.leftOrNull != null) return;

    emit(current.copyWith(
      focusPoint: event.point,
      showFocusIndicator: true,
    ));

    _focusTimer?.cancel();
    _focusTimer = Timer(const Duration(seconds: 2), () {
      add(const ClearFocusIndicatorEvent());
    });
  }

  Future<void> _onDispose(
      DisposeCameraEvent event, Emitter<CameraState> emit) async {
    final current = state;
    if (current is CameraReady) {
      await cameraRepository.disposeCamera(current.controller);
    }
    _focusTimer?.cancel();
    emit(const CameraInitial());
  }

  void _onClearFocus(
      ClearFocusIndicatorEvent event, Emitter<CameraState> emit) {
    final current = state;
    if (current is CameraReady) {
      emit(current.copyWith(showFocusIndicator: false));
    }
  }

  @override
  Future<void> close() {
    _focusTimer?.cancel();
    return super.close();
  }
}*/

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/either_extensions.dart';
import '../../domain/usecases/initialize_camera.dart';
import '../../domain/usecases/capture_image_and_store_locally.dart';
import '../../domain/usecases/set_camera_zoom_level.dart';
import '../../domain/usecases/set_manual_focus_point.dart';
import '../../domain/usecases/add_image_to_upload_queue.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../../../core/usecases/usecase.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final InitializeCamera initializeCamera;
  final CaptureImageAndStoreLocally captureImage;
  final SetCameraZoomLevel setZoomLevel;
  final SetManualFocusPoint setFocusPoint;
  final AddImageToUploadQueue addToQueue;
  final CameraRepository cameraRepository;

  Timer? _focusTimer;
  // Debounce zoom to avoid flooding the camera API
  Timer? _zoomDebounce;
  double _pendingZoom = 1.0;

  CameraBloc({
    required this.initializeCamera,
    required this.captureImage,
    required this.setZoomLevel,
    required this.setFocusPoint,
    required this.addToQueue,
    required this.cameraRepository,
  }) : super(const CameraInitial()) {
    on<InitializeCameraEvent>(_onInitialize);
    on<CaptureImageEvent>(_onCapture);
    on<SetZoomLevelEvent>(_onSetZoom);
    on<SetFocusPointEvent>(_onSetFocus);
    on<DisposeCameraEvent>(_onDispose);
    on<ClearFocusIndicatorEvent>(_onClearFocus);
    on<ApplyZoomEvent>(_onApplyZoom);
  }

  Future<void> _onInitialize(
      InitializeCameraEvent event, Emitter<CameraState> emit) async {
    emit(const CameraLoading());

    final result = await initializeCamera(NoParams());

    if (result.leftOrNull != null) {
      emit(CameraError(result.leftOrNull?.message ?? 'Camera initialization failed'));
      return;
    }

    final controller = result.rightOrNull!;
    final configResult = await cameraRepository.getCameraConfiguration(controller);

    if (configResult.leftOrNull != null) {
      emit(CameraError(configResult.leftOrNull?.message ?? 'Failed to get camera config'));
      return;
    }

    _pendingZoom = 1.0;
    emit(CameraReady(
      controller: controller,
      configuration: configResult.rightOrNull!,
    ));
  }

  Future<void> _onCapture(
      CaptureImageEvent event, Emitter<CameraState> emit) async {
    final current = state;
    if (current is! CameraReady) return;

    emit(CameraCapturing(
      controller: current.controller,
      configuration: current.configuration,
    ));

    final result = await captureImage(current.controller);

    if (result.leftOrNull != null) {
      emit(CameraError(result.leftOrNull?.message ?? 'Capture failed'));
      return;
    }

    final image = result.rightOrNull!;
    await addToQueue(image);

    emit(CameraReady(
      controller: current.controller,
      configuration: current.configuration,
    ));
  }

  /// SetZoomLevelEvent: update UI state immediately for smooth feel,
  /// debounce the actual camera API call to avoid flooding it.
  Future<void> _onSetZoom(
      SetZoomLevelEvent event, Emitter<CameraState> emit) async {
    final current = state;
    if (current is! CameraReady) return;

    final clampedZoom = event.zoom.clamp(
      current.configuration.minZoom,
      current.configuration.maxZoom,
    );

    // Update UI immediately — makes pinch feel instant
    emit(current.copyWith(
      configuration: current.configuration.copyWith(currentZoom: clampedZoom),
    ));

    // Store pending and debounce actual camera call by 50ms
    _pendingZoom = clampedZoom;
    _zoomDebounce?.cancel();
    _zoomDebounce = Timer(const Duration(milliseconds: 50), () {
      add(ApplyZoomEvent(_pendingZoom));
    });
  }

  /// Actually applies zoom to the camera hardware (debounced)
  Future<void> _onApplyZoom(
      ApplyZoomEvent event, Emitter<CameraState> emit) async {
    final current = state;
    if (current is! CameraReady) return;

    await setZoomLevel(SetCameraZoomLevelParams(
      controller: current.controller,
      zoom: event.zoom,
    ));
    // No emit needed — UI was already updated in _onSetZoom
  }

  Future<void> _onSetFocus(
      SetFocusPointEvent event, Emitter<CameraState> emit) async {
    final current = state;
    if (current is! CameraReady) return;

    final result = await setFocusPoint(SetManualFocusPointParams(
      controller: current.controller,
      point: event.point,
    ));

    if (result.leftOrNull != null) return;

    emit(current.copyWith(
      focusPoint: event.point,
      showFocusIndicator: true,
    ));

    _focusTimer?.cancel();
    _focusTimer = Timer(const Duration(seconds: 2), () {
      add(const ClearFocusIndicatorEvent());
    });
  }

  Future<void> _onDispose(
      DisposeCameraEvent event, Emitter<CameraState> emit) async {
    _zoomDebounce?.cancel();
    _focusTimer?.cancel();
    final current = state;
    if (current is CameraReady) {
      await cameraRepository.disposeCamera(current.controller);
    }
    emit(const CameraInitial());
  }

  void _onClearFocus(
      ClearFocusIndicatorEvent event, Emitter<CameraState> emit) {
    final current = state;
    if (current is CameraReady) {
      emit(current.copyWith(showFocusIndicator: false));
    }
  }

  @override
  Future<void> close() {
    _zoomDebounce?.cancel();
    _focusTimer?.cancel();
    return super.close();
  }
}
