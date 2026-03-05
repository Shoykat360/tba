import 'package:equatable/equatable.dart';

/// Represents the current configuration state of the camera hardware.
/// Pure Dart — no Flutter or camera package imports.
class CameraConfiguration extends Equatable {
  final double currentZoomLevel;
  final double minZoomLevel;
  final double maxZoomLevel;

  /// Available preset zoom levels derived from camera lens focal lengths.
  /// e.g. [0.5, 1.0, 2.0]
  final List<double> availablePresetZoomLevels;

  /// Whether the camera is currently locked onto a manual focus point.
  final bool isManualFocusActive;

  /// Normalised offset (0.0–1.0) of the manual focus tap point.
  /// Null when auto-focus is active.
  final double? focusPointX;
  final double? focusPointY;

  const CameraConfiguration({
    required this.currentZoomLevel,
    required this.minZoomLevel,
    required this.maxZoomLevel,
    required this.availablePresetZoomLevels,
    this.isManualFocusActive = false,
    this.focusPointX,
    this.focusPointY,
  });

  CameraConfiguration copyWith({
    double? currentZoomLevel,
    double? minZoomLevel,
    double? maxZoomLevel,
    List<double>? availablePresetZoomLevels,
    bool? isManualFocusActive,
    double? focusPointX,
    double? focusPointY,
    bool clearFocusPoint = false,
  }) {
    return CameraConfiguration(
      currentZoomLevel: currentZoomLevel ?? this.currentZoomLevel,
      minZoomLevel: minZoomLevel ?? this.minZoomLevel,
      maxZoomLevel: maxZoomLevel ?? this.maxZoomLevel,
      availablePresetZoomLevels:
          availablePresetZoomLevels ?? this.availablePresetZoomLevels,
      isManualFocusActive: isManualFocusActive ?? this.isManualFocusActive,
      focusPointX: clearFocusPoint ? null : (focusPointX ?? this.focusPointX),
      focusPointY: clearFocusPoint ? null : (focusPointY ?? this.focusPointY),
    );
  }

  @override
  List<Object?> get props => [
        currentZoomLevel,
        minZoomLevel,
        maxZoomLevel,
        availablePresetZoomLevels,
        isManualFocusActive,
        focusPointX,
        focusPointY,
      ];
}
