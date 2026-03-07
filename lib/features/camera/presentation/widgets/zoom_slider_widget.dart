import 'package:flutter/material.dart';

/// Horizontal slider for fine-grained zoom control.
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
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.zoom_out, color: Colors.white, size: 18),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white30,
                thumbColor: Colors.white,
                overlayColor: Colors.white24,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 8),
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
          SizedBox(
            width: 36,
            child: Text(
              '${currentZoom.toStringAsFixed(1)}x',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
