// Updated color palette with more vibrant colors for custom widgets
import 'package:flutter/material.dart';

// ============================================================
// ColorPalettes - Multiple color schemes for customizable widgets
// ============================================================

/// Color palette for the "Solar" theme (warm, energetic)
class ColorPalettes {
  ColorPalettes._();

  // --- Solar Theme: Warm oranges and yellows ---
  static const Color solarBackground = Color(0xFF0C151F);
  static const Color solarBackgroundElevated = Color(0xFF142237);
  static const Color solarSurface = Color(0xFF1A2E45);
  static const Color solarSurfaceLight = Color(0xFF223A5C);
  static const Color solarSurfaceBorder = Color(0x20FFFFFF);

  // Solar gradient: sunrise colors
  static const Color solarOrangeLight = Color(0xFFFFB347);
  static const Color solarOrangeMid = Color(0xFFFF6B35);
  static const Color solarOrangeDeep = Color(0xFFE63946);
  static const Color solarYellowLight = Color(0xFFF4A261);
  static const Color solarYellowMid = Color(0xFF457B9C);
  static const Color solarYellowDeep = Color(0xFF2A9D8F);

  static const LinearGradient solarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [solarOrangeLight, solarOrangeMid, solarOrangeDeep],
    stops: [0.0, 0.5, 1.0],
  );

  // --- Aqua Theme: Cool blues and teals ---
  static const Color aquaBackground = Color(0xFF0D1B2A);
  static const Color aquaBackgroundElevated = Color(0xFF16283D);
  static const Color aquaSurface = Color(0xFF1B2E41);
  static const Color aquaSurfaceLight = Color(0xFF274062);
  static const Color aquaSurfaceBorder = Color(0x204ECBDB);

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
  static const Color lavenderBackground = Color(0xFF120A2E);
  static const Color lavenderBackgroundElevated = Color(0xFF1D143F);
  static const Color lavenderSurface = Color(0xFF2A1F4A);
  static const Color lavenderSurfaceLight = Color(0xFF3A2E5F);
  static const Color lavenderSurfaceBorder = Color(0x20A855FF);

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
  static const Color forestBackground = Color(0xFF0A120D);
  static const Color forestBackgroundElevated = Color(0xFF141F18);
  static const Color forestSurface = Color(0xFF1A271D);
  static const Color forestSurfaceLight = Color(0xFF26382D);
  static const Color forestSurfaceBorder = Color(0x203FA688);

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

  // ============================================================
  // Static getter for all themes - returns map of color sets
  // ============================================================

  /// Get complete color set for a specific theme
  static Map<String, Color> getThemeColors(String theme) {
    switch (theme) {
      case 'solar':
        return {
          'background': solarBackground,
          'backgroundElevated': solarBackgroundElevated,
          'surface': solarSurface,
          'surfaceLight': solarSurfaceLight,
          'surfaceBorder': solarSurfaceBorder,
          'gradient': solarGradient, // Can't return LinearGradient as Color, use below
        };
      case 'aqua':
        return {
          'background': aquaBackground,
          'backgroundElevated': aquaBackgroundElevated,
          'surface': aquaSurface,
          'surfaceLight': aquaSurfaceLight,
          'surfaceBorder': aquaSurfaceBorder,
        };
      case 'lavender':
        return {
          'background': lavenderBackground,
          'backgroundElevated': lavenderBackgroundElevated,
          'surface': lavenderSurface,
          'surfaceLight': lavenderSurfaceLight,
          'surfaceBorder': lavenderSurfaceBorder,
        };
      case 'forest':
        return {
          'background': forestBackground,
          'backgroundElevated': forestBackgroundElevated,
          'surface': forestSurface,
          'surfaceLight': forestSurfaceLight,
          'surfaceBorder': forestSurfaceBorder,
        };
      default:
        return {
          'background': AppColors.background,
          'backgroundElevated': AppColors.backgroundElevated,
          'surface': AppColors.surface,
          'surfaceLight': AppColors.surfaceLight,
          'surfaceBorder': AppColors.surfaceBorder,
        };
    }
  }

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

  /// Get all accent colors for a theme
  static Map<String, Color> getAccentColors(String theme) {
    switch (theme) {
      case 'solar':
        return {
          'orangeLight': solarOrangeLight,
          'orangeMid': solarOrangeMid,
          'orangeDeep': solarOrangeDeep,
          'yellowLight': solarYellowLight,
          'yellowMid': solarYellowMid,
          'yellowDeep': solarYellowDeep,
        };
      case 'aqua':
        return {
          'tealLight': aquaTealLight,
          'tealMid': aquaTealMid,
          'tealDeep': aquaTealDeep,
          'blueLight': aquaBlueLight,
          'blueMid': aquaBlueMid,
          'blueDeep': aquaBlueDeep,
        };
      case 'lavender':
        return {
          'lavenderLight': lavenderLight,
          'lavenderMid': lavenderMid,
          'lavenderDeep': lavenderDeep,
          'pinkLight': lavenderPinkLight,
          'pinkMid': lavenderPinkMid,
          'pinkDeep': lavenderPinkDeep,
        };
      case 'forest':
        return {
          'greenLight': forestGreenLight,
          'greenMid': forestGreenMid,
          'greenDeep': forestGreenDeep,
          'limeLight': forestLimeLight,
          'limeMid': forestLimeMid,
          'limeDeep': forestLimeDeep,
        };
      default:
        return {
          'flameYellow': AppColors.flameYellow,
          'flameOrange': AppColors.flameOrange,
          'flameRed': AppColors.flameRed,
        };
    }
  }
}

// Keep backward compatibility - export original AppColors
// (add export at end of file if needed)