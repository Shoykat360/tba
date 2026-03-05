import 'package:flutter/material.dart';

/// Design token system for the UI Reconstruction screen.
/// All colour, spacing, radius, and duration constants live here —
/// nothing is hardcoded in widget files.
abstract class ShowcaseTheme {
  ShowcaseTheme._();

  // ---------------------------------------------------------------------------
  // Colours
  // ---------------------------------------------------------------------------

  static const Color background     = Color(0xFF0D0F14);
  static const Color surface        = Color(0xFF151820);
  static const Color surfaceRaised  = Color(0xFF1C2030);
  static const Color surfaceBorder  = Color(0xFF262B3D);

  static const Color accent         = Color(0xFFF5A623);   // warm amber
  static const Color accentSoft     = Color(0x33F5A623);   // amber 20%
  static const Color accentDim      = Color(0x14F5A623);   // amber 8%

  static const Color success        = Color(0xFF2DD4BF);   // teal-mint
  static const Color successSoft    = Color(0x332DD4BF);
  static const Color danger         = Color(0xFFFF6B6B);   // coral
  static const Color dangerSoft     = Color(0x33FF6B6B);
  static const Color info           = Color(0xFF7B93FF);   // periwinkle
  static const Color infoSoft       = Color(0x337B93FF);

  static const Color textPrimary    = Color(0xFFE8EAF0);
  static const Color textSecondary  = Color(0xFF8890A6);
  static const Color textMuted      = Color(0xFF4A5066);

  // ---------------------------------------------------------------------------
  // Spacing
  // ---------------------------------------------------------------------------

  static const double spaceXs  = 4.0;
  static const double spaceSm  = 8.0;
  static const double spaceMd  = 16.0;
  static const double spaceLg  = 24.0;
  static const double spaceXl  = 32.0;
  static const double space2xl = 48.0;

  // ---------------------------------------------------------------------------
  // Border Radius
  // ---------------------------------------------------------------------------

  static const double radiusSm = 6.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 18.0;
  static const double radiusXl = 24.0;

  // ---------------------------------------------------------------------------
  // Animation Durations
  // ---------------------------------------------------------------------------

  static const Duration durationFast   = Duration(milliseconds: 180);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow   = Duration(milliseconds: 500);
  static const Duration durationXSlow  = Duration(milliseconds: 700);

  // ---------------------------------------------------------------------------
  // Curves
  // ---------------------------------------------------------------------------

  static const Curve curveIn    = Curves.easeIn;
  static const Curve curveOut   = Curves.easeOut;
  static const Curve curveInOut = Curves.easeInOut;
  static const Curve curveSpring = Curves.elasticOut;

  // ---------------------------------------------------------------------------
  // Typography helpers
  // ---------------------------------------------------------------------------

  static TextStyle labelStyle({
    double size    = 11.0,
    Color color    = textSecondary,
    FontWeight weight = FontWeight.w600,
    double spacing = 1.2,
  }) =>
      TextStyle(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: spacing,
        fontFamily: 'monospace',
      );

  static TextStyle valueStyle({
    double size    = 28.0,
    Color color    = textPrimary,
    FontWeight weight = FontWeight.w700,
  }) =>
      TextStyle(
        fontSize: size,
        color: color,
        fontWeight: weight,
        fontFamily: 'monospace',
      );

  static TextStyle bodyStyle({
    double size  = 14.0,
    Color color  = textSecondary,
  }) =>
      TextStyle(fontSize: size, color: color, height: 1.5);

  // ---------------------------------------------------------------------------
  // Shared decorations
  // ---------------------------------------------------------------------------

  static BoxDecoration cardDecoration({
    Color borderColor = surfaceBorder,
    Color bgColor     = surface,
    double radius     = radiusMd,
  }) =>
      BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 1.0),
      );

  static BoxDecoration accentCardDecoration() => BoxDecoration(
        color: accentDim,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: accentSoft, width: 1.0),
      );
}
