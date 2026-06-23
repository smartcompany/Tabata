import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

class LocaleSettings {
  LocaleSettings(this._prefs);

  static const _keyLanguageCode = 'app_language_code';

  final SharedPreferences _prefs;

  static const supportedLanguageCodes = ['en', 'ko', 'zh', 'ja'];

  static const defaultLocale = Locale('en');

  Locale? get locale {
    final code = _prefs.getString(_keyLanguageCode);
    if (code == null || code.isEmpty) return null;
    if (!supportedLanguageCodes.contains(code)) return null;
    return Locale(code);
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(_keyLanguageCode);
      return;
    }
    await _prefs.setString(_keyLanguageCode, locale.languageCode);
  }

  static Future<LocaleSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return LocaleSettings(prefs);
  }

  static Locale resolveLocale({
    required Locale? override,
    required Locale? systemLocale,
    required List<Locale> supportedLocales,
  }) {
    if (override != null) return override;

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

extension AppLocaleOption on Locale? {
  String label(AppLocalizations l10n) {
    return switch (this?.languageCode) {
      null => l10n.languageSystem,
      'en' => l10n.languageEnglish,
      'ko' => l10n.languageKorean,
      'zh' => l10n.languageChinese,
      'ja' => l10n.languageJapanese,
      _ => l10n.languageSystem,
    };
  }
}
