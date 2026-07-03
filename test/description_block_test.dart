import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/models/description_block.dart';
import 'package:tabata_timer/models/routine.dart';
import 'package:tabata_timer/utils/video_link_utils.dart';

void main() {
  test('description blocks round-trip json', () {
    final blocks = [
      const TextDescriptionBlock(text: '첫 설명'),
      ImageDescriptionBlock(
        url: 'https://example.com/a.jpg',
        alt: '자세',
      ),
      ImageDescriptionBlock(
        localPath: 'routine_media/routine-1/photo.jpg',
      ),
      const VideoDescriptionBlock(
        url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        provider: 'youtube',
      ),
      const TextDescriptionBlock(text: '마무리'),
    ];

    final json = DescriptionBlock.listToJson(blocks);
    final parsed = DescriptionBlock.listFromJson(json);

    expect(parsed, hasLength(5));
    expect(DescriptionBlock.plainText(parsed), '첫 설명\n\n마무리');

    final remoteImage = parsed[1] as ImageDescriptionBlock;
    expect(remoteImage.url, 'https://example.com/a.jpg');
    expect(remoteImage.hasLocalPath, isFalse);

    final localImage = parsed[2] as ImageDescriptionBlock;
    expect(localImage.localPath, 'routine_media/routine-1/photo.jpg');
    expect(localImage.hasRemoteUrl, isFalse);
  });

  test('routine json keeps descriptionBlocks', () {
    final routine = Routine(
      id: 'test-routine',
      title: 'Test',
      description: 'plain',
      descriptionBlocks: const [
        TextDescriptionBlock(text: 'plain'),
        VideoDescriptionBlock(
          url: 'https://youtu.be/abc123',
          provider: 'youtube',
        ),
      ],
      exercises: const [],
    );

    final decoded = Routine.fromJson(routine.toJson());
    expect(decoded.descriptionBlocks, hasLength(2));
    expect(decoded.description, 'plain');
  });

  test('healthActivityType roundtrips in json', () {
    final routine = Routine(
      id: 'health',
      title: 'HIIT',
      description: '',
      exercises: const [],
      healthActivityType: 'high_intensity_interval_training',
    );

    final decoded = Routine.fromJson(routine.toJson());
    expect(decoded.healthActivityType, 'high_intensity_interval_training');
  });

  test('missing healthActivityType deserializes as null', () {
    final routine = Routine.fromJson({
      'schemaVersion': 1,
      'id': 'legacy',
      'title': 'Legacy',
      'description': '',
      'exercises': [],
    });

    expect(routine.healthActivityType, isNull);
  });

  test('legacy description migrates to text block', () {
    final routine = Routine.fromJson({
      'schemaVersion': 1,
      'id': 'legacy',
      'title': 'Legacy',
      'description': 'old text',
      'exercises': [],
    });

    expect(routine.descriptionBlocks, isEmpty);
    final block = routine.effectiveDescriptionBlocks.single as TextDescriptionBlock;
    expect(block.text, 'old text');
  });

  test('youtube id parser supports common urls', () {
    expect(
      VideoLinkUtils.youtubeVideoId('https://www.youtube.com/watch?v=abc123'),
      'abc123',
    );
    expect(
      VideoLinkUtils.youtubeVideoId('https://youtu.be/abc123'),
      'abc123',
    );
    expect(
      VideoLinkUtils.youtubeEmbedUrl('https://youtu.be/abc123'),
      'https://www.youtube.com/embed/abc123?playsinline=1&rel=0&modestbranding=1&origin=https%3A%2F%2Fcom.smartcompany.tabata',
    );
  });
}
