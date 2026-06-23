import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/engine/workout_timer_engine.dart';
import 'package:tabata_timer/services/workout_voice_planner.dart';

WorkoutTimerSnapshot _snap({
  WorkoutPhaseKind kind = WorkoutPhaseKind.work,
  String label = '팔 벌리기',
  int remainingSec = 8,
  int durationSec = 8,
  bool isPaused = false,
  bool isCompleted = false,
}) {
  return WorkoutTimerSnapshot(
    phase: WorkoutPhase(
      kind: kind,
      label: label,
      durationSec: durationSec,
    ),
    remainingSec: remainingSec,
    exerciseIndex: 1,
    setIndex: 1,
    repIndex: 1,
    exerciseName: '팽귄 운동',
    routineTitle: '테스트',
    totalExercises: 1,
    totalSets: 1,
    totalReps: 1,
    isPaused: isPaused,
    isCompleted: isCompleted,
  );
}

void main() {
  const planner = WorkoutVoicePlanner();

  test('first snapshot announces phase start', () {
    final cues = planner.plan(
      previous: null,
      current: _snap(kind: WorkoutPhaseKind.prepare, label: '준비'),
    );
    expect(cues.length, 1);
    expect(cues.single.kind, VoiceCueKind.phaseStart);
  });

  test('countdown fires on last three seconds for long phases', () {
    final previous = _snap(remainingSec: 4, durationSec: 8);
    final current = _snap(remainingSec: 3, durationSec: 8);
    final cues = planner.plan(previous: previous, current: current);
    expect(cues.length, 1);
    expect(cues.single.kind, VoiceCueKind.countdown);
    expect(cues.single.seconds, 3);
  });

  test('short phases skip countdown', () {
    final previous = _snap(remainingSec: 3, durationSec: 3);
    final current = _snap(remainingSec: 2, durationSec: 3);
    final cues = planner.plan(previous: previous, current: current);
    expect(cues, isEmpty);
  });

  test('completion announces once', () {
    final previous = _snap(remainingSec: 1);
    final completed = _snap(isCompleted: true, remainingSec: 0);
    final cues = planner.plan(previous: previous, current: completed);
    expect(cues.single.kind, VoiceCueKind.completed);

    final again = planner.plan(previous: completed, current: completed);
    expect(again, isEmpty);
  });

  test('pause suppresses cues', () {
    final cues = planner.plan(
      previous: _snap(remainingSec: 4),
      current: _snap(remainingSec: 3, isPaused: true),
    );
    expect(cues, isEmpty);
  });

  test('phase start speech skips duplicate label', () {
    expect(
      phaseStartSpeech(
        phaseKind: WorkoutPhaseKind.prepare,
        label: '준비',
        prepareTitle: '준비',
        workTitle: '운동',
        relaxTitle: '이완',
      ),
      '준비',
    );
    expect(
      phaseStartSpeech(
        phaseKind: WorkoutPhaseKind.work,
        label: '팔 벌리기',
        prepareTitle: '준비',
        workTitle: '운동',
        relaxTitle: '이완',
      ),
      '운동, 팔 벌리기',
    );
  });
}
