import 'package:flutter/material.dart';

/// App locale helpers. UI language follows the device preferred language only.
abstract final class LocaleSettings {
  static const supportedLanguageCodes = ['en', 'ko', 'zh', 'ja'];

  static const defaultLocale = Locale('en');

  static Locale resolveSystemLocale({
    required Locale? systemLocale,
    required List<Locale> supportedLocales,
  }) {
    final system = systemLocale;
    if (system != null) {
      for (final supported in supportedLocales) {
        if (supported.languageCode == system.languageCode) {
          return supported;
        }
      }
    }

    return defaultLocale;
  }
}
