import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/learning_note.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Renders whatever a [LearningNote] has attached — a photo thumbnail
/// (tap to view full-screen), a tappable link chip, both, or neither (in
/// which case this renders nothing, so callers can always include it
/// unconditionally below a note's text).
class NoteAttachments extends StatelessWidget {
  final LearningNote note;
  const NoteAttachments({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    if (note.imagePath == null && note.linkUrl == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (note.imagePath != null) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showFullImage(context, note.imagePath!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.file(
                File(note.imagePath!),
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 72,
                  width: double.infinity,
                  color: AppColors.surfaceLight,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined,
                      color: AppColors.textMuted),
                ),
              ),
            ),
          ),
        ],
        if (note.linkUrl != null) ...[
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: () => _openLink(context, note.linkUrl!),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.link, size: 15, color: AppColors.purpleLight),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      note.linkUrl!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.purpleLight,
                        decoration: TextDecoration.underline,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openLink(BuildContext context, String url) async {
    var opened = false;
    try {
      opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  void _showFullImage(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Image.file(File(path)),
          ),
        ),
      ),
    );
  }
}
