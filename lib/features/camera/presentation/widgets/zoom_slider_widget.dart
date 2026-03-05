/*
import 'package:flutter/material.dart';

/// Vertical zoom slider displayed along the side of the camera preview.
class ZoomSliderWidget extends StatelessWidget {
  final double currentZoom;
  final double minZoom;
  final double maxZoom;
  final ValueChanged<double> onZoomChanged;

  const ZoomSliderWidget({
    super.key,
    required this.currentZoom,
    required this.minZoom,
    required this.maxZoom,
    required this.onZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${currentZoom.toStringAsFixed(1)}×',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4.0),
        RotatedBox(
          quarterTurns: 3,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white38,
              thumbColor: Colors.white,
              overlayColor: Colors.white24,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              trackHeight: 2.0,
            ),
            child: Slider(
              value: currentZoom.clamp(minZoom, maxZoom),
              min: minZoom,
              max: maxZoom,
              onChanged: onZoomChanged,
            ),
          ),
        ),
      ],
    );
  }
}
*/


import 'package:flutter/material.dart';

class ZoomSliderWidget extends StatelessWidget {
  final double minZoom;
  final double maxZoom;
  final double currentZoom;
  final ValueChanged<double> onChanged;

  const ZoomSliderWidget({
    super.key,
    required this.minZoom,
    required this.maxZoom,
    required this.currentZoom,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.zoom_out, color: Colors.white, size: 18),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              trackHeight: 2,
            ),
            child: Slider(
              min: minZoom,
              max: maxZoom,
              value: currentZoom.clamp(minZoom, maxZoom),
              onChanged: onChanged,
            ),
          ),
        ),
        const Icon(Icons.zoom_in, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(
          '${currentZoom.toStringAsFixed(1)}x',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}