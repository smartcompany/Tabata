import 'package:uuid/uuid.dart';

import '../models/exercise.dart';
import '../models/exercise_limits.dart';
import '../models/exercise_phase.dart';
import '../models/phase_config.dart';
import '../models/routine.dart';

const _uuid = Uuid();

Routine createEmptyRoutine() {
  return Routine(
    id: _uuid.v4(),
    title: '',
    description: '',
    exercises: [],
  );
}

Exercise createEmptyExercise({required int order}) {
  return Exercise(
    id: _uuid.v4(),
    name: '',
    instruction: '',
    order: order,
    prepare: const TimedPhase(durationSec: ExerciseLimits.defaultPrepareDurationSec),
    phases: reindexPhases([
      createEmptyPhase(kind: ExercisePhaseKind.work, order: 0),
      createEmptyPhase(kind: ExercisePhaseKind.relax, order: 1),
    ]),
    reps: ExerciseLimits.minReps,
    sets: ExerciseLimits.minSets,
  );
}

List<Exercise> reindexExercises(List<Exercise> exercises) {
  return [
    for (var i = 0; i < exercises.length; i++)
      exercises[i].copyWith(order: i),
  ];
}
