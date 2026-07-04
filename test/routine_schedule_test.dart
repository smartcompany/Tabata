import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/models/routine_schedule.dart';
import 'package:tabata_timer/models/schedule_recurrence.dart';

void main() {
  test('RoutineSchedule roundtrips in json', () {
    final schedule = RoutineSchedule(
      routineId: 'routine-1',
      routineTitle: 'Morning HIIT',
      scheduledAt: DateTime(2026, 7, 5, 8, 30),
      recurrence: ScheduleRecurrence.weekly,
      endDate: DateTime(2026, 12, 31),
    );

    final decoded = RoutineSchedule.fromJson(schedule.toJson());

    expect(decoded.routineId, schedule.routineId);
    expect(decoded.routineTitle, schedule.routineTitle);
    expect(decoded.scheduledAt, schedule.scheduledAt);
    expect(decoded.recurrence, schedule.recurrence);
    expect(decoded.endDate, schedule.endDate);
  });

  test('missing recurrence deserializes as once', () {
    final decoded = RoutineSchedule.fromJson({
      'routineId': 'routine-1',
      'routineTitle': 'Morning HIIT',
      'scheduledAt': DateTime(2026, 7, 5, 8, 30).toIso8601String(),
    });

    expect(decoded.recurrence, ScheduleRecurrence.none);
  });

  test('nextOccurrence finds future weekly slot', () {
    final schedule = RoutineSchedule(
      routineId: 'routine-1',
      routineTitle: 'Morning HIIT',
      scheduledAt: DateTime(2026, 7, 6, 8, 0),
      recurrence: ScheduleRecurrence.weekly,
    );

    final next = schedule.nextOccurrence(DateTime(2026, 7, 6, 9, 0));

    expect(next.weekday, DateTime.monday);
    expect(next.hour, 8);
    expect(next.isAfter(DateTime(2026, 7, 6, 9, 0)), isTrue);
  });

  test('recurring schedule stays active after anchor passes', () {
    final schedule = RoutineSchedule(
      routineId: 'routine-1',
      routineTitle: 'Morning HIIT',
      scheduledAt: DateTime(2026, 1, 1, 8, 0),
      recurrence: ScheduleRecurrence.daily,
    );

    expect(schedule.isActiveAt(DateTime(2026, 7, 5, 12)), isTrue);
  });
}
