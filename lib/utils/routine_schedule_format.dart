import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/routine_schedule.dart';
import '../models/schedule_recurrence.dart';

DateTimeComponents? matchComponentsFor(ScheduleRecurrence recurrence) {
  return switch (recurrence) {
    ScheduleRecurrence.none => null,
    ScheduleRecurrence.daily => DateTimeComponents.time,
    ScheduleRecurrence.weekly => DateTimeComponents.dayOfWeekAndTime,
    ScheduleRecurrence.monthly => DateTimeComponents.dayOfMonthAndTime,
  };
}

tz.TZDateTime notificationScheduledDate(RoutineSchedule schedule) {
  final anchor = schedule.scheduledAt.toLocal();
  if (schedule.recurrence == ScheduleRecurrence.none) {
    return tz.TZDateTime.from(anchor, tz.local);
  }
  final next = schedule.nextOccurrence(DateTime.now());
  return tz.TZDateTime.from(next, tz.local);
}

String scheduleSuccessMessage(
  RoutineSchedule schedule,
  AppLocalizations l10n,
  MaterialLocalizations material,
) {
  return l10n.scheduleWorkoutSuccess(schedule.summary(l10n, material));
}
