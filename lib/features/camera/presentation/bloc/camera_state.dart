import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/camera_configuration.dart';
import 'package:flutter/material.dart';

abstract class CameraState extends Equatable {
  const CameraState();
  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {
  const CameraInitial();
}

class CameraLoading extends CameraState {
  const CameraLoading();
}

class CameraReady extends CameraState {
  final CameraController controller;
  final CameraConfiguration configuration;
  final Offset? focusPoint;
  final bool showFocusIndicator;

  const CameraReady({
    required this.controller,
    required this.configuration,
    this.focusPoint,
    this.showFocusIndicator = false,
  });

  CameraReady copyWith({
    CameraController? controller,
    CameraConfiguration? configuration,
    Offset? focusPoint,
    bool? showFocusIndicator,
  }) {
    return CameraReady(
      controller: controller ?? this.controller,
      configuration: configuration ?? this.configuration,
      focusPoint: focusPoint ?? this.focusPoint,
      showFocusIndicator: showFocusIndicator ?? this.showFocusIndicator,
    );
  }

  @override
  List<Object?> get props => [controller, configuration, focusPoint, showFocusIndicator];
}

class CameraCapturing extends CameraState {
  final CameraController controller;
  final CameraConfiguration configuration;

  const CameraCapturing({
    required this.controller,
    required this.configuration,
  });

  @override
  List<Object?> get props => [controller, configuration];
}

class CameraError extends CameraState {
  final String message;
  const CameraError(this.message);
  @override
  List<Object?> get props => [message];
}
