import 'package:flutter/material.dart';
import 'showcase_theme.dart';

/// A horizontally-scrolling set of toggle chips.
/// The selected chip animates a sliding pill underlay (not just a colour swap).
class AnimatedToggleChipGroup extends StatefulWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelectionChanged;
  final Color accentColor;

  const AnimatedToggleChipGroup({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelectionChanged,
    required this.accentColor,
  });

  @override
  State<AnimatedToggleChipGroup> createState() =>
      _AnimatedToggleChipGroupState();
}

class _AnimatedToggleChipGroupState extends State<AnimatedToggleChipGroup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.0,
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: ShowcaseTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(ShowcaseTheme.radiusSm + 3),
        border: Border.all(color: ShowcaseTheme.surfaceBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double chipWidth =
              (constraints.maxWidth - 6.0) / widget.labels.length;

          return Stack(
            children: [
              // Sliding pill — moves under the selected chip.
              AnimatedPositioned(
                duration: ShowcaseTheme.durationNormal,
                curve: ShowcaseTheme.curveInOut,
                left: chipWidth * widget.selectedIndex,
                top: 0,
                bottom: 0,
                width: chipWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.accentColor.withOpacity(0.18),
                    borderRadius:
                        BorderRadius.circular(ShowcaseTheme.radiusSm),
                    border: Border.all(
                      color: widget.accentColor.withOpacity(0.5),
                      width: 1.0,
                    ),
                  ),
                ),
              ),

              // Labels row.
              Row(
                children: List.generate(widget.labels.length, (index) {
                  final bool isSelected = index == widget.selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onSelectionChanged(index),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: ShowcaseTheme.durationNormal,
                          style: TextStyle(
                            color: isSelected
                                ? widget.accentColor
                                : ShowcaseTheme.textSecondary,
                            fontSize: 12.0,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            letterSpacing: 0.4,
                          ),
                          child: Text(widget.labels[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
