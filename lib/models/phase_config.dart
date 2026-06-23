import 'exercise_limits.dart';
import 'json_field.dart';

class PhaseConfig {
  const PhaseConfig({
    required this.label,
    required this.durationSec,
  });

  final String label;
  final int durationSec;

  Map<String, dynamic> toJson() => {
        'label': label,
        'durationSec': durationSec,
      };

  factory PhaseConfig.fromJson(Map<String, dynamic> json) {
    return PhaseConfig(
      label: JsonField.requiredString(json, 'label'),
      durationSec: JsonField.requiredInt(
        json,
        'durationSec',
        min: ExerciseLimits.minWorkRelaxDurationSec,
      ),
    );
  }

  PhaseConfig copyWith({String? label, int? durationSec}) {
    return PhaseConfig(
      label: label ?? this.label,
      durationSec: durationSec ?? this.durationSec,
    );
  }
}

class TimedPhase {
  const TimedPhase({required this.durationSec});

  final int durationSec;

  Map<String, dynamic> toJson() => {'durationSec': durationSec};

  factory TimedPhase.fromJson(Map<String, dynamic> json) {
    return TimedPhase(
      durationSec: JsonField.requiredInt(json, 'durationSec', min: 0),
    );
  }

  TimedPhase copyWith({int? durationSec}) {
    return TimedPhase(durationSec: durationSec ?? this.durationSec);
  }
}
