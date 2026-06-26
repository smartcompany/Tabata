import 'dart:ui';

import 'package:translator/translator.dart';

import 'locale_settings.dart';

/// Translates user-generated server content on the device (no server round-trip).
class ContentTranslationService {
  ContentTranslationService({GoogleTranslator? translator})
      : _translator = translator ?? GoogleTranslator();

  final GoogleTranslator _translator;
  final Map<String, String> _cache = {};

  String resolveTargetLanguage({
    Locale? systemLocale,
  }) {
    return LocaleSettings.resolveSystemLocale(
      systemLocale: systemLocale,
      supportedLocales: LocaleSettings.supportedLanguageCodes
          .map((code) => Locale(code))
          .toList(),
    ).languageCode;
  }

  Future<Map<String, String>> translateMap({
    required Iterable<String> texts,
    required String targetLanguage,
  }) async {
    final pending = <String>[];
    final seen = <String>{};
    for (final text in texts) {
      if (!_shouldTranslate(text)) continue;
      if (_cache.containsKey(_cacheKey(targetLanguage, text))) continue;
      if (seen.add(text)) pending.add(text);
    }

    for (final source in pending) {
      try {
        final result = await _translator.translate(
          source,
          to: _translatorLanguageCode(targetLanguage),
        );
        _cache[_cacheKey(targetLanguage, source)] = result.text;
      } catch (_) {
        _cache[_cacheKey(targetLanguage, source)] = source;
      }
    }

    return {
      for (final text in texts)
        if (_shouldTranslate(text))
          text: _cache[_cacheKey(targetLanguage, text)] ?? text
        else
          text: text,
    };
  }

  String _translatorLanguageCode(String languageCode) {
    return switch (languageCode) {
      'zh' => 'zh-cn',
      _ => languageCode,
    };
  }

  bool _shouldTranslate(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) return false;
    return true;
  }

  String _cacheKey(String targetLanguage, String text) => '$targetLanguage|$text';
}
