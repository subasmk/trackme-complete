import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/date_utils_x.dart';
import 'sloth_mascot.dart';

/// The large hero card at the top of the home screen: overall streak,
/// a personalized greeting, a Sunday-first weekly checkmark strip showing
/// which days had at least one goal completed, and the sloth mascot peeking
/// in from the right — all inside the signature purple gradient card.
class StreakCard extends StatelessWidget {
  final int streakDays;
  final String userName;
  final Set<int> completedWeekdayIndices; // 0=Sun .. 6=Sat, days with >=1 completion
  final VoidCallback? onTap;

  const StreakCard({
    super.key,
    required this.streakDays,
    required this.userName,
    required this.completedWeekdayIndices,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final week = DateUtilsX.weekDates(DateTime.now());
    final todayIndex = DateTime.now().weekday % 7;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.md, AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.purpleMid.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Sloth mascot peeking in from the top-right corner so it never covers Saturday.
            Positioned(
              right: -4,
              top: -8,
              child: SlothMascot(
                size: 82,
                mood: streakDays > 0 ? SlothMood.happy : SlothMood.idle,
                showGlow: false,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 8),
                    Text(
                      '$streakDays ${streakDays == 1 ? 'day' : 'days'}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(duration: 300.ms).scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        curve: Curves.easeOutBack),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep going, $userName!',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.purpleLight,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final isDone = completedWeekdayIndices.contains(i);
                    final isToday = i == todayIndex;
                    final isFuture = week[i].isAfter(DateTime.now()) &&
                        !DateUtilsX.isToday(week[i]);
                    return _DayPill(
                      letter: DateUtilsX.weekdayLetters[i],
                      isDone: isDone,
                      isToday: isToday,
                      isFuture: isFuture,
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

class _DayPill extends StatelessWidget {
  final String letter;
  final bool isDone;
  final bool isToday;
  final bool isFuture;

  const _DayPill({
    required this.letter,
    required this.isDone,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          letter,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.55),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? Colors.white : Colors.transparent,
            border: Border.all(
              color: isToday && !isDone
                  ? Colors.white
                  : Colors.white.withOpacity(isDone ? 0 : 0.25),
              width: isToday && !isDone ? 2 : 1.5,
            ),
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, size: 18, color: AppColors.purple)
              : null,
        ),
      ],
    );
  }
}
