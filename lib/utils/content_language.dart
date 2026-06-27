import 'dart:ui';

import '../services/locale_settings.dart';

abstract final class ContentLanguage {
  static const defaultLanguage = 'ko';

  static String current({Locale? systemLocale}) {
    return LocaleSettings.resolveSystemLocale(
      systemLocale: systemLocale ?? PlatformDispatcher.instance.locale,
      supportedLocales: [
        for (final code in LocaleSettings.supportedLanguageCodes) Locale(code),
      ],
    ).languageCode;
  }

  static String? parse(String? raw) {
    if (raw == null) return null;
    final code = raw.trim();
    if (code.isEmpty) return null;
    if (LocaleSettings.supportedLanguageCodes.contains(code)) return code;
    return null;
  }

  /// Legacy routines without [contentLanguage] are treated as Korean content.
  static String resolve(String? raw) => parse(raw) ?? defaultLanguage;

  static bool matchesTarget(String? contentLanguage, String targetLanguage) {
    return resolve(contentLanguage) == targetLanguage;
  }
}
