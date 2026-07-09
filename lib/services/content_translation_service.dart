import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:translator/translator.dart';

import 'locale_settings.dart';

/// Translates user-generated server content on the device (no server round-trip).
class ContentTranslationService {
  ContentTranslationService({GoogleTranslator? translator})
      : _translator = translator ?? GoogleTranslator();

  static const _translateConcurrency = 8;

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
      if (!_shouldTranslate(text)) {
        _cache[_cacheKey(targetLanguage, text)] = text;
        continue;
      }
      if (_cache.containsKey(_cacheKey(targetLanguage, text))) continue;
      if (seen.add(text)) pending.add(text);
    }

    if (pending.isNotEmpty) {
      for (var i = 0; i < pending.length; i += _translateConcurrency) {
        final chunk = pending.skip(i).take(_translateConcurrency).toList();
        await Future.wait([
          for (final source in chunk) _translateOne(source, targetLanguage),
        ]);
      }
    }

    return _resultMap(texts, targetLanguage);
  }

  Map<String, String> _resultMap(
    Iterable<String> texts,
    String targetLanguage,
  ) {
    return {
      for (final text in texts)
        text: _cache[_cacheKey(targetLanguage, text)] ?? text,
    };
  }

  @visibleForTesting
  void seedCacheForTesting({
    required String targetLanguage,
    required String source,
    required String translated,
  }) {
    _cache[_cacheKey(targetLanguage, source)] = translated;
  }

  Future<void> _translateOne(String source, String targetLanguage) async {
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
