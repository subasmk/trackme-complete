/// Small set of date helpers used throughout streak logic, the calendar
/// heatmap, and the week strip. All comparisons are done on the
/// year/month/day components only, so time-of-day never affects streaks.
class DateUtilsX {
  DateUtilsX._();

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime d) => isSameDay(d, DateTime.now());

  static bool isYesterday(DateTime d) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(d, yesterday);
  }

  /// Whole-day difference between two dates, ignoring time of day.
  static int daysBetween(DateTime a, DateTime b) {
    final aDate = dateOnly(a);
    final bDate = dateOnly(b);
    return bDate.difference(aDate).inDays;
  }

  /// Returns the 7 dates (Sunday -> Saturday) for the week containing [date].
  static List<DateTime> weekDates(DateTime date) {
    final d = dateOnly(date);
    // DateTime.weekday: Mon=1 ... Sun=7. We want Sunday-first like the
    // reference design's "S M T W T F S" strip.
    final sundayOffset = d.weekday % 7; // Sun -> 0, Mon -> 1, ... Sat -> 6
    final sunday = d.subtract(Duration(days: sundayOffset));
    return List.generate(7, (i) => sunday.add(Duration(days: i)));
  }

  static const List<String> weekdayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  static String monthShort(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[month - 1];
  }
}
