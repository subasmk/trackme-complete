import 'package:hive/hive.dart';
import 'quest_item.dart';

part 'quest.g.dart';

/// A Quest is a structured daily challenge with multiple goal items,
/// a time window, difficulty, type, XP/gold rewards, and a streak tracker.
/// Unlike Goals (which track a single habit), a Quest bundles several
/// sub-goals into one completable session (e.g., a Fitness workout).
@HiveType(typeId: 2)
class Quest extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String emoji;

  /// Category type: 'Fitness', 'Study', 'Mindfulness', 'Skill', 'Custom'
  @HiveField(3)
  String type;

  /// Difficulty: 'Easy', 'Medium', 'Hard'
  @HiveField(4)
  String difficulty;

  /// Optional start time in "HH:mm" format (e.g., "07:30")
  @HiveField(5)
  String? startTime;

  /// Optional end time in "HH:mm" format (e.g., "08:10")
  @HiveField(6)
  String? endTime;

  @HiveField(7)
  int streak;

  @HiveField(8)
  int longestStreak;

  /// Sub-goals that make up this quest (e.g., pushups, pull-ups, etc.)
  @HiveField(9)
  List<QuestItem> items;

  /// XP awarded on completion
  @HiveField(10)
  int xp;

  /// Gold awarded on completion
  @HiveField(11)
  int gold;

  /// Focus stat labels (e.g., "STR/AGI", "INT", "END")
  @HiveField(12)
  String focusStats;

  /// Last time this quest was completed (date only, time ignored)
  @HiveField(13)
  DateTime? lastCompleted;

  @HiveField(14)
  DateTime createdAt;

  Quest({
    required this.id,
    required this.title,
    required this.emoji,
    this.type = 'Fitness',
    this.difficulty = 'Medium',
    this.startTime,
    this.endTime,
    this.streak = 0,
    this.longestStreak = 0,
    List<QuestItem>? items,
    this.xp = 100,
    this.gold = 50,
    this.focusStats = 'STR',
    this.lastCompleted,
    DateTime? createdAt,
  })  : items = items ?? <QuestItem>[],
        createdAt = createdAt ?? DateTime.now();

  /// True if the quest was completed today.
  bool get isCompletedToday {
    if (lastCompleted == null) return false;
    final now = DateTime.now();
    return lastCompleted!.year == now.year &&
        lastCompleted!.month == now.month &&
        lastCompleted!.day == now.day;
  }

  /// Returns a human-readable time range string, e.g., "07:30 - 08:10".
  String? get timeRange {
    if (startTime == null && endTime == null) return null;
    final s = startTime ?? '';
    final e = endTime ?? '';
    if (s.isEmpty && e.isEmpty) return null;
    if (e.isEmpty) return s;
    if (s.isEmpty) return e;
    return '$s - $e';
  }

  /// XP computed from difficulty for display purposes.
  static int xpForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 75;
      case 'Hard':
        return 187;
      default:
        return 120;
    }
  }

  /// Gold computed from difficulty for display purposes.
  static int goldForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 30;
      case 'Hard':
        return 75;
      default:
        return 50;
    }
  }
}
