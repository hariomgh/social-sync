import 'package:flutter/material.dart';

/// Centralized color palette for the app and the social platforms it targets.
///
/// Platform brand colors are used for chips, badges and preview accents so the
/// composer feels native to each network.
abstract final class AppColors {
  // Brand / app palette
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF4B3FC4);
  static const Color secondary = Color(0xFF00B894);
  static const Color danger = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color success = Color(0xFF27AE60);

  // Neutral surfaces (light)
  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOutline = Color(0xFFE2E5EC);
  static const Color lightTextPrimary = Color(0xFF1A1C1E);
  static const Color lightTextSecondary = Color(0xFF5B6068);

  // Neutral surfaces (dark)
  static const Color darkBackground = Color(0xFF121316);
  static const Color darkSurface = Color(0xFF1C1E22);
  static const Color darkOutline = Color(0xFF2D3036);
  static const Color darkTextPrimary = Color(0xFFF2F3F5);
  static const Color darkTextSecondary = Color(0xFFA7ADB7);

  // Platform brand colors
  static const Color instagram = Color(0xFFE1306C);
  static const Color facebook = Color(0xFF1877F2);
  static const Color linkedin = Color(0xFF0A66C2);
  static const Color x = Color(0xFF000000);

  /// Instagram's signature gradient, reused on chips and connect buttons.
  static const List<Color> instagramGradient = <Color>[
    Color(0xFFFEDA75),
    Color(0xFFFA7E1E),
    Color(0xFFD62976),
    Color(0xFF962FBF),
    Color(0xFF4F5BD5),
  ];
}
