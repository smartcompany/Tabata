import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../app_auth_provider.dart';
import '../features/legal/privacy_processing_consent.dart';
import '../screens/legal_webview_screen.dart';
import '../services/content_settings.dart';
import '../services/health_workout_recorder.dart';
import '../services/workout_settings.dart';
import '../utils/account_deletion.dart';
import '../utils/legal_urls.dart';

Future<void> showAppSettingsSheet(BuildContext hostContext) async {
  final l10n = AppLocalizations.of(hostContext);
  final workoutSettings = await WorkoutSettings.load();
  final contentSettings = await ContentSettings.load();
  await AppAuthProvider.shared.ensureInitialized();
  final isLoggedIn = AppAuthProvider.shared.isLoggedIn();

  if (!hostContext.mounted) return;

  await showModalBottomSheet<void>(
    context: hostContext,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      var countSecondsWithTts = workoutSettings.countSecondsWithTts;
      var saveToAppleHealth = workoutSettings.saveToAppleHealth;
      var autoTranslateContent = contentSettings.autoTranslateContent;

      return StatefulBuilder(
        builder: (context, setSheetState) {
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
                  l10n.workoutSettingsSection,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.countSecondsWithTtsTitle),
                  subtitle: Text(l10n.countSecondsWithTtsSubtitle),
                  value: countSecondsWithTts,
                  onChanged: (value) async {
                    await workoutSettings.setCountSecondsWithTts(value);
                    setSheetState(() => countSecondsWithTts = value);
                  },
                ),
                if (Platform.isIOS) ...[
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.healthSaveToAppleHealthTitle),
                    subtitle: Text(l10n.healthSaveToAppleHealthSubtitle),
                    value: saveToAppleHealth,
                    onChanged: (value) async {
                      if (value) {
                        final granted =
                            await HealthWorkoutRecorder.requestWritePermission();
                        if (!context.mounted) return;
                        if (!granted) {
                          ScaffoldMessenger.of(hostContext).showSnackBar(
                            SnackBar(
                              content: Text(l10n.healthPermissionRequiredSnack),
                            ),
                          );
                          return;
                        }
                      }
                      await workoutSettings.setSaveToAppleHealth(value);
                      setSheetState(() => saveToAppleHealth = value);
                    },
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  l10n.contentSettingsSection,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.autoTranslateContentTitle),
                  subtitle: Text(l10n.autoTranslateContentSubtitle),
                  value: autoTranslateContent,
                  onChanged: (value) async {
                    await contentSettings.setAutoTranslateContent(value);
                    setSheetState(() => autoTranslateContent = value);
                  },
                ),
                const SizedBox(height: 20),
                if (isLoggedIn) ...[
                  Text(
                    l10n.settingsAccountSection,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.settingsSignOut),
                    trailing: const Icon(Icons.logout),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await clearPrivacyProcessingConsent();
                      await AppAuthProvider.shared.logout();
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      l10n.settingsDeleteAccount,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    trailing: Icon(
                      Icons.person_remove_outlined,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await confirmAndDeleteAccount(hostContext);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  l10n.settingsLegalSection,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsPrivacyPolicy),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final locale = Localizations.localeOf(context);
                    Navigator.of(context).pop();
                    LegalWebViewScreen.open(
                      hostContext,
                      url: LegalUrls.privacyPolicy(locale),
                      pageTitle: l10n.settingsPrivacyPolicy,
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsAppDisclosures),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final locale = Localizations.localeOf(context);
                    Navigator.of(context).pop();
                    LegalWebViewScreen.open(
                      hostContext,
                      url: LegalUrls.appDisclosures(locale),
                      pageTitle: l10n.settingsAppDisclosures,
                    );
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
