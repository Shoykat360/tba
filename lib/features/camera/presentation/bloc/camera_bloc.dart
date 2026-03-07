import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/either_extensions.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/camera_repository.dart';
import '../../domain/usecases/camera_usecases.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final InitializeCamera initializeCameraUseCase;
  final CaptureImageAndStoreLocally captureImageUseCase;
  final SetCameraZoomLevel setZoomLevelUseCase;
  final SetManualFocusPoint setFocusPointUseCase;
  final AddImageToUploadQueue addImageToQueueUseCase;
  final CameraRepository cameraRepository;

  Timer? _focusIndicatorTimer;

  // Zoom debounce prevents flooding the camera hardware API during pinch
  Timer? _zoomDebounceTimer;
  double _latestRequestedZoom = 1.0;

  CameraBloc({
    required this.initializeCameraUseCase,
    required this.captureImageUseCase,
    required this.setZoomLevelUseCase,
    required this.setFocusPointUseCase,
    required this.addImageToQueueUseCase,
    required this.cameraRepository,
  }) : super(const CameraInitial()) {
    on<InitializeCameraEvent>(_handleInitialize);
    on<CaptureImageEvent>(_handleCapture);
    on<SetZoomLevelEvent>(_handleSetZoom);
    on<ApplyZoomToHardwareEvent>(_handleApplyZoomToHardware);
    on<SetFocusPointEvent>(_handleSetFocus);
    on<DisposeCameraEvent>(_handleDispose);
    on<ClearFocusIndicatorEvent>(_handleClearFocusIndicator);
  }

  Future<void> _handleInitialize(
      InitializeCameraEvent event, Emitter<CameraState> emit) async {
    emit(const CameraLoading());

    final cameraResult = await initializeCameraUseCase(NoParams());
    if (cameraResult.leftOrNull != null) {
      emit(CameraError(
          cameraResult.leftOrNull?.message ?? 'Camera init failed'));
      return;
    }

    final controller = cameraResult.rightOrNull!;
    final configResult =
        await cameraRepository.getCameraConfiguration(controller);
    if (configResult.leftOrNull != null) {
      emit(CameraError(
          configResult.leftOrNull?.message ?? 'Failed to read camera config'));
      return;
    }

    _latestRequestedZoom = 1.0;
    emit(CameraReady(
      controller: controller,
      configuration: configResult.rightOrNull!,
    ));
  }

  Future<void> _handleCapture(
      CaptureImageEvent event, Emitter<CameraState> emit) async {
    final currentState = state;
    if (currentState is! CameraReady) return;

    emit(CameraCapturing(
      controller: currentState.controller,
      configuration: currentState.configuration,
    ));

    final captureResult =
        await captureImageUseCase(currentState.controller);
    if (captureResult.leftOrNull != null) {
      emit(CameraError(
          captureResult.leftOrNull?.message ?? 'Capture failed'));
      return;
    }

    final capturedImage = captureResult.rightOrNull!;

    // Queue image for upload — fire and forget, no await needed for UX
    await addImageToQueueUseCase(capturedImage);

    emit(CameraReady(
      controller: currentState.controller,
      configuration: currentState.configuration,
    ));
  }

  /// Updates UI zoom immediately for smooth feel, then debounces the
  /// actual camera hardware call by 50 ms to avoid API flooding.
  Future<void> _handleSetZoom(
      SetZoomLevelEvent event, Emitter<CameraState> emit) async {
    final currentState = state;
    if (currentState is! CameraReady) return;

    final clampedZoom = event.zoom.clamp(
      currentState.configuration.minZoom,
      currentState.configuration.maxZoom,
    );

    // Update UI immediately so slider/pinch feels instant
    emit(currentState.copyWith(
      configuration:
          currentState.configuration.copyWith(currentZoom: clampedZoom),
    ));

    // Store latest zoom and schedule hardware update
    _latestRequestedZoom = clampedZoom;
    _zoomDebounceTimer?.cancel();
    _zoomDebounceTimer =
        Timer(const Duration(milliseconds: 50), () {
      add(ApplyZoomToHardwareEvent(_latestRequestedZoom));
    });
  }

  /// Actually sets zoom on the camera hardware (called after debounce).
  Future<void> _handleApplyZoomToHardware(
      ApplyZoomToHardwareEvent event, Emitter<CameraState> emit) async {
    final currentState = state;
    if (currentState is! CameraReady) return;

    await setZoomLevelUseCase(ZoomLevelParams(
      controller: currentState.controller,
      zoom: event.zoom,
    ));
    // No emit needed — UI was already updated in _handleSetZoom
  }

  Future<void> _handleSetFocus(
      SetFocusPointEvent event, Emitter<CameraState> emit) async {
    final currentState = state;
    if (currentState is! CameraReady) return;

    final focusResult = await setFocusPointUseCase(FocusPointParams(
      controller: currentState.controller,
      point: event.point,
    ));

    if (focusResult.leftOrNull != null) return;

    emit(currentState.copyWith(
      focusPoint: event.point,
      showFocusIndicator: true,
    ));

    // Auto-hide the focus square after 2 seconds
    _focusIndicatorTimer?.cancel();
    _focusIndicatorTimer = Timer(const Duration(seconds: 2), () {
      add(const ClearFocusIndicatorEvent());
    });
  }

  Future<void> _handleDispose(
      DisposeCameraEvent event, Emitter<CameraState> emit) async {
    _zoomDebounceTimer?.cancel();
    _focusIndicatorTimer?.cancel();

    final currentState = state;
    if (currentState is CameraReady) {
      await cameraRepository.disposeCamera(currentState.controller);
    }

    emit(const CameraInitial());
  }

  void _handleClearFocusIndicator(
      ClearFocusIndicatorEvent event, Emitter<CameraState> emit) {
    final currentState = state;
    if (currentState is CameraReady) {
      emit(currentState.copyWith(showFocusIndicator: false));
    }
  }

  @override
  Future<void> close() {
    _zoomDebounceTimer?.cancel();
    _focusIndicatorTimer?.cancel();
    return super.close();
  }
}
