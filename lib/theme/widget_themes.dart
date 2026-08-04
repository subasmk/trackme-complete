import 'package:flutter/material.dart';
import 'app_colors.dart';

/// One selectable color theme for a goal. The three stops mirror what's
/// needed on both sides of the app: [light]→[dark] make a Flutter
/// [LinearGradient], and the same three hex values are duplicated as
/// Android color resources (see android colors.xml, `theme_<id>_light/
/// mid/dark`) so a goal's widget matches its in-app card exactly.
class WidgetTheme {
  final String id;
  final String label;
  final Color light;
  final Color mid;
  final Color dark;

  const WidgetTheme({
    required this.id,
    required this.label,
    required this.light,
    required this.mid,
    required this.dark,
  });

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [light, mid, dark],
      );
}

/// The curated palette a goal can be assigned to — deliberately a small,
/// hand-picked set (like Duolingo's own course colors) rather than an
/// open-ended color wheel, so every combination still looks intentional.
class WidgetThemes {
  WidgetThemes._();

  // Reuses AppColors' existing purple ramp directly (rather than
  // duplicating its hex values here) so a goal left on the default
  // "Purple" theme matches the app's own signature purple — e.g. the home
  // screen's overall streak card — exactly, with no drift possible between
  // the two.
  static const purple = WidgetTheme(
    id: 'purple',
    label: 'Purple',
    light: AppColors.purpleLight,
    mid: AppColors.purpleMid,
    dark: AppColors.purpleDeep,
  );

  static const mint = WidgetTheme(
    id: 'mint',
    label: 'Mint',
    light: Color(0xFF6EE7B7),
    mid: Color(0xFF10B981),
    dark: Color(0xFF047857),
  );

  static const flame = WidgetTheme(
    id: 'flame',
    label: 'Flame',
    light: Color(0xFFFFB74D),
    mid: Color(0xFFFF9500),
    dark: Color(0xFFC2410C),
  );

  static const sky = WidgetTheme(
    id: 'sky',
    label: 'Sky',
    light: Color(0xFF7DD3FC),
    mid: Color(0xFF0EA5E9),
    dark: Color(0xFF0369A1),
  );

  static const berry = WidgetTheme(
    id: 'berry',
    label: 'Berry',
    light: Color(0xFFF9A8D4),
    mid: Color(0xFFEC4899),
    dark: Color(0xFF9D174D),
  );

  static const coral = WidgetTheme(
    id: 'coral',
    label: 'Coral',
    light: Color(0xFFFCA5A5),
    mid: Color(0xFFEF4444),
    dark: Color(0xFF991B1B),
  );

  static const gold = WidgetTheme(
    id: 'gold',
    label: 'Gold',
    light: Color(0xFFFDE68A),
    mid: Color(0xFFF59E0B),
    dark: Color(0xFFB45309),
  );

  static const List<WidgetTheme> all = [
    purple,
    mint,
    flame,
    sky,
    berry,
    coral,
    gold,
  ];

  static WidgetTheme byId(String? id) =>
      all.firstWhere((t) => t.id == id, orElse: () => purple);
}
