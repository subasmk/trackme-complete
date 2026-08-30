// widget_themes.dart - Additional color palettes for custom widgets
// Add to the same directory as app_colors.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Color palettes for the colorful custom goal widgets
/// (solar/aqua/lavender/forest themes - separate from the main app colors)
class ColorPalettes {
  ColorPalettes._();

  // --- Solar Theme: Warm oranges and yellows ---
  static const Color solarOrangeLight = Color(0xFFFFB347);
  static const Color solarOrangeMid = Color(0xFFFF6B35);
  static const Color solarOrangeDeep = Color(0xFFE63946);
  static const Color solarYellowLight = Color(0xFFF4A261);
  static const Color solarYellowMid = Color(0xFFFFC15E);
  static const Color solarYellowDeep = Color(0xFFFF7A45);

  static const LinearGradient solarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [solarOrangeLight, solarOrangeMid, solarOrangeDeep],
    stops: [0.0, 0.5, 1.0],
  );

  // --- Aqua Theme: Cool blues and teals ---
  static const Color aquaTealLight = Color(0xFF83C5BE);
  static const Color aquaTealMid = Color(0xFF268B83);
  static const Color aquaTealDeep = Color(0xFF006D77);
  static const Color aquaBlueLight = Color(0xFF5F27CD);
  static const Color aquaBlueMid = Color(0xFF6C5CE7);
  static const Color aquaBlueDeep = Color(0xFF4A2CFF);

  static const LinearGradient aquaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [aquaTealLight, aquaTealMid, aquaTealDeep],
    stops: [0.0, 0.5, 1.0],
  );

  // --- Lavender Theme: Purple and magenta ---
  static const Color lavenderLight = Color(0xFFBF5AF2);
  static const Color lavenderMid = Color(0xFF8B5CF6);
  static const Color lavenderDeep = Color(0xFF7C3AED);
  static const Color lavenderPinkLight = Color(0xFFEC4899);
  static const Color lavenderPinkMid = Color(0xFFF472B6);
  static const Color lavenderPinkDeep = Color(0xFFF97316);

  static const LinearGradient lavenderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lavenderLight, lavenderMid, lavenderDeep],
    stops: [0.0, 0.5, 1.0],
  );

  // --- Forest Theme: Greens and earth tones ---
  static const Color forestGreenLight = Color(0xFF84CC16);
  static const Color forestGreenMid = Color(0xFF2A9D8F);
  static const Color forestGreenDeep = Color(0xFF1F834D);
  static const Color forestLimeLight = Color(0xFFA8D51D);
  static const Color forestLimeMid = Color(0xFF7EE787);
  static const Color forestLimeDeep = Color(0xFF2F855A);

  static const LinearGradient forestGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [forestGreenLight, forestGreenMid, forestGreenDeep],
    stops: [0.0, 0.5, 1.0],
  );

  /// Get gradient for a specific theme
  static LinearGradient getGradient(String theme) {
    switch (theme) {
      case 'solar': return solarGradient;
      case 'aqua': return aquaGradient;
      case 'lavender': return lavenderGradient;
      case 'forest': return forestGradient;
      default: return AppColors.primaryGradient;
    }
  }
}
