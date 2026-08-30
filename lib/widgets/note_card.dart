import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/goal.dart';
import '../models/learning_note.dart';
import '../services/goal_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import 'note_attachments.dart';
import 'edit_note_sheet.dart';

/// One note entry, with its date, text, attachments, and an edit/delete
/// menu. Used by both goal_detail_screen.dart's per-goal history (where
/// [showGoalHeader] is false, since the goal is already obvious from
/// context) and notes_screen.dart's cross-goal timeline (where it's true,
/// and [onTap] usually navigates to that goal).
class NoteCard extends StatelessWidget {
  final Goal goal;
  final LearningNote note;
  final bool showGoalHeader;
  final VoidCallback? onTap;

  const NoteCard({
    super.key,
    required this.goal,
    required this.note,
    this.showGoalHeader = false,
    this.onTap,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete this note?', style: AppTextStyles.title),
        content: const Text(
          'This removes the note and any attached photo or link. It won\'t change your streak.',
          style: AppTextStyles.bodyMuted,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<GoalService>().deleteNote(goal, note.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (showGoalHeader) ...[
                  Text(goal.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    goal.title,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.purpleLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                ] else
                  const Spacer(),
                Text(
                  DateFormat(showGoalHeader ? 'MMM d, yyyy' : 'EEE, MMM d, yyyy')
                      .format(note.date),
                  style: AppTextStyles.caption,
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.more_horiz,
                        size: 18, color: AppColors.textMuted),
                    color: AppColors.surfaceLight,
                    onSelected: (value) {
                      if (value == 'edit') {
                        showEditNoteSheet(context, goal: goal, note: note);
                      } else if (value == 'delete') {
                        _confirmDelete(context);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: AppColors.danger)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(note.text, style: AppTextStyles.body),
            NoteAttachments(note: note),
          ],
        ),
      ),
    );
  }
}
