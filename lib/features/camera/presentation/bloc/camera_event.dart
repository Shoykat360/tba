/*
import 'package:equatable/equatable.dart';
import 'package:flutter/gestures.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when [CameraPreviewScreen] mounts — initialises the camera hardware.
class CameraInitializedEvent extends CameraEvent {
  const CameraInitializedEvent();
}

/// Fired by the pinch gesture recogniser on the preview.
class PinchToZoomUpdated extends CameraEvent {
  /// The current pinch scale from [ScaleUpdateDetails.scale].
  final double pinchScale;

  const PinchToZoomUpdated({required this.pinchScale});

  @override
  List<Object?> get props => [pinchScale];
}

/// Fired when the user drags the zoom slider or taps a preset button.
class ZoomLevelChangeRequested extends CameraEvent {
  final double zoomLevel;

  const ZoomLevelChangeRequested({required this.zoomLevel});

  @override
  List<Object?> get props => [zoomLevel];
}

/// Fired when the user taps the preview frame to set a manual focus point.
class ManualFocusPointSet extends CameraEvent {
  final TapDownDetails tapDetails;

  /// Width of the camera preview widget — required to normalise the tap offset.
  final double previewWidth;

  /// Height of the camera preview widget — required to normalise the tap offset.
  final double previewHeight;

  const ManualFocusPointSet({
    required this.tapDetails,
    required this.previewWidth,
    required this.previewHeight,
  });

  @override
  List<Object?> get props => [tapDetails, previewWidth, previewHeight];
}

/// Fired when user taps one of the rounded preset zoom buttons (0.5x, 1x…).
class PresetZoomLevelSelected extends CameraEvent {
  final double presetZoomLevel;

  const PresetZoomLevelSelected({required this.presetZoomLevel});

  @override
  List<Object?> get props => [presetZoomLevel];
}

/// Fired when user taps the shutter button.
class ShutterButtonPressed extends CameraEvent {
  const ShutterButtonPressed();
}

/// Fired when the camera screen is disposed.
class CameraDisposedEvent extends CameraEvent {
  const CameraDisposedEvent();
}
*/


