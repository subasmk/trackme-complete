import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/learning_note.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils_x.dart';

/// A month-view calendar where any day with a learning note is highlighted
/// in the purple brand color, giving an at-a-glance "heatmap" of
/// consistency for this specific goal.
class GoalHeatmapCalendar extends StatefulWidget {
  final List<LearningNote> notes;

  const GoalHeatmapCalendar({super.key, required this.notes});

  @override
  State<GoalHeatmapCalendar> createState() => _GoalHeatmapCalendarState();
}

class _GoalHeatmapCalendarState extends State<GoalHeatmapCalendar> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  bool _hasNoteOn(DateTime day) {
    return widget.notes.any((n) => DateUtilsX.isSameDay(n.date, day));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: TableCalendar(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2100, 12, 31),
        focusedDay: _focusedMonth,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.title.copyWith(fontSize: 15),
          leftChevronIcon:
              const Icon(Icons.chevron_left, color: AppColors.textSecondary),
          rightChevronIcon:
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: AppTextStyles.caption,
          weekendStyle:
              AppTextStyles.caption.copyWith(color: AppColors.textMuted),
        ),
        calendarStyle: const CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: TextStyle(color: AppColors.textSecondary),
          weekendTextStyle: TextStyle(color: AppColors.textSecondary),
          todayDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        onPageChanged: (day) => setState(() => _focusedMonth = day),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focused) => _buildCell(day, false),
          todayBuilder: (context, day, focused) => _buildCell(day, true),
        ),
      ),
    );
  }

  Widget _buildCell(DateTime day, bool isToday) {
    final done = _hasNoteOn(day);
    return Container(
      margin: const EdgeInsets.all(3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: done ? AppColors.primaryGradient : null,
        color: done ? null : Colors.transparent,
        border: isToday && !done
            ? Border.all(color: AppColors.purpleLight, width: 1.4)
            : null,
      ),
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: done ? Colors.white : AppColors.textSecondary,
          fontWeight: done || isToday ? FontWeight.w800 : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }
}
