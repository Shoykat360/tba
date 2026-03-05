/*
import 'package:flutter/material.dart';

/// A row of rounded pill buttons representing discrete zoom preset levels.
/// e.g. 0.5×  1×  2×
class ZoomPresetButtonsWidget extends StatelessWidget {
  final List<double> presetZoomLevels;
  final double currentZoom;
  final ValueChanged<double> onPresetSelected;

  const ZoomPresetButtonsWidget({
    super.key,
    required this.presetZoomLevels,
    required this.currentZoom,
    required this.onPresetSelected,
  });

  bool _isActivePreset(double preset) =>
      (preset - currentZoom).abs() < 0.05;

  String _formatPresetLabel(double preset) {
    if (preset == preset.truncate().toDouble()) {
      return '${preset.toInt()}×';
    }
    return '${preset}×';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: presetZoomLevels.map((preset) {
        final bool isActive = _isActivePreset(preset);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GestureDetector(
            onTap: () => onPresetSelected(preset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.amber
                    : Colors.black54,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: isActive ? Colors.amber : Colors.white38,
                  width: 1.0,
                ),
              ),
              child: Text(
                _formatPresetLabel(preset),
                style: TextStyle(
                  color: isActive ? Colors.black : Colors.white,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
*/


import 'package:flutter/material.dart';

class ZoomPresetButtonsWidget extends StatelessWidget {
  final List<double> presets;
  final double currentZoom;
  final ValueChanged<double> onPresetSelected;

  const ZoomPresetButtonsWidget({
    super.key,
    required this.presets,
    required this.currentZoom,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: presets.map((preset) {
        final isSelected = (currentZoom - preset).abs() < 0.05;
        return GestureDetector(
          onTap: () => onPresetSelected(preset),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.yellow
                  : Colors.black.withOpacity(0.5),
              border: Border.all(
                color: isSelected ? Colors.yellow : Colors.white54,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                _formatPreset(preset),
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatPreset(double value) {
    if (value == value.truncateToDouble()) {
      return '${value.toInt()}x';
    }
    return '${value}x';
  }
}