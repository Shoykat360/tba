import 'package:flutter/material.dart';

/// Row of circular zoom preset buttons (e.g. .5x, 1x, 2x, 3x).
class ZoomPresetButtonsWidget extends StatelessWidget {
  final List<double> presets;
  final double currentZoom;
  final ValueChanged<double> onPresetTapped;

  const ZoomPresetButtonsWidget({
    super.key,
    required this.presets,
    required this.currentZoom,
    required this.onPresetTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: presets.map((preset) {
        final isActive = (currentZoom - preset).abs() < 0.05;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => onPresetTapped(preset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? Colors.yellowAccent
                    : Colors.black.withOpacity(0.55),
                border: Border.all(
                  color: isActive
                      ? Colors.yellowAccent
                      : Colors.white54,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  preset == 0.5
                      ? '.5x'
                      : '${preset.toStringAsFixed(0)}x',
                  style: TextStyle(
                    color: isActive ? Colors.black : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
