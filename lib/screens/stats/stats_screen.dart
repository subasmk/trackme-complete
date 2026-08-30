import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/goal.dart';
import '../../services/goal_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/widget_themes.dart';
import '../../utils/date_utils_x.dart';
import '../../widgets/weekly_bar_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<GoalService>().goals;
    final week = DateUtilsX.weekDates(DateTime.now());

    final dailyMinutes = List<double>.filled(7, 0);
    var totalMinutes = 0;
    var totalCompletions = 0;
    final perGoalCompletions = <String, int>{}; // keyed by goal.id

    for (final goal in goals) {
      var completionsThisWeek = 0;
      for (final note in goal.notes) {
        for (var i = 0; i < 7; i++) {
          if (DateUtilsX.isSameDay(note.date, week[i])) {
            dailyMinutes[i] += goal.dailyMinutes;
            totalMinutes += goal.dailyMinutes;
            totalCompletions++;
            completionsThisWeek++;
            break; // a note can only match one day of the week
          }
        }
      }
      perGoalCompletions[goal.id] = completionsThisWeek;
    }

    final hours = totalMinutes / 60;
    final timeLabel =
        totalMinutes >= 60 ? '${hours.toStringAsFixed(1)}h' : '${totalMinutes}m';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Weekly Stats'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'This week',
                    value: timeLabel,
                    icon: Icons.timer_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatCard(
                    label: 'Completions',
                    value: '$totalCompletions',
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            Text('Minutes per day', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: WeeklyBarChart(values: dailyMinutes),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text('By goal this week', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            if (goals.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: Text('No goals yet', style: AppTextStyles.bodyMuted),
                ),
              )
            else
              ...goals.map((goal) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _GoalWeekRow(
                      goal: goal,
                      completions: perGoalCompletions[goal.id] ?? 0,
                    ),
                  )),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.purpleLight, size: 22),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.display.copyWith(fontSize: 22)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _GoalWeekRow extends StatelessWidget {
  final Goal goal;
  final int completions;
  const _GoalWeekRow({required this.goal, required this.completions});

  @override
  Widget build(BuildContext context) {
    final theme = WidgetThemes.byId(goal.themeId);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        children: [
          Text(goal.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(goal.title,
                style: AppTextStyles.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.mid.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              '$completions/7 days',
              style: TextStyle(
                  color: theme.mid, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
