import 'package:equatable/equatable.dart';

import 'package:flutter/material.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();
  @override
  List<Object?> get props => [];
}

class InitializeCameraEvent extends CameraEvent {
  const InitializeCameraEvent();
}

class CaptureImageEvent extends CameraEvent {
  const CaptureImageEvent();
}

class SetZoomLevelEvent extends CameraEvent {
  final double zoom;
  const SetZoomLevelEvent(this.zoom);
  @override
  List<Object?> get props => [zoom];
}

/// Internal event — fired after debounce to actually apply zoom to hardware
class ApplyZoomEvent extends CameraEvent {
  final double zoom;
  const ApplyZoomEvent(this.zoom);
  @override
  List<Object?> get props => [zoom];
}

class SetFocusPointEvent extends CameraEvent {
  final Offset point;
  const SetFocusPointEvent(this.point);
  @override
  List<Object?> get props => [point];
}

class DisposeCameraEvent extends CameraEvent {
  const DisposeCameraEvent();
}

class ClearFocusIndicatorEvent extends CameraEvent {
  const ClearFocusIndicatorEvent();
}
