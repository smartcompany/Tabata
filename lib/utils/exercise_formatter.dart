import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/exercise.dart';
import '../models/exercise_phase.dart';
import 'duration_calculator.dart';

abstract final class ExerciseFormatter {
  static String displayName(Exercise exercise, AppLocalizations l10n) {
    if (exercise.name.isEmpty) return l10n.newExercise;
    return exercise.name;
  }

  static String phaseKindLabel(ExercisePhaseKind kind, AppLocalizations l10n) {
    return switch (kind) {
      ExercisePhaseKind.work => l10n.labelWork,
      ExercisePhaseKind.relax => l10n.labelRelax,
    };
  }

  static String phaseWithDuration(
    String label,
    int seconds,
    AppLocalizations l10n,
  ) {
    return l10n.phaseWithDuration(label, seconds);
  }

  static String phasesSummary(Exercise exercise, AppLocalizations l10n) {
    return exercise.orderedPhases
        .map(
          (phase) => phaseWithDuration(phase.label, phase.durationSec, l10n),
        )
        .join(' → ');
  }

  static String listSubtitle(Exercise exercise, AppLocalizations l10n) {
    final oneSetSec =
        exercise.prepare.durationSec + repDurationSec(exercise) * exercise.reps;
    return l10n.exerciseListSubtitle(
      phasesSummary(exercise, l10n),
      l10n.repsSetsSummary(exercise.reps, exercise.sets),
      l10n.oneSetDuration(formatDuration(oneSetSec, l10n)),
    );
  }

  static String oneSetDuration(Exercise exercise, AppLocalizations l10n) {
    final oneSetSec =
        exercise.prepare.durationSec + repDurationSec(exercise) * exercise.reps;
    return l10n.oneSetDuration(formatDuration(oneSetSec, l10n));
  }
}
