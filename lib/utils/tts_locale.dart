import 'package:flutter/material.dart';

const _ttsLanguageByCode = {
  'en': 'en-US',
  'ko': 'ko-KR',
  'zh': 'zh-CN',
  'ja': 'ja-JP',
};

String ttsLanguageForLocale(Locale locale) {
  return _ttsLanguageByCode[locale.languageCode] ?? 'en-US';
}

List<String> ttsFallbackLanguagesForLocale(Locale locale) {
  final primary = ttsLanguageForLocale(locale);
  return {primary, 'en-US'}.toList();
}
