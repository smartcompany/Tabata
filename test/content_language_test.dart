import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/utils/content_language.dart';

void main() {
  test('current resolves supported device locale', () {
    expect(
      ContentLanguage.current(systemLocale: const Locale('ko')),
      'ko',
    );
    expect(
      ContentLanguage.current(systemLocale: const Locale('fr')),
      'en',
    );
  });

  test('matchesTarget compares stored content language', () {
    expect(ContentLanguage.matchesTarget('ko', 'ko'), isTrue);
    expect(ContentLanguage.matchesTarget('en', 'ko'), isFalse);
    expect(ContentLanguage.matchesTarget(null, 'ko'), isTrue);
    expect(ContentLanguage.matchesTarget(null, 'en'), isFalse);
  });

  test('resolve defaults missing language to Korean', () {
    expect(ContentLanguage.resolve(null), 'ko');
    expect(ContentLanguage.resolve(''), 'ko');
    expect(ContentLanguage.resolve('en'), 'en');
  });
}
