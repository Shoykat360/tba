class CameraConfiguration {
  final double minZoom;
  final double maxZoom;
  final double currentZoom;
  final List<double> availableZoomPresets;
  final bool isFocusSupported;

  const CameraConfiguration({
    required this.minZoom,
    required this.maxZoom,
    required this.currentZoom,
    required this.availableZoomPresets,
    required this.isFocusSupported,
  });

  CameraConfiguration copyWith({
    double? minZoom,
    double? maxZoom,
    double? currentZoom,
    List<double>? availableZoomPresets,
    bool? isFocusSupported,
  }) {
    return CameraConfiguration(
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      currentZoom: currentZoom ?? this.currentZoom,
      availableZoomPresets: availableZoomPresets ?? this.availableZoomPresets,
      isFocusSupported: isFocusSupported ?? this.isFocusSupported,
    );
  }
}
