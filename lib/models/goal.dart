import 'package:hive/hive.dart';
import 'learning_note.dart';

part 'goal.g.dart';

@HiveType(typeId: 0)
class Goal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String emoji;

  @HiveField(3)
  int streak;

  @HiveField(4)
  int longestStreak;

  @HiveField(5)
  int dailyMinutes;

  @HiveField(6)
  DateTime? lastCompleted;

  @HiveField(7)
  List<LearningNote> notes;

  @HiveField(8)
  int xp;

  @HiveField(9)
  int level;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  List<String> unlockedBadgeIds;

  @HiveField(12)
  String themeId;

  Goal({
    required this.id,
    required this.title,
    required this.emoji,
    this.streak = 0,
    this.longestStreak = 0,
    required this.dailyMinutes,
    this.lastCompleted,
    List<LearningNote>? notes,
    this.xp = 0,
    this.level = 1,
    DateTime? createdAt,
    List<String>? unlockedBadgeIds,
    String? themeId,
  })  : notes = notes ?? <LearningNote>[],
        createdAt = createdAt ?? DateTime.now(),
        unlockedBadgeIds = unlockedBadgeIds ?? <String>[],
        themeId = themeId ?? 'purple';

  /// True if the goal's daily task has already been completed today.
  bool get isCompletedToday {
    if (lastCompleted == null) return false;
    final now = DateTime.now();
    return lastCompleted!.year == now.year &&
        lastCompleted!.month == now.month &&
        lastCompleted!.day == now.day;
  }

  /// XP required to reach the next level. Simple curve: level * 100.
  int get xpForNextLevel => level * 100;

  /// Progress (0.0 - 1.0) toward the next level.
  double get levelProgress {
    final needed = xpForNextLevel;
    if (needed == 0) return 0;
    return (xp % needed) / needed;
  }
}
