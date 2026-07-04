import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import 'schedule_recurrence.dart';

class RoutineSchedule {
  const RoutineSchedule({
    required this.routineId,
    required this.routineTitle,
    required this.scheduledAt,
    this.recurrence = ScheduleRecurrence.none,
    this.endDate,
  });

  final String routineId;
  final String routineTitle;

  /// Anchor date/time: first fire time, or day-of-week / day-of-month for repeats.
  final DateTime scheduledAt;
  final ScheduleRecurrence recurrence;
  final DateTime? endDate;

  bool isExpired(DateTime now) {
    if (recurrence == ScheduleRecurrence.none) {
      return !scheduledAt.isAfter(now);
    }
    final end = endDate;
    if (end == null) return false;
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return now.isAfter(endOfDay);
  }

  bool isActiveAt(DateTime now) => !isExpired(now);

  DateTime nextOccurrence(DateTime after) {
    final anchor = scheduledAt.toLocal();
    if (recurrence == ScheduleRecurrence.none) {
      return anchor;
    }

    if (recurrence == ScheduleRecurrence.daily) {
      var next = DateTime(
        after.year,
        after.month,
        after.day,
        anchor.hour,
        anchor.minute,
      );
      if (!next.isAfter(after)) {
        next = next.add(const Duration(days: 1));
      }
      return next;
    }

    if (recurrence == ScheduleRecurrence.weekly) {
      final targetWeekday = anchor.weekday;
      var daysUntil = (targetWeekday - after.weekday + 7) % 7;
      var next = DateTime(
        after.year,
        after.month,
        after.day,
        anchor.hour,
        anchor.minute,
      ).add(Duration(days: daysUntil));
      if (!next.isAfter(after)) {
        next = next.add(const Duration(days: 7));
      }
      return next;
    }

    final targetDay = anchor.day;
    var year = after.year;
    var month = after.month;
    for (var i = 0; i < 24; i++) {
      final day = _clampDayOfMonth(year, month, targetDay);
      final candidate = DateTime(
        year,
        month,
        day,
        anchor.hour,
        anchor.minute,
      );
      if (candidate.isAfter(after)) return candidate;
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }
    return anchor;
  }

  int _clampDayOfMonth(int year, int month, int day) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return day > lastDay ? lastDay : day;
  }

  String summary(AppLocalizations l10n, MaterialLocalizations material) {
    final time =
        material.formatTimeOfDay(TimeOfDay.fromDateTime(scheduledAt));
    switch (recurrence) {
      case ScheduleRecurrence.none:
        final date = material.formatFullDate(scheduledAt);
        return l10n.scheduleWorkoutActive('$date $time');
      case ScheduleRecurrence.daily:
        return l10n.scheduleRecurrenceDailySummary(time);
      case ScheduleRecurrence.weekly:
        final weekday = _weekdayLabel(material, scheduledAt.weekday);
        return l10n.scheduleRecurrenceWeeklySummary(weekday, time);
      case ScheduleRecurrence.monthly:
        return l10n.scheduleRecurrenceMonthlySummary(scheduledAt.day, time);
    }
  }

  String _weekdayLabel(MaterialLocalizations material, int weekday) {
    final labels = material.narrowWeekdays;
    return labels[weekday % 7];
  }

  Map<String, dynamic> toJson() => {
        'routineId': routineId,
        'routineTitle': routineTitle,
        'scheduledAt': scheduledAt.toIso8601String(),
        'recurrence': recurrence.storageId,
        if (endDate != null) 'endDate': endDate!.toIso8601String(),
      };

  factory RoutineSchedule.fromJson(Map<String, dynamic> json) {
    return RoutineSchedule(
      routineId: json['routineId'] as String,
      routineTitle: json['routineTitle'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String).toLocal(),
      recurrence: ScheduleRecurrence.fromId(json['recurrence'] as String?),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String).toLocal()
          : null,
    );
  }
}
