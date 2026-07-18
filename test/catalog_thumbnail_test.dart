import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/models/description_block.dart';
import 'package:tabata_timer/models/exercise.dart';
import 'package:tabata_timer/models/exercise_phase.dart';
import 'package:tabata_timer/models/phase_config.dart';
import 'package:tabata_timer/models/routine.dart';
import 'package:tabata_timer/utils/catalog_thumbnail.dart';

void main() {
  group('pickRoutineListThumbnail', () {
    test('returns first remote image from description blocks', () {
      final routine = Routine(
        id: 'r1',
        title: 'Test',
        description: '',
        exercises: const [],
        descriptionBlocks: [
          const TextDescriptionBlock(text: 'intro'),
          ImageDescriptionBlock(url: 'https://example.com/desc.jpg'),
        ],
      );

      final thumb = pickRoutineListThumbnail(routine);
      expect(thumb?.imageUrl, 'https://example.com/desc.jpg');
      expect(thumb?.isVideo, isFalse);
    });

    test('falls back to exercise instruction blocks', () {
      final routine = Routine(
        id: 'r1',
        title: 'Test',
        description: '',
        exercises: [
          Exercise(
            id: 'e1',
            name: 'Squat',
            instruction: '',
            order: 0,
            prepare: const TimedPhase(durationSec: 0),
            phases: const [
              ExercisePhase(
                id: 'p1',
                kind: ExercisePhaseKind.work,
                label: 'Squat',
                durationSec: 20,
                order: 0,
              ),
            ],
            reps: 1,
            sets: 1,
            instructionBlocks: [
              ImageDescriptionBlock(url: 'https://example.com/ex.jpg'),
            ],
          ),
        ],
      );

      expect(
        pickRoutineListThumbnail(routine)?.imageUrl,
        'https://example.com/ex.jpg',
      );
    });

    test('falls back to YouTube thumbnail when no images', () {
      final routine = Routine(
        id: 'r1',
        title: 'Test',
        description: '',
        exercises: const [],
        descriptionBlocks: const [
          TextDescriptionBlock(text: 'intro'),
          VideoDescriptionBlock(
            url: 'https://www.youtube.com/watch?v=abc123XYZ01',
            provider: 'youtube',
          ),
        ],
      );

      final thumb = pickRoutineListThumbnail(routine);
      expect(
        thumb?.imageUrl,
        'https://img.youtube.com/vi/abc123XYZ01/hqdefault.jpg',
      );
      expect(thumb?.isVideo, isTrue);
    });

    test('prefers image over YouTube', () {
      final routine = Routine(
        id: 'r1',
        title: 'Test',
        description: '',
        exercises: const [],
        descriptionBlocks: [
          const VideoDescriptionBlock(
            url: 'https://www.youtube.com/watch?v=abc123XYZ01',
            provider: 'youtube',
          ),
          ImageDescriptionBlock(url: 'https://example.com/first.jpg'),
        ],
      );

      final thumb = pickRoutineListThumbnail(routine);
      expect(thumb?.imageUrl, 'https://example.com/first.jpg');
      expect(thumb?.isVideo, isFalse);
    });

    test('returns null when no remote media exist', () {
      final routine = Routine(
        id: 'r1',
        title: 'Test',
        description: '',
        exercises: const [],
        descriptionBlocks: const [TextDescriptionBlock(text: 'text only')],
      );

      expect(pickRoutineListThumbnail(routine), isNull);
    });
  });

  group('pickCatalogThumbnailImageUrl', () {
    test('returns image url string for catalog cards', () {
      final routine = Routine(
        id: 'r1',
        title: 'Test',
        description: '',
        exercises: const [],
        descriptionBlocks: [
          ImageDescriptionBlock(url: 'https://example.com/desc.jpg'),
        ],
      );

      expect(
        pickCatalogThumbnailImageUrl(routine),
        'https://example.com/desc.jpg',
      );
    });
  });
}
