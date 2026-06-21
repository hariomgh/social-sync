import 'package:flutter/material.dart';

/// Centralized color palette for the app and the social platforms it targets.
///
/// The brand language is an indigo→violet system with a blue→purple gradient on
/// primary CTAs, soft lavender surfaces, and rounded cards.
abstract final class AppColors {
  // Brand / app palette
  static const Color primary = Color(0xFF4F46E5); // indigo-600
  static const Color primaryAccent = Color(0xFF6366F1); // indigo-500
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color secondary = Color(0xFF8B5CF6); // violet
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF22C55E);

  /// Blue→purple gradient used on primary buttons and accents.
  static const List<Color> brandGradient = <Color>[
    Color(0xFF4C6FF5),
    Color(0xFF8A5BF6),
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    colors: brandGradient,
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Neutral surfaces (light)
  static const Color lightBackground = Color(0xFFF3F3FC); // lavender wash
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF1F1FE); // tinted fills
  static const Color lavenderFill = Color(0xFFECEBFE); // secondary buttons/pills
  static const Color lightOutline = Color(0xFFE7E7F2);
  static const Color lightTextPrimary = Color(0xFF1B1B2F);
  static const Color lightTextSecondary = Color(0xFF6E7191);
  static const Color sectionLabel = Color(0xFF9499B7); // uppercase labels

  // Neutral surfaces (dark)
  static const Color darkBackground = Color(0xFF121221);
  static const Color darkSurface = Color(0xFF1B1B2C);
  static const Color darkSurfaceAlt = Color(0xFF23233A);
  static const Color darkOutline = Color(0xFF2E2E45);
  static const Color darkTextPrimary = Color(0xFFF2F2F8);
  static const Color darkTextSecondary = Color(0xFFA6A8C4);

  // Platform brand colors
  static const Color instagram = Color(0xFFE1306C);
  static const Color facebook = Color(0xFF1877F2);
  static const Color linkedin = Color(0xFF0A66C2);
  static const Color x = Color(0xFF0F1419);

  /// Instagram's signature gradient, reused on avatars and chips.
  static const List<Color> instagramGradient = <Color>[
    Color(0xFFFEDA75),
    Color(0xFFFA7E1E),
    Color(0xFFD62976),
    Color(0xFF962FBF),
    Color(0xFF4F5BD5),
  ];
}
