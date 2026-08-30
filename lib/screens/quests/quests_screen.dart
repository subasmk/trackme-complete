import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/quest_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../models/quest.dart';
import 'quest_detail_screen.dart';
import 'add_quest_screen.dart';

class QuestsScreen extends StatelessWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final questService = context.watch<QuestService>();
    final quests = questService.quests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Quests'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Text(
              '${questService.completedTodayCount}/${questService.totalQuestsCount} today',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddQuestScreen()),
        ),
        backgroundColor: AppColors.purpleMid,
        child: const Icon(Icons.add, color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: quests.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, 100),
                itemCount: quests.length,
                itemBuilder: (context, index) {
                  final quest = quests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _QuestCard(quest: quest),
                  );
                },
              ),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final Quest quest;
  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final done = quest.isCompletedToday;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuestDetailScreen(questId: quest.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: done
                ? AppColors.success.withOpacity(0.4)
                : AppColors.surfaceBorder,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Left: emoji + done ring
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: Text(quest.emoji, style: const TextStyle(fontSize: 26)),
                ),
                if (done)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(Icons.check, size: 10, color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            // Middle: info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quest.title, style: AppTextStyles.body, maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      _Chip(label: quest.type, color: AppColors.purpleMid),
                      const SizedBox(width: 6),
                      _Chip(
                        label: quest.difficulty,
                        color: _difficultyColor(quest.difficulty),
                      ),
                      if (quest.items.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _Chip(
                          label: '${quest.items.length} goals',
                          color: AppColors.textMuted,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: AppColors.flameOrange, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        '${quest.streak} day streak',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.flameOrange),
                      ),
                      if (quest.timeRange != null) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.schedule,
                            color: AppColors.textMuted, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          quest.timeRange!,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Right: XP badge
            Column(
              children: [
                Text(
                  '${quest.xp}',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.purpleLight,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text('XP', style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(String d) {
    switch (d) {
      case 'Easy':
        return AppColors.success;
      case 'Hard':
        return AppColors.flameRed;
      default:
        return AppColors.flameYellow;
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: AppTextStyles.caption.copyWith(color: color, fontSize: 10)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text('No quests yet', style: AppTextStyles.title),
            const SizedBox(height: 6),
            Text(
              'Tap the + button to create your first quest — a structured daily challenge with multiple goals.',
              style: AppTextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
