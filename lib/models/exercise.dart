import 'description_block.dart';
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
    this.instructionBlocks = const [],
  });

  final String id;
  final String name;
  final String instruction;
  final List<DescriptionBlock> instructionBlocks;
  final int order;
  final TimedPhase prepare;
  final List<ExercisePhase> phases;
  final int reps;
  final int sets;

  List<DescriptionBlock> get effectiveInstructionBlocks {
    if (instructionBlocks.isNotEmpty) return instructionBlocks;
    return DescriptionBlock.fromLegacyDescription(instruction);
  }

  String get instructionPlainText =>
      DescriptionBlock.plainText(effectiveInstructionBlocks);

  List<ExercisePhase> get orderedPhases {
    final copy = List<ExercisePhase>.from(phases);
    copy.sort((a, b) => a.order.compareTo(b.order));
    return copy;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'instruction': instructionPlainText,
        if (instructionBlocks.isNotEmpty)
          'instructionBlocks':
              DescriptionBlock.listToJson(instructionBlocks),
        'order': order,
        'prepare': prepare.toJson(),
        'phases': phases.map((phase) => phase.toJson()).toList(),
        'reps': reps,
        'sets': sets,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final legacyInstruction = JsonField.optionalString(json, 'instruction');
    final blocks = DescriptionBlock.listFromJson(json['instructionBlocks']);
    final effectiveBlocks = blocks.isNotEmpty
        ? blocks
        : DescriptionBlock.fromLegacyDescription(legacyInstruction);

    return Exercise(
      id: JsonField.requiredString(json, 'id'),
      name: JsonField.requiredString(json, 'name'),
      instruction: DescriptionBlock.plainText(effectiveBlocks),
      instructionBlocks: blocks,
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
    List<DescriptionBlock>? instructionBlocks,
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
      instructionBlocks: instructionBlocks ?? this.instructionBlocks,
      order: order ?? this.order,
      prepare: prepare ?? this.prepare,
      phases: phases ?? this.phases,
      reps: reps ?? this.reps,
      sets: sets ?? this.sets,
    );
  }
}
