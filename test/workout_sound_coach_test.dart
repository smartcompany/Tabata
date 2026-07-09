import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/engine/workout_timer_engine.dart';
import 'package:tabata_timer/services/workout_sound_coach.dart';

WorkoutTimerSnapshot _snap({
  WorkoutPhaseKind kind = WorkoutPhaseKind.work,
  String label = '운동',
  int remainingSec = 10,
  int durationSec = 10,
  int countRepNumber = 0,
  int totalCountReps = 0,
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
    ),
    remainingSec: remainingSec,
    exerciseIndex: 1,
    setIndex: 1,
    repIndex: 1,
    exerciseName: '테스트',
    routineTitle: '테스트',
    totalExercises: 1,
    totalSets: 1,
    totalReps: 1,
    isPaused: isPaused,
    isCompleted: isCompleted,
  );
}

void main() {
  test('clock loop plays during duration mode above last three seconds', () {
    expect(
      WorkoutSoundCoach.shouldPlayClockLoop(_snap(remainingSec: 10)),
      isTrue,
    );
    expect(
      WorkoutSoundCoach.shouldPlayClockLoop(_snap(remainingSec: 4)),
      isTrue,
    );
  });

  test('clock loop stops for last three seconds and short phases', () {
    expect(
      WorkoutSoundCoach.shouldPlayClockLoop(_snap(remainingSec: 3)),
      isFalse,
    );
    expect(
      WorkoutSoundCoach.shouldPlayClockLoop(_snap(remainingSec: 2)),
      isFalse,
    );
    expect(
      WorkoutSoundCoach.shouldPlayClockLoop(
        _snap(remainingSec: 2, durationSec: 3),
      ),
      isFalse,
    );
  });

  test('clock loop does not play in count mode', () {
    expect(
      WorkoutSoundCoach.shouldPlayClockLoop(
        _snap(
          remainingSec: 8,
          durationSec: 5,
          countRepNumber: 2,
          totalCountReps: 5,
        ),
      ),
      isFalse,
    );
  });

  test('clock loop does not play during intro announce', () {
    expect(
      WorkoutSoundCoach.shouldPlayClockLoop(
        _snap(remainingSec: 10),
        blockForIntro: true,
      ),
      isFalse,
    );
  });

  test('clock loop stops when paused or completed', () {
    expect(
      WorkoutSoundCoach.shouldPlayClockLoop(_snap(isPaused: true)),
      isFalse,
    );
    expect(
      WorkoutSoundCoach.shouldPlayClockLoop(_snap(isCompleted: true)),
      isFalse,
    );
  });
}
