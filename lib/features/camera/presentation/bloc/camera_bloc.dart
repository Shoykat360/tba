/*
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/either_extensions.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/camera_repository_impl.dart';
import '../../domain/entities/camera_configuration.dart';
import '../../domain/usecases/capture_image_and_store_locally.dart';
import '../../domain/usecases/initialize_camera.dart';
import '../../domain/usecases/set_camera_zoom_level.dart';
import '../../domain/usecases/set_manual_focus_point.dart';
import 'camera_event.dart';
import 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final InitializeCamera _initializeCamera;
  final CaptureImageAndStoreLocally _captureImageAndStoreLocally;
  final SetCameraZoomLevel _setCameraZoomLevel;
  final SetManualFocusPoint _setManualFocusPoint;

  /// The concrete repository implementation is injected here — and only here —
  /// so [CameraBloc] can retrieve the live [CameraController] for the
  /// [CameraPreview] widget. The domain interface does not expose the
  /// controller because it is a Flutter/camera-package type that must not
  /// enter the domain layer.
  final CameraRepositoryImpl _cameraRepositoryImpl;

  CameraBloc({
    required InitializeCamera initializeCamera,
    required CaptureImageAndStoreLocally captureImageAndStoreLocally,
    required SetCameraZoomLevel setCameraZoomLevel,
    required SetManualFocusPoint setManualFocusPoint,
    required CameraRepositoryImpl cameraRepositoryImpl,
  })  : _initializeCamera = initializeCamera,
        _captureImageAndStoreLocally = captureImageAndStoreLocally,
        _setCameraZoomLevel = setCameraZoomLevel,
        _setManualFocusPoint = setManualFocusPoint,
        _cameraRepositoryImpl = cameraRepositoryImpl,
        super(const CameraInitialState()) {
    on<CameraInitializedEvent>(_onCameraInitialized);
    on<PinchToZoomUpdated>(_onPinchToZoomUpdated);
    on<ZoomLevelChangeRequested>(_onZoomLevelChangeRequested);
    on<ManualFocusPointSet>(_onManualFocusPointSet);
    on<PresetZoomLevelSelected>(_onPresetZoomLevelSelected);
    on<ShutterButtonPressed>(_onShutterButtonPressed);
    on<CameraDisposedEvent>(_onCameraDisposed);
  }

  // ---------------------------------------------------------------------------
  // Event Handlers
  // ---------------------------------------------------------------------------

  Future<void> _onCameraInitialized(
    CameraInitializedEvent event,
    Emitter<CameraState> emit,
  ) async {
    emit(const CameraInitializingState());

    final result = await _initializeCamera(const NoParams());

    if (result.isLeft()) {
      _emitCameraFailureState(result.leftOrThrow, emit);
      return;
    }

    final CameraConfiguration config = result.rightOrThrow;
    final CameraController? controller =
        _cameraRepositoryImpl.activeCameraController;

    if (controller == null) {
      emit(const CameraErrorState(
        errorMessage: 'Camera controller unavailable after initialisation.',
      ));
      return;
    }

    emit(CameraReadyState(
      cameraController: controller,
      cameraConfiguration: config,
      pinchStartZoomLevel: config.minZoomLevel,
    ));
  }

  Future<void> _onPinchToZoomUpdated(
    PinchToZoomUpdated event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReadyState) return;
    final CameraReadyState readyState = state as CameraReadyState;

    final double newZoom = _calculateZoomFromPinchScale(
      pinchScale: event.pinchScale,
      baseZoom: readyState.pinchStartZoomLevel,
      minZoom: readyState.cameraConfiguration.minZoomLevel,
      maxZoom: readyState.cameraConfiguration.maxZoomLevel,
    );

    await _applyZoomAndUpdateState(newZoom, readyState, emit);
  }

  Future<void> _onZoomLevelChangeRequested(
    ZoomLevelChangeRequested event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReadyState) return;
    final CameraReadyState readyState = state as CameraReadyState;

    final double clampedZoom = event.zoomLevel.clamp(
      readyState.cameraConfiguration.minZoomLevel,
      readyState.cameraConfiguration.maxZoomLevel,
    );

    await _applyZoomAndUpdateState(clampedZoom, readyState, emit);
  }

  Future<void> _onManualFocusPointSet(
    ManualFocusPointSet event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReadyState) return;
    final CameraReadyState readyState = state as CameraReadyState;

    final double normalisedX =
        event.tapDetails.localPosition.dx / event.previewWidth;
    final double normalisedY =
        event.tapDetails.localPosition.dy / event.previewHeight;

    final result = await _setManualFocusPoint(
      SetManualFocusPointParams(x: normalisedX, y: normalisedY),
    );

    // Focus failures are non-fatal — the preview remains usable.
    if (result.isLeft()) return;

    final CameraConfiguration updatedConfig =
        readyState.cameraConfiguration.copyWith(
      isManualFocusActive: true,
      focusPointX: normalisedX,
      focusPointY: normalisedY,
    );

    emit(readyState.copyWith(cameraConfiguration: updatedConfig));
  }

  Future<void> _onPresetZoomLevelSelected(
    PresetZoomLevelSelected event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReadyState) return;
    final CameraReadyState readyState = state as CameraReadyState;
    await _applyZoomAndUpdateState(event.presetZoomLevel, readyState, emit);
  }

  Future<void> _onShutterButtonPressed(
    ShutterButtonPressed event,
    Emitter<CameraState> emit,
  ) async {
    if (state is! CameraReadyState) return;
    final CameraReadyState readyState = state as CameraReadyState;

    // Debounce rapid shutter taps.
    if (readyState.isCapturing) return;

    emit(readyState.copyWith(isCapturing: true));

    final result = await _captureImageAndStoreLocally(const NoParams());

    if (result.isLeft()) {
      emit(readyState.copyWith(isCapturing: false));
      emit(CameraErrorState(errorMessage: result.leftOrThrow.message));
      return;
    }

    final capturedImage = result.rightOrThrow;

    // One-shot state — [SyncBloc] listens for this to queue the new image.
    emit(ImageCapturedSuccessState(capturedImage: capturedImage));

    // Restore ready state with capture flag off and last captured image set.
    emit(readyState.copyWith(
      isCapturing: false,
      lastCapturedImage: capturedImage,
    ));
  }

  Future<void> _onCameraDisposed(
    CameraDisposedEvent event,
    Emitter<CameraState> emit,
  ) async {
    emit(const CameraInitialState());
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  /// Calculates zoom from pinch by multiplying the base (start-of-gesture)
  /// zoom by the current scale factor, then clamping to hardware limits.
  double _calculateZoomFromPinchScale({
    required double pinchScale,
    required double baseZoom,
    required double minZoom,
    required double maxZoom,
  }) {
    return (baseZoom * pinchScale).clamp(minZoom, maxZoom);
  }

  /// Sends the zoom level to the camera hardware and updates the config state.
  Future<void> _applyZoomAndUpdateState(
    double zoomLevel,
    CameraReadyState readyState,
    Emitter<CameraState> emit,
  ) async {
    final result = await _setCameraZoomLevel(
      SetCameraZoomLevelParams(zoomLevel: zoomLevel),
    );

    // Zoom failures are non-fatal — silently ignore and preserve current state.
    if (result.isLeft()) return;

    final CameraConfiguration updatedConfig =
        readyState.cameraConfiguration.copyWith(
      currentZoomLevel: zoomLevel,
    );

    emit(readyState.copyWith(cameraConfiguration: updatedConfig));
  }

  /// Routes a [Failure] from the camera initialisation path to the correct
  /// typed error state so the UI can show the appropriate recovery action.
  void _emitCameraFailureState(Failure failure, Emitter<CameraState> emit) {
    if (failure is CameraPermissionDeniedFailure) {
      emit(CameraPermissionDeniedState(
        errorMessage: failure.message,
        isPermanentlyDenied: false,
      ));
    } else if (failure is CameraPermissionPermanentlyDeniedFailure) {
      emit(CameraPermissionDeniedState(
        errorMessage: failure.message,
        isPermanentlyDenied: true,
      ));
    } else if (failure is CameraHardwareUnavailableFailure) {
      emit(const CameraHardwareUnavailableState());
    } else {
      emit(CameraErrorState(errorMessage: failure.message));
    }
  }
}
*/


