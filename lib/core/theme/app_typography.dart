import 'package:flutter/material.dart';

/// App-wide text theme. Uses the platform default font for performance and to
/// avoid bundling external font files; swap in `google_fonts` if desired.
abstract final class AppTypography {
  static const String fontFamily = 'Roboto';

  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: primary),
      bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: primary),
      bodySmall: TextStyle(fontSize: 12, height: 1.35, color: secondary),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
    );
  }
}
