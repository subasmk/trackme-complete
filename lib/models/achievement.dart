import 'package:flutter/material.dart';

/// Static definition of a badge/achievement. These are not persisted to Hive
/// directly — only the unlocked badge IDs are stored on [Goal.unlockedBadgeIds].
/// This class describes the badge's display info and unlock condition.
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function(int streak, int longestStreak, int xp, int level)
      condition;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.condition,
  });
}

/// The full catalog of achievements available in the app.
class AchievementCatalog {
  static final List<Achievement> all = [
    Achievement(
      id: 'streak_3',
      title: 'Getting Started',
      description: 'Reach a 3-day streak',
      icon: Icons.local_fire_department,
      color: const Color(0xFFFFA726),
      condition: (streak, longest, xp, level) => longest >= 3,
    ),
    Achievement(
      id: 'streak_7',
      title: 'One Week Wonder',
      description: 'Reach a 7-day streak',
      icon: Icons.whatshot,
      color: const Color(0xFFFF7043),
      condition: (streak, longest, xp, level) => longest >= 7,
    ),
    Achievement(
      id: 'streak_30',
      title: 'Unstoppable',
      description: 'Reach a 30-day streak',
      icon: Icons.emoji_events,
      color: const Color(0xFFFFD54F),
      condition: (streak, longest, xp, level) => longest >= 30,
    ),
    Achievement(
      id: 'streak_100',
      title: 'Centurion',
      description: 'Reach a 100-day streak',
      icon: Icons.military_tech,
      color: const Color(0xFFFF5252),
      condition: (streak, longest, xp, level) => longest >= 100,
    ),
    Achievement(
      id: 'level_5',
      title: 'Rising Star',
      description: 'Reach Level 5',
      icon: Icons.star,
      color: const Color(0xFF9C6BFF),
      condition: (streak, longest, xp, level) => level >= 5,
    ),
    Achievement(
      id: 'level_10',
      title: 'Expert',
      description: 'Reach Level 10',
      icon: Icons.auto_awesome,
      color: const Color(0xFF7C4DFF),
      condition: (streak, longest, xp, level) => level >= 10,
    ),
    Achievement(
      id: 'xp_500',
      title: 'XP Hunter',
      description: 'Earn 500 total XP',
      icon: Icons.bolt,
      color: const Color(0xFF64B5F6),
      condition: (streak, longest, xp, level) => xp >= 500,
    ),
  ];

  static List<Achievement> unlockedFor(
    int streak,
    int longestStreak,
    int xp,
    int level,
  ) {
    return all
        .where((a) => a.condition(streak, longestStreak, xp, level))
        .toList();
  }
}
