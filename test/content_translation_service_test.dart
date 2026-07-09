import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/services/content_translation_service.dart';

void main() {
  test('translateMap returns cached translations when nothing is pending', () async {
    final service = ContentTranslationService();
    service.seedCacheForTesting(
      targetLanguage: 'en',
      source: '한국어 제목',
      translated: 'Korean title',
    );

    final map = await service.translateMap(
      texts: ['한국어 제목'],
      targetLanguage: 'en',
    );

    expect(map['한국어 제목'], 'Korean title');
  });
}
