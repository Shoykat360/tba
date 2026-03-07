import 'package:flutter/material.dart';
import 'zoom_preset_buttons_widget.dart';
import 'zoom_slider_widget.dart';

/// Bottom overlay containing the shutter button, zoom slider and zoom presets.
class CameraControlsOverlay extends StatelessWidget {
  final double minZoom;
  final double maxZoom;
  final double currentZoom;
  final List<double> zoomPresets;
  final VoidCallback onCapture;
  final ValueChanged<double> onZoomChanged;
  final bool isCapturing;

  const CameraControlsOverlay({
    super.key,
    required this.minZoom,
    required this.maxZoom,
    required this.currentZoom,
    required this.zoomPresets,
    required this.onCapture,
    required this.onZoomChanged,
    required this.isCapturing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.75),
            Colors.transparent,
          ],
        ),
      ),
      padding: const EdgeInsets.only(bottom: 40, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ZoomSliderWidget(
              minZoom: minZoom,
              maxZoom: maxZoom,
              currentZoom: currentZoom,
              onChanged: onZoomChanged,
            ),
          ),
          const SizedBox(height: 12),

          // Preset zoom buttons (0.5x, 1x, 2x …)
          ZoomPresetButtonsWidget(
            presets: zoomPresets,
            currentZoom: currentZoom,
            onPresetTapped: onZoomChanged,
          ),
          const SizedBox(height: 24),

          // Shutter button
          GestureDetector(
            onTap: isCapturing ? null : onCapture,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: isCapturing ? 68 : 74,
              height: isCapturing ? 68 : 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCapturing
                    ? Colors.grey.shade500
                    : Colors.white,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: isCapturing
                  ? const Center(
                      child: SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
