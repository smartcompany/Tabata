import 'package:uuid/uuid.dart';

import '../models/exercise.dart';
import '../models/exercise_phase.dart';
import '../models/routine.dart';

const _uuid = Uuid();

/// Deep-clones [source] with a new routine id and fresh exercise/phase ids.
Routine forkRoutine(Routine source, {String? newRoutineId}) {
  final exercises = source.orderedExercises;
  return source.copyWith(
    id: newRoutineId ?? _uuid.v4(),
    exercises: [
      for (var i = 0; i < exercises.length; i++)
        forkExercise(exercises[i], order: i),
    ],
  );
}

/// Clones [exercise] with fresh ids for appending to another routine.
Exercise forkExercise(Exercise exercise, {required int order}) {
  return exercise.copyWith(
    id: _uuid.v4(),
    order: order,
    phases: reindexPhases([
      for (final phase in exercise.orderedPhases)
        phase.copyWith(id: _uuid.v4()),
    ]),
  );
}

/// Clones selected exercises from [sourceExercises] in list order.
List<Exercise> forkSelectedExercises(
  List<Exercise> sourceExercises,
  Set<String> selectedIds, {
  required int startOrder,
}) {
  var order = startOrder;
  return [
    for (final exercise in sourceExercises)
      if (selectedIds.contains(exercise.id))
        forkExercise(exercise, order: order++),
  ];
}
