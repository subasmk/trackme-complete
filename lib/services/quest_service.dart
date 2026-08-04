import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/quest.dart';
import '../models/quest_item.dart';
import '../services/hive_service.dart';
import '../services/home_widget_service.dart';

class QuestService extends ChangeNotifier {
  final Box<Quest> _box = HiveService.questsBox;
  static const _uuid = Uuid();

  List<Quest> get quests => _box.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  int get completedTodayCount =>
      quests.where((q) => q.isCompletedToday).length;

  int get totalQuestsCount => quests.length;

  Quest? questById(String id) {
    try {
      return _box.values.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // CRUD
  // ---------------------------------------------------------------------------

  Future<Quest> addQuest({
    required String title,
    required String emoji,
    required String type,
    required String difficulty,
    String? startTime,
    String? endTime,
    List<QuestItem>? items,
    String? focusStats,
  }) async {
    final quest = Quest(
      id: _uuid.v4(),
      title: title,
      emoji: emoji,
      type: type,
      difficulty: difficulty,
      startTime: startTime,
      endTime: endTime,
      items: items ?? [],
      xp: Quest.xpForDifficulty(difficulty),
      gold: Quest.goldForDifficulty(difficulty),
      focusStats: focusStats ?? _defaultFocusStats(type),
    );
    await _box.put(quest.id, quest);
    await _sync();
    notifyListeners();
    return quest;
  }

  Future<void> updateQuest(Quest quest) async {
    await quest.save();
    await _sync();
    notifyListeners();
  }

  Future<void> deleteQuest(String id) async {
    await _box.delete(id);
    await _sync();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Completion
  // ---------------------------------------------------------------------------

  Future<void> completeToday(String questId) async {
    final quest = questById(questId);
    if (quest == null || quest.isCompletedToday) return;

    final now = DateTime.now();

    // Streak logic: if last completed was yesterday, continue streak
    final isConsecutive = quest.lastCompleted != null &&
        _isYesterday(quest.lastCompleted!, now);

    quest.streak = isConsecutive ? quest.streak + 1 : 1;
    if (quest.streak > quest.longestStreak) {
      quest.longestStreak = quest.streak;
    }
    quest.lastCompleted = now;

    await quest.save();
    await _sync();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  bool _isYesterday(DateTime date, DateTime reference) {
    final yesterday = DateTime(reference.year, reference.month, reference.day)
        .subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  String _defaultFocusStats(String type) {
    switch (type) {
      case 'Fitness':
        return 'STR/AGI';
      case 'Study':
        return 'INT';
      case 'Mindfulness':
        return 'WIS';
      case 'Skill':
        return 'DEX';
      default:
        return 'ALL';
    }
  }

  Future<void> _sync() async {
    await HomeWidgetService.syncQuests(quests);
  }
}
