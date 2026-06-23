import 'exercise_limits.dart';
import 'exercise_phase.dart';
import 'json_field.dart';
import 'phase_config.dart';

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.instruction,
    required this.order,
    required this.prepare,
    required this.phases,
    required this.reps,
    required this.sets,
  });

  final String id;
  final String name;
  final String instruction;
  final int order;
  final TimedPhase prepare;
  final List<ExercisePhase> phases;
  final int reps;
  final int sets;

  List<ExercisePhase> get orderedPhases {
    final copy = List<ExercisePhase>.from(phases);
    copy.sort((a, b) => a.order.compareTo(b.order));
    return copy;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'instruction': instruction,
        'order': order,
        'prepare': prepare.toJson(),
        'phases': phases.map((phase) => phase.toJson()).toList(),
        'reps': reps,
        'sets': sets,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: JsonField.requiredString(json, 'id'),
      name: JsonField.requiredString(json, 'name'),
      instruction: JsonField.optionalString(json, 'instruction'),
      order: JsonField.requiredInt(json, 'order', min: 0),
      prepare: TimedPhase.fromJson(JsonField.requiredMap(json, 'prepare')),
      phases: parseExercisePhases(json),
      reps: JsonField.requiredInt(
        json,
        'reps',
        min: ExerciseLimits.minReps,
      ),
      sets: JsonField.requiredInt(
        json,
        'sets',
        min: ExerciseLimits.minSets,
      ),
    );
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? instruction,
    int? order,
    TimedPhase? prepare,
    List<ExercisePhase>? phases,
    int? reps,
    int? sets,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      instruction: instruction ?? this.instruction,
      order: order ?? this.order,
      prepare: prepare ?? this.prepare,
      phases: phases ?? this.phases,
      reps: reps ?? this.reps,
      sets: sets ?? this.sets,
    );
  }
}
