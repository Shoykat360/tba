import 'package:flutter/material.dart';
import 'zoom_preset_buttons_widget.dart';
import 'zoom_slider_widget.dart';

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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
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
        const SizedBox(height: 16),

        // Zoom preset buttons
        ZoomPresetButtonsWidget(
          presets: zoomPresets,
          currentZoom: currentZoom,
          onPresetTap: onZoomChanged,
        ),
        const SizedBox(height: 24),

        // Capture button
        GestureDetector(
          onTap: isCapturing ? null : onCapture,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: isCapturing ? 68 : 72,
            height: isCapturing ? 68 : 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCapturing ? Colors.grey.shade400 : Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: isCapturing
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
