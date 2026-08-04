import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/learning_note.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'hive_service.dart';

/// Exports every goal (with its notes, streaks, XP, and theme) plus the
/// user's display name to a single JSON file, and can restore from one.
///
/// Photos are embedded as base64 right inside the JSON rather than just
/// referencing their on-device path — a path from this install is
/// meaningless after a reinstall or on a different phone, so a "backup"
/// that didn't do this would silently lose every photo on restore.
class BackupService {
  BackupService._();

  static const int _formatVersion = 1;
  static const _uuid = Uuid();

  /// Builds the backup JSON, writes it to a temp file, and hands it to the
  /// OS share sheet so the user can save it to Drive, email it to
  /// themselves, etc. — TrackMe never uploads it anywhere itself.
  static Future<void> exportData() async {
    final data = await _buildExportJson();
    final tempDir = await getTemporaryDirectory();
    final fileName =
        'trackme_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(jsonEncode(data));

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'TrackMe backup',
        text: 'Your TrackMe data backup',
      ),
    );
  }

  static Future<Map<String, dynamic>> _buildExportJson() async {
    final goalsJson = <Map<String, dynamic>>[];

    for (final g in HiveService.goalsBox.values) {
      final notesJson = <Map<String, dynamic>>[];
      for (final n in g.notes) {
        String? imageBase64;
        String? imageExt;
        if (n.imagePath != null) {
          final imageFile = File(n.imagePath!);
          if (await imageFile.exists()) {
            imageBase64 = base64Encode(await imageFile.readAsBytes());
            imageExt =
                n.imagePath!.contains('.') ? n.imagePath!.split('.').last : 'jpg';
          }
        }
        notesJson.add({
          'id': n.id,
          'text': n.text,
          'date': n.date.toIso8601String(),
          'imageBase64': imageBase64,
          'imageExt': imageExt,
          'linkUrl': n.linkUrl,
        });
      }

      goalsJson.add({
        'id': g.id,
        'title': g.title,
        'emoji': g.emoji,
        'streak': g.streak,
        'longestStreak': g.longestStreak,
        'dailyMinutes': g.dailyMinutes,
        'lastCompleted': g.lastCompleted?.toIso8601String(),
        'xp': g.xp,
        'level': g.level,
        'createdAt': g.createdAt.toIso8601String(),
        'unlockedBadgeIds': g.unlockedBadgeIds,
        'themeId': g.themeId,
        'notes': notesJson,
      });
    }

    return {
      'version': _formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'userName': HiveService.settingsBox.get('user_name') ?? 'Learner',
      'goals': goalsJson,
    };
  }

  /// Lets the user pick a previously-exported JSON file, validates it,
  /// asks for confirmation (since this replaces everything currently in
  /// the app), and restores it. Returns true only if a restore actually
  /// happened — false if the user cancelled at any step or the file was
  /// invalid.
  static Future<bool> importData(BuildContext context) async {
    final FilePickerResult? picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = picked?.files.single.path;
    if (path == null) return false;

    Map<String, dynamic> data;
    try {
      final raw = await File(path).readAsString();
      data = jsonDecode(raw) as Map<String, dynamic>;
      if (data['version'] == null || data['goals'] is! List) {
        throw const FormatException('missing version/goals');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("That file doesn't look like a TrackMe backup")),
        );
      }
      return false;
    }

    if (!context.mounted) return false;
    final goalCount = (data['goals'] as List).length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Replace all data?', style: AppTextStyles.title),
        content: Text(
          'This restores $goalCount goal(s) from this backup and '
          'permanently replaces everything currently in the app. '
          "This can't be undone.",
          style: AppTextStyles.bodyMuted,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Replace', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    await _restoreFromJson(data);
    return true;
  }

  static Future<void> _restoreFromJson(Map<String, dynamic> data) async {
    await HiveService.goalsBox.clear();

    final docsDir = await getApplicationDocumentsDirectory();
    final notesDir = Directory('${docsDir.path}/note_images');
    if (!await notesDir.exists()) {
      await notesDir.create(recursive: true);
    }

    for (final rawGoal in (data['goals'] as List)) {
      final g = rawGoal as Map<String, dynamic>;

      final notes = <LearningNote>[];
      for (final rawNote in (g['notes'] as List? ?? const [])) {
        final n = rawNote as Map<String, dynamic>;
        String? imagePath;
        final base64Image = n['imageBase64'] as String?;
        if (base64Image != null) {
          try {
            final bytes = base64Decode(base64Image);
            final ext = (n['imageExt'] as String?) ?? 'jpg';
            final destPath = '${notesDir.path}/${_uuid.v4()}.$ext';
            await File(destPath).writeAsBytes(bytes);
            imagePath = destPath;
          } catch (_) {
            imagePath = null; // Corrupt image data; keep the note without it.
          }
        }
        notes.add(LearningNote(
          id: (n['id'] as String?) ?? _uuid.v4(),
          text: (n['text'] as String?) ?? '',
          date: DateTime.tryParse(n['date'] as String? ?? '') ?? DateTime.now(),
          imagePath: imagePath,
          linkUrl: n['linkUrl'] as String?,
        ));
      }

      final goal = Goal(
        id: (g['id'] as String?) ?? _uuid.v4(),
        title: (g['title'] as String?) ?? 'Goal',
        emoji: (g['emoji'] as String?) ?? '🎯',
        streak: (g['streak'] as num?)?.toInt() ?? 0,
        longestStreak: (g['longestStreak'] as num?)?.toInt() ?? 0,
        dailyMinutes: (g['dailyMinutes'] as num?)?.toInt() ?? 30,
        lastCompleted: g['lastCompleted'] != null
            ? DateTime.tryParse(g['lastCompleted'] as String)
            : null,
        notes: notes,
        xp: (g['xp'] as num?)?.toInt() ?? 0,
        level: (g['level'] as num?)?.toInt() ?? 1,
        createdAt:
            DateTime.tryParse(g['createdAt'] as String? ?? '') ?? DateTime.now(),
        unlockedBadgeIds:
            (g['unlockedBadgeIds'] as List?)?.cast<String>() ?? const [],
        themeId: (g['themeId'] as String?) ?? 'purple',
      );
      await HiveService.goalsBox.put(goal.id, goal);
    }

    final userName = data['userName'] as String?;
    if (userName != null && userName.trim().isNotEmpty) {
      await HiveService.settingsBox.put('user_name', userName.trim());
    }
  }
}
