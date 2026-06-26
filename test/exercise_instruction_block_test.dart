import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/models/description_block.dart';
import 'package:tabata_timer/models/exercise.dart';
import 'package:tabata_timer/models/exercise_phase.dart';
import 'package:tabata_timer/models/phase_config.dart';

Exercise _sampleExercise({List<DescriptionBlock> instructionBlocks = const []}) {
  return Exercise(
    id: 'ex-1',
    name: 'Push-up',
    instruction: 'legacy text',
    instructionBlocks: instructionBlocks,
    order: 0,
    prepare: const TimedPhase(durationSec: 10),
    phases: const [
      ExercisePhase(
        id: 'phase-1',
        kind: ExercisePhaseKind.work,
        label: 'Work',
        durationSec: 20,
        order: 0,
      ),
    ],
    reps: 8,
    sets: 4,
  );
}

void main() {
  test('exercise json keeps instructionBlocks', () {
    final exercise = _sampleExercise(
      instructionBlocks: const [
        TextDescriptionBlock(text: '자세 설명'),
        VideoDescriptionBlock(
          url: 'https://youtu.be/abc123',
          provider: 'youtube',
        ),
      ],
    );

    final decoded = Exercise.fromJson(exercise.toJson());
    expect(decoded.instructionBlocks, hasLength(2));
    expect(decoded.instruction, '자세 설명');
  });

  test('legacy instruction migrates to text block', () {
    final exercise = Exercise.fromJson({
      'id': 'legacy',
      'name': 'Squat',
      'instruction': 'old text',
      'order': 0,
      'prepare': {'durationSec': 5},
      'phases': [
        {
          'id': 'p1',
          'kind': 'work',
          'label': 'Work',
          'durationSec': 20,
          'order': 0,
        },
      ],
      'reps': 8,
      'sets': 4,
    });

    expect(exercise.instructionBlocks, isEmpty);
    final block =
        exercise.effectiveInstructionBlocks.single as TextDescriptionBlock;
    expect(block.text, 'old text');
  });
}
