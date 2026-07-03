import 'package:health/health.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

/// Stored on [Routine.healthActivityType] as a stable string id.
enum RoutineHealthActivityType {
  functionalStrengthTraining('functional_strength_training'),
  flexibility('flexibility'),
  highIntensityIntervalTraining('high_intensity_interval_training'),
  traditionalStrengthTraining('traditional_strength_training'),
  other('other');

  const RoutineHealthActivityType(this.id);

  final String id;

  static RoutineHealthActivityType? fromId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final type in values) {
      if (type.id == id) return type;
    }
    return null;
  }

  static String labelFor(AppLocalizations l10n, String id) {
    return fromId(id)?.label(l10n) ?? id;
  }

  String label(AppLocalizations l10n) {
    return switch (this) {
      RoutineHealthActivityType.functionalStrengthTraining =>
        l10n.healthActivityTypeFunctionalStrength,
      RoutineHealthActivityType.flexibility =>
        l10n.healthActivityTypeFlexibility,
      RoutineHealthActivityType.highIntensityIntervalTraining =>
        l10n.healthActivityTypeHiit,
      RoutineHealthActivityType.traditionalStrengthTraining =>
        l10n.healthActivityTypeTraditionalStrength,
      RoutineHealthActivityType.other => l10n.healthActivityTypeOther,
    };
  }

  HealthWorkoutActivityType toHealthWorkoutType() {
    return switch (this) {
      RoutineHealthActivityType.functionalStrengthTraining =>
        HealthWorkoutActivityType.FUNCTIONAL_STRENGTH_TRAINING,
      RoutineHealthActivityType.flexibility =>
        HealthWorkoutActivityType.FLEXIBILITY,
      RoutineHealthActivityType.highIntensityIntervalTraining =>
        HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING,
      RoutineHealthActivityType.traditionalStrengthTraining =>
        HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
      RoutineHealthActivityType.other => HealthWorkoutActivityType.OTHER,
    };
  }
}
