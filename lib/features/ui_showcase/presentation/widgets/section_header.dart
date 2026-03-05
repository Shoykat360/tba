import 'package:flutter/material.dart';
import 'showcase_theme.dart';

/// A styled section header with a short animated left-border accent stripe
/// and optional trailing action widget.
class SectionHeader extends StatelessWidget {
  final String label;
  final Widget? trailing;
  final Color accentColor;

  const SectionHeader({
    super.key,
    required this.label,
    this.trailing,
    this.accentColor = ShowcaseTheme.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.0,
          height: 14.0,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(2.0),
          ),
        ),
        const SizedBox(width: ShowcaseTheme.spaceSm),
        Text(
          label.toUpperCase(),
          style: ShowcaseTheme.labelStyle(
            color: ShowcaseTheme.textSecondary,
            size: 11.0,
            spacing: 1.8,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
