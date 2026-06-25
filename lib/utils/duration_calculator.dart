import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/exercise.dart';
import '../models/exercise_phase.dart';
import '../models/routine.dart';

int phaseDurationSec(ExercisePhase phase) => phase.effectiveDurationSec;

int repDurationSec(Exercise exercise) {
  return exercise.orderedPhases.fold(
    0,
    (sum, phase) => sum + phaseDurationSec(phase),
  );
}

int exerciseDurationSec(Exercise exercise) {
  return exercise.prepare.durationSec +
      repDurationSec(exercise) * exercise.reps * exercise.sets;
}

int routineDurationSec(Routine routine) {
  return routine.orderedExercises.fold(
    0,
    (sum, exercise) => sum + exerciseDurationSec(exercise),
  );
}

String formatDuration(int totalSec, AppLocalizations l10n) {
  final minutes = totalSec ~/ 60;
  final seconds = totalSec % 60;
  if (minutes == 0) return l10n.durationSeconds(seconds);
  if (seconds == 0) return l10n.durationMinutes(minutes);
  return l10n.durationMinutesSeconds(minutes, seconds);
}

String formatDurationShort(int totalSec, AppLocalizations l10n) {
  final minutes = (totalSec / 60).ceil();
  if (minutes < 60) return l10n.durationApproxMinutes(minutes);
  final hours = minutes ~/ 60;
  final remainMin = minutes % 60;
  if (remainMin == 0) return l10n.durationApproxHours(hours);
  return l10n.durationApproxHoursMinutes(hours, remainMin);
}
