import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../screens/legal_webview_screen.dart';
import '../services/app_review_service.dart';
import '../services/content_settings.dart';
import '../services/health_workout_recorder.dart';
import '../services/health_permission_flow.dart';
import '../services/workout_settings.dart';
import '../utils/health_platform_l10n.dart';
import '../utils/legal_urls.dart';
import 'health_app_info.dart';

Future<void> showAppSettingsSheet(
  BuildContext hostContext, {
  Future<void> Function()? onShowOnboardingAgain,
}) async {
  final l10n = AppLocalizations.of(hostContext);
  final workoutSettings = await WorkoutSettings.load();
  final contentSettings = await ContentSettings.load();

  if (!hostContext.mounted) return;

  await showModalBottomSheet<void>(
    context: hostContext,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(hostContext).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      var countSecondsWithTts = workoutSettings.countSecondsWithTts;
      var saveToAppleHealth = workoutSettings.saveToAppleHealth;
      var autoTranslateContent = contentSettings.autoTranslateContent;

      return StatefulBuilder(
        builder: (context, setSheetState) {
          final colorScheme = Theme.of(context).colorScheme;
          final sectionTitleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: colorScheme.onSurface.withValues(alpha: 0.86),
          );
          final sheetTheme = Theme.of(context).copyWith(
            dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.35),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return colorScheme.outline;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return colorScheme.primary.withValues(alpha: 0.85);
                }
                return colorScheme.surfaceContainerHigh;
              }),
            ),
            listTileTheme: ListTileThemeData(
              iconColor: colorScheme.onSurfaceVariant,
              textColor: colorScheme.onSurface,
            ),
          );

          return Theme(
            data: sheetTheme,
            child: Padding(
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
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.workoutSettingsSection,
                    style: sectionTitleStyle,
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
                  if (HealthWorkoutRecorder.isSupported) ...[
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: HealthAppLabel(
                        detailText: HealthPlatformL10n(l10n).saveDetail,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      value: saveToAppleHealth,
                      onChanged: (value) async {
                        if (value) {
                          if (!await HealthPermissionFlow
                              .ensureHealthAppReadyForPermission(context)) {
                            return;
                          }
                          final granted =
                              await HealthWorkoutRecorder.requestWritePermission();
                          if (!context.mounted) return;
                          if (!granted) {
                            ScaffoldMessenger.of(hostContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  HealthPlatformL10n(l10n).permissionRequiredSnack,
                                ),
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
                  const SizedBox(height: 8),
                  Divider(height: 1),
                  const SizedBox(height: 20),
                  Text(
                    l10n.contentSettingsSection,
                    style: sectionTitleStyle,
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
                  const SizedBox(height: 8),
                  Divider(height: 1),
                  const SizedBox(height: 20),
                  Text(
                    l10n.settingsAppSection,
                    style: sectionTitleStyle,
                  ),
                  if (onShowOnboardingAgain != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settingsShowOnboardingAgain),
                      subtitle: Text(l10n.settingsShowOnboardingAgainSubtitle),
                      trailing: const Icon(Icons.restart_alt_outlined),
                      onTap: () async {
                        Navigator.of(context).pop();
                        await onShowOnboardingAgain();
                      },
                    ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.settingsRateApp),
                    trailing: const Icon(Icons.star_outline_rounded),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await Future<void>.delayed(const Duration(milliseconds: 350));
                      await AppReviewService.promptFromSettings();
                    },
                  ),
                  const SizedBox(height: 8),
                  Divider(height: 1),
                  const SizedBox(height: 20),
                  Text(
                    l10n.settingsLegalSection,
                    style: sectionTitleStyle,
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
            ),
          );
        },
      );
    },
  );
}
