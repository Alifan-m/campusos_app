import 'package:flutter/material.dart';

class AppColors {
  // Primary - University Blue
  static const Color primary = Color(0xFF005EA4);
  static const Color primaryContainer = Color(0xFF0077CE);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary - Orange accent
  static const Color secondary = Color(0xFFAB3500);
  static const Color secondaryContainer = Color(0xFFFE6A34);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Tertiary - Green
  static const Color tertiary = Color(0xFF006B1B);
  static const Color tertiaryContainer = Color(0xFF268630);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Surface
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);

  // Text
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF404752);
  static const Color outline = Color(0xFF707783);
  static const Color outlineVariant = Color(0xFFC0C7D4);

  // Status
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color success = Color(0xFF006B1B);

  // Convenience aliases
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textHint = outline;
  static const Color border = outlineVariant;
  static const Color divider = surfaceContainerHigh;
}
