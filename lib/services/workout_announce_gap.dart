import '../engine/workout_timer_engine.dart';

const workRelaxSessionGap = Duration(seconds: 1);

bool needsWorkRelaxSessionGap(
  WorkoutTimerSnapshot? previous,
  WorkoutTimerSnapshot current,
) {
  if (previous == null || previous.isCompleted || current.isCompleted) {
    return false;
  }
  return previous.phase.kind == WorkoutPhaseKind.relax &&
      current.phase.kind != WorkoutPhaseKind.relax;
}
