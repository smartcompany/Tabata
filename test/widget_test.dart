import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/data/seed_routines.dart';
import 'package:tabata_timer/engine/workout_timer_engine.dart';
import 'package:tabata_timer/engine/workout_timer_labels.dart';
import 'package:tabata_timer/services/routine_json_codec.dart';
import 'package:tabata_timer/utils/duration_calculator.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('ko'));
  });

  test('rotator cuff routine has three exercises', () {
    final routine = createRotatorCuffRoutine();
    expect(routine.orderedExercises.length, 3);
  });

  test('penguin exercise duration matches PRD', () {
    final exercise = createRotatorCuffRoutine().orderedExercises.first;
    expect(exerciseDurationSec(exercise), 5 + (8 + 8) * 10 * 5);
  });

  test('timer queue starts with prepare phase', () {
    final engine = WorkoutTimerEngine(
      createRotatorCuffRoutine(),
      labels: WorkoutTimerLabels(
        prepare: l10n.phasePrepare,
        completedMessage: l10n.workoutCompletedMessage,
      ),
    );
    expect(engine.snapshot.phase.kind, WorkoutPhaseKind.prepare);
    engine.dispose();
  });

  test('skipExercise on last exercise completes workout', () {
    final routine = createRotatorCuffRoutine();
    final engine = WorkoutTimerEngine(
      routine,
      labels: WorkoutTimerLabels(
        prepare: l10n.phasePrepare,
        completedMessage: l10n.workoutCompletedMessage,
      ),
    );

    for (var i = 0;
        i < routine.orderedExercises.length &&
            !engine.snapshot.isCompleted;
        i++) {
      engine.skipExercise();
    }

    expect(engine.snapshot.isCompleted, isTrue);
    engine.dispose();
  });

  test('routine json roundtrip preserves data', () {
    final routine = createRotatorCuffRoutine();
    final decoded = RoutineJsonCodec.decode(RoutineJsonCodec.encode(routine));
    expect(decoded.title, routine.title);
    expect(decoded.orderedExercises.length, routine.orderedExercises.length);
  });

  test('invalid json throws RoutineJsonException', () {
    expect(
      () => RoutineJsonCodec.decode(''),
      throwsA(isA<RoutineJsonException>()),
    );
  });

  test('formatDuration uses localized units', () {
    expect(formatDuration(45, l10n), l10n.durationSeconds(45));
  });
}
