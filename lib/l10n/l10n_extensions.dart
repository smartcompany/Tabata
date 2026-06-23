import 'package:tabata_timer/l10n/app_localizations.dart';

import '../engine/workout_timer_engine.dart';
import '../services/routine_json_codec.dart';

extension WorkoutPhaseKindL10n on WorkoutPhaseKind {
  String title(AppLocalizations l10n) {
    return switch (this) {
      WorkoutPhaseKind.prepare => l10n.phasePrepare,
      WorkoutPhaseKind.work => l10n.phaseWork,
      WorkoutPhaseKind.relax => l10n.phaseRelax,
      WorkoutPhaseKind.completed => l10n.phaseCompleted,
    };
  }
}

extension RoutineJsonErrorL10n on RoutineJsonError {
  String message(AppLocalizations l10n) {
    return switch (this) {
      RoutineJsonError.empty => l10n.errorEmptyJson,
      RoutineJsonError.notObject => l10n.errorInvalidRoutineJson,
      RoutineJsonError.invalidRoutine => l10n.errorInvalidRoutineJson,
    };
  }
}
