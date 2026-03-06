import 'package:flutter/material.dart';

class ZoomPresetButtonsWidget extends StatelessWidget {
  final List<double> presets;
  final double currentZoom;
  final ValueChanged<double> onPresetTap;

  const ZoomPresetButtonsWidget({
    super.key,
    required this.presets,
    required this.currentZoom,
    required this.onPresetTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: presets.map((preset) {
        final isSelected = (currentZoom - preset).abs() < 0.05;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => onPresetTap(preset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.yellowAccent
                    : Colors.black.withOpacity(0.5),
                border: Border.all(
                  color: isSelected ? Colors.yellowAccent : Colors.white54,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  preset == 0.5 ? '.5x' : '${preset.toStringAsFixed(0)}x',
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
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
