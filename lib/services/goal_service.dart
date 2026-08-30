import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/learning_note.dart';
import '../models/achievement.dart';
import '../utils/streak_logic.dart';
import 'hive_service.dart';
import 'home_widget_service.dart';

/// The single source of truth for goal data. Wraps the Hive `Goal` box in a
/// [ChangeNotifier] so every screen rebuilds reactively, and is the only
/// place that mutates goals — this keeps streak/XP/badge rules consistent
/// no matter which screen triggers a change.
class GoalService extends ChangeNotifier {
  static const _uuid = Uuid();
  String _currentUserName = 'Learner';

  GoalService() {
    _reconcileAllOnLoad();
    unawaited(_syncWidget());
  }

  /// Called once at startup: if the user missed a day while the app was
  /// closed, the streak needs to reflect that immediately rather than only
  /// updating the next time they try to complete something.
  void _reconcileAllOnLoad() {
    for (final goal in HiveService.goalsBox.values) {
      StreakLogic.reconcileMissedDay(goal);
      goal.save();
    }
  }

  List<Goal> get goals => HiveService.goalsBox.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  Goal? goalById(String id) {
    try {
      return HiveService.goalsBox.values.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  int get totalGoalsCount => HiveService.goalsBox.length;

  int get completedTodayCount => goals.where((g) => g.isCompletedToday).length;

  /// True only once every goal that exists has been completed today (and
  /// there is at least one goal) — drives the "all done" celebratory state.
  bool get allCompletedToday =>
      totalGoalsCount > 0 && completedTodayCount == totalGoalsCount;

  List<Achievement> get allUnlockedAchievements {
    final ids = <String>{};
    for (final g in goals) {
      ids.addAll(g.unlockedBadgeIds);
    }
    return AchievementCatalog.all.where((a) => ids.contains(a.id)).toList();
  }

  Future<void> addGoal({
    required String title,
    required String emoji,
    required int dailyMinutes,
    String themeId = 'purple',
  }) async {
    final goal = Goal(
      id: _uuid.v4(),
      title: title.trim(),
      emoji: emoji,
      dailyMinutes: dailyMinutes,
      themeId: themeId,
    );
    await HiveService.goalsBox.put(goal.id, goal);
    notifyListeners();
    unawaited(_syncWidget());
  }

  Future<void> updateGoal(
    Goal goal, {
    String? title,
    String? emoji,
    int? dailyMinutes,
    String? themeId,
  }) async {
    if (title != null) goal.title = title.trim();
    if (emoji != null) goal.emoji = emoji;
    if (dailyMinutes != null) goal.dailyMinutes = dailyMinutes;
    if (themeId != null) goal.themeId = themeId;
    await goal.save();
    notifyListeners();
    unawaited(_syncWidget());
  }

  Future<void> deleteGoal(Goal goal) async {
    await goal.delete();
    notifyListeners();
    unawaited(_syncWidget());
  }

  /// The core gamification loop: mark a goal done for today, save the note,
  /// bump streak/XP/level, unlock any newly-earned badges, persist, and
  /// push the update out to the home screen widgets.
  ///
  /// Returns a [CompletionResult] the UI uses to decide whether to show the
  /// celebration screen, and which new badges (if any) were unlocked.
  Future<({CompletionResult result, List<Achievement> newBadges})> completeToday(
    Goal goal,
    String noteText, {
    String? pickedImagePath,
    String? linkUrl,
  }) async {
    final previouslyUnlocked = Set<String>.from(goal.unlockedBadgeIds);

    final result = StreakLogic.completeToday(goal);
    if (!result.success) {
      return (result: result, newBadges: <Achievement>[]);
    }

    final permanentImagePath = pickedImagePath != null
        ? await _copyImageToPermanentStorage(pickedImagePath)
        : null;

    final note = LearningNote(
      id: _uuid.v4(),
      text: noteText.trim(),
      date: DateTime.now(),
      imagePath: permanentImagePath,
      linkUrl: _normalizeLink(linkUrl),
    );
    goal.notes = [...goal.notes, note];

    final unlockedNow = AchievementCatalog.unlockedFor(
      goal.streak,
      goal.longestStreak,
      goal.xp,
      goal.level,
    );
    final newlyUnlockedIds = unlockedNow
        .map((a) => a.id)
        .where((id) => !previouslyUnlocked.contains(id))
        .toSet();
    goal.unlockedBadgeIds = {...goal.unlockedBadgeIds, ...newlyUnlockedIds}.toList();

    await goal.save();
    notifyListeners();
    unawaited(_syncWidget());

    final newBadges =
        AchievementCatalog.all.where((a) => newlyUnlockedIds.contains(a.id)).toList();

    return (result: result, newBadges: newBadges);
  }

  /// All learning notes across every goal, newest first, optionally
  /// filtered by a case-insensitive search on the note text or goal title.
  List<({Goal goal, LearningNote note})> allNotes({String query = ''}) {
    final entries = <({Goal goal, LearningNote note})>[];
    for (final g in goals) {
      for (final n in g.notes) {
        entries.add((goal: g, note: n));
      }
    }
    entries.sort((a, b) => b.note.date.compareTo(a.note.date));

    if (query.trim().isEmpty) return entries;
    final q = query.trim().toLowerCase();
    return entries
        .where((e) =>
            e.note.text.toLowerCase().contains(q) ||
            e.goal.title.toLowerCase().contains(q))
        .toList();
  }

  /// Edits an existing note's text and/or attachments in place.
  ///
  /// Deliberately never touches streak/XP/badges: those were already
  /// earned the moment the note was first created, so fixing a typo or
  /// swapping a photo afterward can't retroactively change them — notes
  /// are a journal of that day, not an undo button for progress.
  ///
  /// [removeImage]/[removeLink] explicitly clear that attachment; leaving
  /// them false and [newPickedImagePath]/[linkUrl] null keeps whatever was
  /// already on the note.
  Future<void> editNote(
    Goal goal,
    String noteId, {
    String? text,
    String? newPickedImagePath,
    bool removeImage = false,
    String? linkUrl,
    bool removeLink = false,
  }) async {
    final index = goal.notes.indexWhere((n) => n.id == noteId);
    if (index == -1) return;
    final note = goal.notes[index];

    if (text != null && text.trim().isNotEmpty) {
      note.text = text.trim();
    }

    if (removeImage) {
      note.imagePath = null;
    } else if (newPickedImagePath != null) {
      final permanentPath = await _copyImageToPermanentStorage(newPickedImagePath);
      if (permanentPath != null) note.imagePath = permanentPath;
    }

    if (removeLink) {
      note.linkUrl = null;
    } else if (linkUrl != null) {
      note.linkUrl = _normalizeLink(linkUrl);
    }

    await goal.save();
    notifyListeners();
    unawaited(_syncWidget());
  }

  /// Removes a note entirely. Like [editNote], this is purely a journal
  /// edit — it never touches streak/XP, even if the deleted note was
  /// today's.
  Future<void> deleteNote(Goal goal, String noteId) async {
    goal.notes = goal.notes.where((n) => n.id != noteId).toList();
    await goal.save();
    notifyListeners();
    unawaited(_syncWidget());
  }

  void setUserName(String name) {
    _currentUserName = name;
    unawaited(_syncWidget());
  }

  /// Called by BackupService after an import replaces the Hive box's
  /// contents directly (bypassing every method above, since a restore
  /// isn't "add one goal" or "edit one note" — it's wholesale replacement).
  /// Refreshes the UI and pushes the new data out to the widgets.
  void notifyExternalChange() {
    notifyListeners();
    unawaited(_syncWidget());
  }

  /// Copies a picked image (which may live in a temp/cache location the OS
  /// can clear at any time) into this app's own documents directory, so it
  /// stays available for as long as the note exists. Best-effort: if
  /// anything goes wrong, the note is still saved without its photo rather
  /// than failing the whole completion.
  Future<String?> _copyImageToPermanentStorage(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;
      final docsDir = await getApplicationDocumentsDirectory();
      final notesDir = Directory('${docsDir.path}/note_images');
      if (!await notesDir.exists()) {
        await notesDir.create(recursive: true);
      }
      final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'jpg';
      final destPath = '${notesDir.path}/${_uuid.v4()}.$ext';
      await sourceFile.copy(destPath);
      return destPath;
    } catch (_) {
      return null;
    }
  }

  /// Ensures a user-entered link always has a scheme, so `Uri.parse` and
  /// `launchUrl` behave correctly even if they typed "example.com" without
  /// "https://" in front of it.
  String? _normalizeLink(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  Future<void> _syncWidget() async {
    await HomeWidgetService.syncGoals(goals, userName: _currentUserName);
  }
}
