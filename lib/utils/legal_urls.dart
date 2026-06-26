import 'package:flutter/material.dart';

import '../config/api_config.dart';

/// Legal document URLs served from tabata-server `/legal/*`.
abstract final class LegalUrls {
  static String localeHash(Locale? locale) {
    final code = locale?.languageCode ?? 'ko';
    return switch (code) {
      'en' => 'en',
      'ja' => 'en',
      'zh' => 'en',
      _ => 'ko',
    };
  }

  static Uri privacyPolicy(Locale? locale) => Uri.parse(
        '${ApiConfig.profileApiBaseUrl}/legal/privacy.html#${localeHash(locale)}',
      );

  static Uri appDisclosures(Locale? locale) => Uri.parse(
        '${ApiConfig.profileApiBaseUrl}/legal/app-disclosures.html#${localeHash(locale)}',
      );
}
