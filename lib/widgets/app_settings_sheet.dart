import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../services/locale_settings.dart';
import '../services/sound_settings.dart';
import '../services/voice_settings.dart';

Future<void> showAppSettingsSheet(
  BuildContext context, {
  required LocaleSettings localeSettings,
  required VoidCallback onLocaleChanged,
}) async {
  final l10n = AppLocalizations.of(context);
  final voiceSettings = await VoiceSettings.load();
  final soundSettings = await SoundSettings.load();

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      var voiceEnabled = voiceSettings.enabled;
      var soundEnabled = soundSettings.enabled;
      var selectedLocale = localeSettings.locale;

      return StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> selectLocale(Locale? locale) async {
            await localeSettings.setLocale(locale);
            setSheetState(() => selectedLocale = locale);
            onLocaleChanged();
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              0,
              16,
              24 + MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.settingsTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.languageTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                _LanguageOptionTile(
                  label: l10n.languageSystem,
                  selected: selectedLocale == null,
                  onTap: () => selectLocale(null),
                ),
                _LanguageOptionTile(
                  label: l10n.languageEnglish,
                  selected: selectedLocale?.languageCode == 'en',
                  onTap: () => selectLocale(const Locale('en')),
                ),
                _LanguageOptionTile(
                  label: l10n.languageKorean,
                  selected: selectedLocale?.languageCode == 'ko',
                  onTap: () => selectLocale(const Locale('ko')),
                ),
                _LanguageOptionTile(
                  label: l10n.languageChinese,
                  selected: selectedLocale?.languageCode == 'zh',
                  onTap: () => selectLocale(const Locale('zh')),
                ),
                _LanguageOptionTile(
                  label: l10n.languageJapanese,
                  selected: selectedLocale?.languageCode == 'ja',
                  onTap: () => selectLocale(const Locale('ja')),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.voiceGuidance),
                  subtitle: Text(l10n.voiceGuidanceSubtitle),
                  value: voiceEnabled,
                  onChanged: (value) async {
                    await voiceSettings.setEnabled(value);
                    setSheetState(() => voiceEnabled = value);
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.soundEffects),
                  subtitle: Text(l10n.soundEffectsSubtitle),
                  value: soundEnabled,
                  onChanged: (value) async {
                    await soundSettings.setEnabled(value);
                    setSheetState(() => soundEnabled = value);
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}
