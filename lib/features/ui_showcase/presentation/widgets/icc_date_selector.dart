import 'package:flutter/material.dart';
import 'showcase_theme.dart';
import 'icc_dummy_data.dart';

class IccDateSelector extends StatelessWidget {
  final int selectedDayIndex;
  final ValueChanged<int> onDaySelected;

  const IccDateSelector({
    super.key,
    required this.selectedDayIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ShowcaseTheme.surface,
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: List.generate(IccDummyData.dateTabs.length, (i) {
            final tab = IccDummyData.dateTabs[i];
            final isSelected = i == selectedDayIndex;
            return GestureDetector(
              onTap: () => onDaySelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? ShowcaseTheme.tabSelected : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? null
                      : Border.all(color: Colors.transparent),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${tab.day}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : ShowcaseTheme.textPrimary,
                          ),
                        ),
                        Text(
                          tab.month,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white70 : ShowcaseTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (tab.hasLiveIndicator)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4ADE80),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
