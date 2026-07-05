import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabata_timer/data/workout_history_repository.dart';
import 'package:tabata_timer/models/workout_session_record.dart';

void main() {
  test('workout history persists and groups by day', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = await WorkoutHistoryRepository.create();

    await repository.add(
      WorkoutSessionRecord(
        id: 'session-1',
        routineId: 'routine-1',
        routineTitle: 'Morning Tabata',
        startedAt: DateTime(2026, 7, 4, 8, 0),
        endedAt: DateTime(2026, 7, 4, 8, 12),
        durationSec: 720,
        exerciseCount: 3,
      ),
    );

    expect(repository.sessionCountForMonth(2026, 7), 1);
    expect(repository.totalDurationSecForMonth(2026, 7), 720);
    expect(repository.recordsForDay(DateTime(2026, 7, 4)), hasLength(1));
    expect(repository.daysWithWorkoutsInMonth(2026, 7), {4});

    final reloaded = await WorkoutHistoryRepository.create();
    expect(reloaded.allRecords, hasLength(1));
    expect(reloaded.allRecords.first.routineTitle, 'Morning Tabata');
  });

  test('health synced flag can be updated', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = await WorkoutHistoryRepository.create();

    await repository.add(
      WorkoutSessionRecord(
        id: 'session-2',
        routineId: 'routine-2',
        routineTitle: 'HIIT',
        startedAt: DateTime(2026, 7, 3, 18, 0),
        endedAt: DateTime(2026, 7, 3, 18, 20),
        durationSec: 1200,
        exerciseCount: 5,
        healthActivityType: 'high_intensity_interval_training',
      ),
    );

    await repository.updateHealthSynced('session-2', true);

    final record = repository.allRecords.first;
    expect(record.healthSynced, isTrue);
  });
}
