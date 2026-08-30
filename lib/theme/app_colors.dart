import 'package:flutter/material.dart';

/// Central color palette for TrackMe — dark navy blue premium theme.
/// Near-black navy backgrounds, a blue gradient for primary surfaces,
/// and warm orange-yellow flame accents for streak numbers.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF070D1A);
  static const Color backgroundElevated = Color(0xFF0D1626);

  // Surfaces (non-gradient cards / inputs)
  static const Color surface = Color(0xFF0F1E35);
  static const Color surfaceLight = Color(0xFF152843);
  static const Color surfaceBorder = Color(0x18FFFFFF); // white @ 9%

  // Blue brand ramp (light -> deep)
  static const Color purpleLight = Color(0xFF7EC8FF);
  static const Color purpleMid = Color(0xFF2D9BEF);
  static const Color purple = Color(0xFF1B7FD4);
  static const Color purpleDeep = Color(0xFF0D5BA3);
  static const Color purpleDarker = Color(0xFF063370);

  // Flame / streak accent
  static const Color flameYellow = Color(0xFFFFC15E);
  static const Color flameOrange = Color(0xFFFF7A45);
  static const Color flameRed = Color(0xFFFF5252);

  // Sloth mascot palette
  static const Color slothFur = Color(0xFFC9A27A);
  static const Color slothFurDark = Color(0xFF9C7752);
  static const Color slothFace = Color(0xFFF1DEC2);
  static const Color slothEyePatch = Color(0xFF6B4A32);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9DC4E8);
  static const Color textMuted = Color(0xFF5A8AAD);

  // Status
  static const Color success = Color(0xFF4ADE80);
  static const Color danger = Color(0xFFFF6B6B);

  /// Primary diagonal blue gradient used for the streak card, the main
  /// CTA button, and the home-screen Android widgets.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleLight, purpleMid, purpleDeep],
    stops: [0.0, 0.55, 1.0],
  );

  /// Slightly deeper gradient used for the celebration overlay background glow.
  static const LinearGradient celebrationGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [purpleDeep, purpleDarker],
  );

  /// Warm flame gradient for streak flame icons.
  static const LinearGradient flameGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [flameYellow, flameOrange],
  );

  /// Radial glow placed behind the sloth mascot, echoing the reference art.
  static RadialGradient mascotGlow({double opacity = 0.35}) => RadialGradient(
        colors: [
          purpleMid.withOpacity(opacity),
          purpleMid.withOpacity(0.0),
        ],
      );
}
