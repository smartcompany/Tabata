import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/models/exercise.dart';
import 'package:tabata_timer/models/exercise_phase.dart';
import 'package:tabata_timer/models/phase_config.dart';
import 'package:tabata_timer/utils/duration_calculator.dart';

Exercise _exerciseWithCountPhase({
  int countReps = 100,
  int secondsPerRep = 5,
}) {
  return Exercise(
    id: 'e1',
    name: '스쿼트',
    instruction: '',
    prepare: const TimedPhase(durationSec: 10),
    phases: [
      ExercisePhase(
        id: 'p1',
        kind: ExercisePhaseKind.work,
        label: '스쿼트',
        durationSec: 20,
        order: 0,
        timingMode: PhaseTimingMode.count,
        countReps: countReps,
        secondsPerRep: secondsPerRep,
      ),
    ],
    reps: 1,
    sets: 1,
    order: 0,
  );
}

void main() {
  test('count mode uses reps times seconds per rep', () {
    final exercise = _exerciseWithCountPhase();
    expect(repDurationSec(exercise), 500);
    expect(exerciseDurationSec(exercise), 510);
  });

  test('duration mode unchanged', () {
    final exercise = Exercise(
      id: 'e1',
      name: '점프',
      instruction: '',
      prepare: const TimedPhase(durationSec: 0),
      phases: [
        ExercisePhase(
          id: 'p1',
          kind: ExercisePhaseKind.work,
          label: '점프',
          durationSec: 20,
          order: 0,
        ),
      ],
      reps: 2,
      sets: 1,
      order: 0,
    );
    expect(repDurationSec(exercise), 20);
    expect(exerciseDurationSec(exercise), 40);
  });
}
