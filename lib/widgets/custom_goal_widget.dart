// custom_goal_widget.dart - Colorful custom goal widget with sloth mascot
// Matches the style shown in the reference image: colorful gradient cards,
// daily check markers, streak counters, and expressive sloth designs

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'sloth_mascot.dart';

/// A customizable goal widget with multiple color themes
/// Similar to the Android home widgets shown in the reference image
class CustomGoalWidget extends StatelessWidget {
  final String goalTitle;
  final int currentStreak;
  final int targetStreak;
  final Set<int> completedWeekdayIndices; // 0=Sun .. 6=Sat
  final String theme; // 'solar', 'aqua', 'lavender', 'forest', or 'default'
  final Color? customAccent; // Optional custom color override
  final VoidCallback? onTap;

  const CustomGoalWidget({
    super.key,
    required this.goalTitle,
    required this.currentStreak,
    required this.targetStreak,
    required this.completedWeekdayIndices,
    this.theme = 'solar',
    this.customAccent,
    this.onTap,
  });

  /// Get gradient based on theme
  LinearGradient get gradient {
    final acc = customAccent;
    if (acc != null) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [acc, acc.withOpacity(0.8), acc.withOpacity(0.7)],
      );
    }
    return ColorPalettes.getGradient(theme);
  }

  /// Get day pill color based on theme
  Color get dayPillColor {
    switch (theme) {
      case 'aqua': return AppColors.aquaTealMid;
      case 'lavender': return AppColors.lavenderMid;
      case 'forest': return AppColors.forestGreenMid;
      case 'solar':
      default: return AppColors.solarOrangeMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final week = [
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
      for (int i = 0; i < 7; i++)
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - i - 1)),
    ];
    final todayIndex = DateTime.now().weekday % 7 - 1;
    if (todayIndex < 0) todayIndex = DateTime.now().weekday - 1;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.md, AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Sloth mascot - changes based on streak progress
            Positioned(
              right: -4,
              top: -8,
              child: SlothMascot(
                size: 70,
                mood: currentStreak > targetStreak
                    ? SlothMood.celebrating
                    : currentStreak > 0
                        ? SlothMood.happy
                        : SlothMood.idle,
                showGlow: true,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Streak counter
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.local_fireplace_rounded,
                        color: Colors.white, fontSize: 28),
                    const SizedBox(width: 8),
                    Text(
                      '$currentStreak',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(duration: 300.ms).scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(width: 4),
                    Text(
                      currentStreak == 1 ? 'day' : 'days',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                
                // Goal title
                Text(
                  goalTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                
                // Progress indicator
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: targetStreak > 0
                              ? (currentStreak / targetStreak) * 150.clamp(0, 150)
                              : 150.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.9),
                                Colors.white.withOpacity(0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Target text
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Goal: $currentStreak / $targetStreak days',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                
                // Weekly checkin dots
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final dayIndex = i;
                    final isDone = completedWeekdayIndices.contains(dayIndex);
                    final isToday = dayIndex == todayIndex;
                    final isFuture = week[dayIndex].isAfter(DateTime.now()) &&
                        week[dayIndex].day != DateTime.now().day;
                    
                    return Column(
                      children: [
                        Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? Colors.white
                                : Colors.transparent,
                            border: Border.all(
                              color: isToday && !isDone
                                  ? Colors.white
                                  : Colors.white.withOpacity(isDone ? 0 : 0.3),
                              width: isToday && !isDone ? 2 : 1,
                            ),
                          ),
                          child: isDone
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: dayPillColor,
                                )
                              : null,
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Enhanced goal widget with more color variations
class ColorfulGoalCard extends StatelessWidget {
  final String title;
  final int streak;
  final int? maxStreak;
  final List<String> tags;
  final Color gradientStart;
  final Color gradientEnd;
  final int widgetHeight;

  const ColorfulGoalCard({
    super.key,
    required this.title,
    required this.streak,
    this.maxStreak,
    this.tags = const [],
    this.widgetHeight = 180,
    required this.gradientStart,
    required this.gradientEnd,
  });

  static const Map<String, List<Color>> presetGradients = {
    'solar': [Color(0xFFFFB347), Color(0xFFFF6B35)],
    'aqua': [Color(0xFF83C5BE), Color(0xFF268B83)],
    'lavender': [Color(0xFFBF5AF2), Color(0xFF8B5CF6)],
    'forest': [Color(0xFF84CC16), Color(0xFF2A9D8F)],
    'sunset': [Color(0xFFF48FB1), Color(0xFFF992B8)],
    'ocean': [Color(0xFF74B9FF), Color(0xFF0984E3)],
    'fire': [Color(0xFFFF6B35), Color(0xFFE84393)],
    'nature': [Color(0xFF55A366), Color(0xFF27AE60)],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widgetHeight.toDouble(),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sloth mascot header
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SlothMascot(
                size: 40,
                mood: streak > 0 ? SlothMood.happy : SlothMood.idle,
                showGlow: false,
              ),
            ],
          ),
          
          // Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Streak display
          Row(
            children: [
              const Icon(Icons.local_fireplace_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                '$streak day${streak != 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (maxStreak != null) ...[
                const SizedBox(width: 8),
                Text(
                  '/ $maxStreak',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
          
          // Tags
          if (tags.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}