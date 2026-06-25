import 'package:uuid/uuid.dart';

import '../models/exercise.dart';
import '../models/exercise_phase.dart';
import '../models/routine.dart';
import 'routine_factory.dart';

const _uuid = Uuid();

/// Deep-clones [source] with a new routine id and fresh exercise/phase ids.
Routine forkRoutine(Routine source, {String? newRoutineId}) {
  final exercises = source.orderedExercises;
  return source.copyWith(
    id: newRoutineId ?? _uuid.v4(),
    exercises: [
      for (var i = 0; i < exercises.length; i++)
        _forkExercise(exercises[i], order: i),
    ],
  );
}

Exercise _forkExercise(Exercise exercise, {required int order}) {
  return exercise.copyWith(
    id: _uuid.v4(),
    order: order,
    phases: reindexPhases([
      for (final phase in exercise.orderedPhases)
        phase.copyWith(id: _uuid.v4()),
    ]),
  );
}
