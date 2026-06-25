import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/engine/workout_timer_engine.dart';
import 'package:tabata_timer/services/workout_announce_gap.dart';

WorkoutTimerSnapshot _snap({
  WorkoutPhaseKind kind = WorkoutPhaseKind.work,
  bool isCompleted = false,
}) {
  return WorkoutTimerSnapshot(
    phase: WorkoutPhase(kind: kind, label: '', durationSec: 8),
    remainingSec: 8,
    exerciseIndex: 1,
    setIndex: 1,
    repIndex: 1,
    exerciseName: '팽귄 운동',
    routineTitle: '테스트',
    totalExercises: 1,
    totalSets: 1,
    totalReps: 1,
    isPaused: false,
    isCompleted: isCompleted,
  );
}

void main() {
  test('gap after relax before next work', () {
    final previous = _snap(kind: WorkoutPhaseKind.relax);
    final current = _snap(kind: WorkoutPhaseKind.work);
    expect(needsWorkRelaxSessionGap(previous, current), isTrue);
  });

  test('no gap from work to relax', () {
    final previous = _snap(kind: WorkoutPhaseKind.work);
    final current = _snap(kind: WorkoutPhaseKind.relax);
    expect(needsWorkRelaxSessionGap(previous, current), isFalse);
  });

  test('no gap on first snapshot', () {
    final current = _snap(kind: WorkoutPhaseKind.prepare);
    expect(needsWorkRelaxSessionGap(null, current), isFalse);
  });
}
