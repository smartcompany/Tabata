import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/engine/workout_timer_engine.dart';
import 'package:tabata_timer/services/workout_voice_planner.dart';

WorkoutTimerSnapshot _snap({
  WorkoutPhaseKind kind = WorkoutPhaseKind.work,
  String label = '팔 벌리기',
  int remainingSec = 8,
  int durationSec = 8,
  int countRepNumber = 0,
  int totalCountReps = 0,
  String phaseGroupKey = '',
  int exerciseIndex = 1,
  String exerciseName = '팽귄 운동',
  bool isPaused = false,
  bool isCompleted = false,
}) {
  return WorkoutTimerSnapshot(
    phase: WorkoutPhase(
      kind: kind,
      label: label,
      durationSec: durationSec,
      countRepNumber: countRepNumber,
      totalCountReps: totalCountReps,
      phaseGroupKey: phaseGroupKey,
    ),
    remainingSec: remainingSec,
    exerciseIndex: exerciseIndex,
    setIndex: 1,
    repIndex: 1,
    exerciseName: exerciseName,
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

  test('hasBlockingIntroCues is true for exercise name and phase start', () {
    final cues = planner.plan(
      previous: null,
      current: _snap(
        kind: WorkoutPhaseKind.prepare,
        label: '준비',
        exerciseName: '밴드 당기기',
      ),
    );
    expect(WorkoutVoicePlanner.hasBlockingIntroCues(cues), isTrue);
  });

  test('hasBlockingIntroCues is false for end countdown only', () {
    final cues = planner.plan(
      previous: _snap(remainingSec: 4, durationSec: 10),
      current: _snap(remainingSec: 3, durationSec: 10),
    );
    expect(WorkoutVoicePlanner.hasBlockingIntroCues(cues), isFalse);
  });

  test('shouldHoldTimerForAnnounce holds countdown when requested', () {
    final cues = planner.plan(
      previous: _snap(remainingSec: 4, durationSec: 10),
      current: _snap(remainingSec: 3, durationSec: 10),
    );
    expect(
      WorkoutVoicePlanner.shouldHoldTimerForAnnounce(cues),
      isFalse,
    );
    expect(
      WorkoutVoicePlanner.shouldHoldTimerForAnnounce(
        cues,
        holdCountdown: true,
      ),
      isTrue,
    );
  });

  test('first snapshot announces exercise name then phase start', () {
    final cues = planner.plan(
      previous: null,
      current: _snap(
        kind: WorkoutPhaseKind.prepare,
        label: '준비',
        exerciseName: '사이드 플랭크',
      ),
    );
    expect(cues.length, 2);
    expect(cues[0].kind, VoiceCueKind.exerciseName);
    expect(cues[0].exerciseName, '사이드 플랭크');
    expect(cues[1].kind, VoiceCueKind.phaseStart);
    expect(cues[1].phaseDurationSec, 8);
  });

  test('new exercise announces name before prepare', () {
    final previous = _snap(
      kind: WorkoutPhaseKind.relax,
      label: '휴식',
      exerciseIndex: 1,
      exerciseName: '플랭크',
    );
    final current = _snap(
      kind: WorkoutPhaseKind.prepare,
      label: '준비',
      exerciseIndex: 2,
      exerciseName: '사이드 플랭크',
    );
    final cues = planner.plan(previous: previous, current: current);
    expect(cues.length, 2);
    expect(cues[0].kind, VoiceCueKind.exerciseName);
    expect(cues[0].exerciseName, '사이드 플랭크');
    expect(cues[1].kind, VoiceCueKind.phaseStart);
  });

  test('same exercise phase change skips exercise name', () {
    final previous = _snap(kind: WorkoutPhaseKind.work, label: '유지');
    final current = _snap(kind: WorkoutPhaseKind.relax, label: '휴식');
    final cues = planner.plan(previous: previous, current: current);
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

  test('count mode announces rep number on each step', () {
    final first = _snap(
      remainingSec: 5,
      durationSec: 5,
      countRepNumber: 1,
      totalCountReps: 3,
      phaseGroupKey: 'g1',
    );
    final cues = planner.plan(previous: null, current: first);
    expect(cues.length, 4);
    expect(cues[0].kind, VoiceCueKind.exerciseName);
    expect(cues[1].kind, VoiceCueKind.phaseStart);
    expect(cues[2].kind, VoiceCueKind.repCount);
    expect(cues[2].repNumber, 1);
    expect(cues[3].kind, VoiceCueKind.countdown);
    expect(cues[3].seconds, 5);

    final second = _snap(
      remainingSec: 5,
      durationSec: 5,
      countRepNumber: 2,
      totalCountReps: 3,
      phaseGroupKey: 'g1',
    );
    final nextCues = planner.plan(previous: first, current: second);
    expect(nextCues.length, 2);
    expect(nextCues[0].kind, VoiceCueKind.repCount);
    expect(nextCues[0].repNumber, 2);
    expect(nextCues[1].kind, VoiceCueKind.countdown);
    expect(nextCues[1].seconds, 5);
  });

  test('count mode announces first second at rep start', () {
    final first = _snap(
      remainingSec: 10,
      durationSec: 10,
      countRepNumber: 1,
      totalCountReps: 3,
      phaseGroupKey: 'g1',
    );
    final cues = planner.plan(previous: null, current: first);
    expect(cues.length, 4);
    expect(cues[2].kind, VoiceCueKind.repCount);
    expect(cues[3].kind, VoiceCueKind.countdown);
    expect(cues[3].seconds, 10);
  });

  test('count mode announces remaining seconds when countSecondsWithTts is on', () {
    final previous = _snap(
      remainingSec: 4,
      durationSec: 5,
      countRepNumber: 2,
      totalCountReps: 3,
      phaseGroupKey: 'g1',
    );
    final current = _snap(
      remainingSec: 3,
      durationSec: 5,
      countRepNumber: 2,
      totalCountReps: 3,
      phaseGroupKey: 'g1',
    );
    final cues = planner.plan(previous: previous, current: current);
    expect(cues.length, 1);
    expect(cues.single.kind, VoiceCueKind.countdown);
    expect(cues.single.seconds, 3);
  });

  test('count mode skips second voice when countSecondsWithTts is off', () {
    final previous = _snap(
      remainingSec: 4,
      durationSec: 5,
      countRepNumber: 2,
      totalCountReps: 3,
      phaseGroupKey: 'g1',
    );
    final current = _snap(
      remainingSec: 3,
      durationSec: 5,
      countRepNumber: 2,
      totalCountReps: 3,
      phaseGroupKey: 'g1',
    );
    final cues = planner.plan(
      previous: previous,
      current: current,
      countSecondsWithTts: false,
    );
    expect(cues, isEmpty);
  });

  test('descending count announces high to low rep numbers', () {
    final third = _snap(
      remainingSec: 5,
      durationSec: 5,
      countRepNumber: 3,
      totalCountReps: 3,
      phaseGroupKey: 'g1',
    );
    final cues = planner.plan(previous: null, current: third);
    expect(cues.length, 4);
    expect(cues[0].kind, VoiceCueKind.exerciseName);
    expect(cues[1].kind, VoiceCueKind.phaseStart);
    expect(cues[2].kind, VoiceCueKind.repCount);
    expect(cues[2].repNumber, 3);
    expect(cues[3].kind, VoiceCueKind.countdown);
    expect(cues[3].seconds, 5);

    final second = _snap(
      remainingSec: 5,
      durationSec: 5,
      countRepNumber: 2,
      totalCountReps: 3,
      phaseGroupKey: 'g1',
    );
    final nextCues = planner.plan(previous: third, current: second);
    expect(nextCues.length, 2);
    expect(nextCues[0].repNumber, 2);
    expect(nextCues[1].kind, VoiceCueKind.countdown);
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
