import '../models/goal.dart';
import 'date_utils_x.dart';

/// Result of attempting to mark a goal complete for today.
class CompletionResult {
  final bool success;
  final String? errorMessage;
  final int newStreak;
  final bool isNewLongest;
  final bool leveledUp;
  final int newLevel;

  const CompletionResult({
    required this.success,
    this.errorMessage,
    this.newStreak = 0,
    this.isNewLongest = false,
    this.leveledUp = false,
    this.newLevel = 1,
  });
}

/// All streak/XP/level math lives here so the rules are defined in exactly
/// one place and both the UI and the widget-sync service agree on them.
class StreakLogic {
  StreakLogic._();

  /// Base XP awarded per completion, plus a small bonus that scales with
  /// the goal's daily target so longer sessions feel more rewarding.
  static int xpForCompletion(int dailyMinutes) {
    final bonus = (dailyMinutes / 10).floor() * 2;
    return 10 + bonus;
  }

  /// Level from total XP using a simple, readable curve: level N requires
  /// N*100 cumulative XP (i.e. level thresholds are 100, 300, 600, 1000...).
  static int levelForXp(int totalXp) {
    int level = 1;
    int remaining = totalXp;
    while (remaining >= level * 100) {
      remaining -= level * 100;
      level++;
    }
    return level;
  }

  /// Applies "complete today" to [goal] in place and returns the outcome.
  /// Rules:
  /// - Cannot complete twice in the same day.
  /// - If the last completion was yesterday, streak increments by 1.
  /// - If the last completion was today already -> blocked (handled above).
  /// - Otherwise (2+ days ago, or never completed) streak resets to 1.
  static CompletionResult completeToday(Goal goal) {
    final now = DateTime.now();

    if (goal.isCompletedToday) {
      return const CompletionResult(
        success: false,
        errorMessage: "You've already completed this goal today. Come back tomorrow!",
      );
    }

    final last = goal.lastCompleted;
    int newStreak;
    if (last != null && DateUtilsX.isYesterday(last)) {
      newStreak = goal.streak + 1;
    } else {
      // First completion ever, or the streak was broken by a missed day.
      newStreak = 1;
    }

    final isNewLongest = newStreak > goal.longestStreak;
    final oldLevel = goal.level;

    goal.streak = newStreak;
    if (isNewLongest) goal.longestStreak = newStreak;
    goal.lastCompleted = now;
    goal.xp += xpForCompletion(goal.dailyMinutes);
    goal.level = levelForXp(goal.xp);

    return CompletionResult(
      success: true,
      newStreak: newStreak,
      isNewLongest: isNewLongest,
      leveledUp: goal.level > oldLevel,
      newLevel: goal.level,
    );
  }

  /// Whether a streak has silently been broken by the calendar moving on
  /// (i.e. the user hasn't opened the app since missing a day). Call this
  /// when loading goals so the displayed streak is always accurate, even
  /// before the next "Complete Today" tap.
  static void reconcileMissedDay(Goal goal) {
    if (goal.streak == 0) return;
    final last = goal.lastCompleted;
    if (last == null) return;
    if (DateUtilsX.isToday(last) || DateUtilsX.isYesterday(last)) return;
    // More than one full day has passed since the last completion -> reset.
    goal.streak = 0;
  }
}
