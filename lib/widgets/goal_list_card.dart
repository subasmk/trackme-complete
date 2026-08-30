import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/widget_themes.dart';

/// A single row in the home screen's goal list. Shows the goal's emoji,
/// title, current streak, daily target, a level-progress bar, and a
/// checkmark badge when it's already been completed today. Accented with
/// the goal's own color theme so goals stay visually distinct at a glance,
/// matching their widget's color.
class GoalListCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const GoalListCard({super.key, required this.goal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final done = goal.isCompletedToday;
    final theme = WidgetThemes.byId(goal.themeId);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: done ? theme.mid.withOpacity(0.6) : AppColors.surfaceBorder,
            width: done ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.mid.withOpacity(0.18),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(goal.emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          goal.title,
                          style: AppTextStyles.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('🔥', style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 2),
                      Text(
                        '${goal.streak}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.flameOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${goal.dailyMinutes} min/day · Lv ${goal.level}',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: goal.levelProgress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation(theme.mid),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? AppColors.success.withOpacity(0.15)
                    : AppColors.surfaceLight,
                border: Border.all(
                  color: done ? AppColors.success : AppColors.surfaceBorder,
                  width: 1.5,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 16, color: AppColors.success)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
