import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../services/app_review_service.dart';
import '../services/content_settings.dart';
import '../services/health_workout_recorder.dart';
import '../services/health_permission_flow.dart';
import '../services/workout_settings.dart';
import '../utils/health_platform_l10n.dart';
import '../utils/legal_urls.dart';
import '../widgets/health_app_info.dart';
import 'legal_webview_screen.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({
    super.key,
    this.onShowOnboardingAgain,
  });

  final Future<void> Function()? onShowOnboardingAgain;

  static Future<void> open(
    BuildContext context, {
    Future<void> Function()? onShowOnboardingAgain,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => AppSettingsScreen(
          onShowOnboardingAgain: onShowOnboardingAgain,
        ),
      ),
    );
  }

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  WorkoutSettings? _workoutSettings;
  ContentSettings? _contentSettings;
  var _countSecondsWithTts = false;
  var _saveToAppleHealth = false;
  var _autoTranslateContent = false;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final workoutSettings = await WorkoutSettings.load();
    final contentSettings = await ContentSettings.load();
    if (!mounted) return;
    setState(() {
      _workoutSettings = workoutSettings;
      _contentSettings = contentSettings;
      _countSecondsWithTts = workoutSettings.countSecondsWithTts;
      _saveToAppleHealth = workoutSettings.saveToAppleHealth;
      _autoTranslateContent = contentSettings.autoTranslateContent;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final sectionTitleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: colorScheme.onSurface.withValues(alpha: 0.86),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Theme(
              data: Theme.of(context).copyWith(
                dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.35),
                switchTheme: SwitchThemeData(
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
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
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  Text(
                    l10n.workoutSettingsSection,
                    style: sectionTitleStyle,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.countSecondsWithTtsTitle),
                    subtitle: Text(l10n.countSecondsWithTtsSubtitle),
                    value: _countSecondsWithTts,
                    onChanged: (value) async {
                      await _workoutSettings?.setCountSecondsWithTts(value);
                      if (!mounted) return;
                      setState(() => _countSecondsWithTts = value);
                    },
                  ),
                  if (HealthWorkoutRecorder.isSupported)
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: HealthAppLabel(
                        detailText: HealthPlatformL10n(l10n).saveDetail,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      value: _saveToAppleHealth,
                      onChanged: (value) async {
                        if (value) {
                          if (!await HealthPermissionFlow
                              .ensureHealthAppReadyForPermission(context)) {
                            return;
                          }
                          final granted = await HealthWorkoutRecorder
                              .requestWritePermission();
                          if (!mounted) return;
                          if (!granted) {
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  HealthPlatformL10n(l10n)
                                      .permissionRequiredSnack,
                                ),
                              ),
                            );
                            return;
                          }
                        }
                        await _workoutSettings?.setSaveToAppleHealth(value);
                        if (!mounted) return;
                        setState(() => _saveToAppleHealth = value);
                      },
                    ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Text(
                    l10n.contentSettingsSection,
                    style: sectionTitleStyle,
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.autoTranslateContentTitle),
                    subtitle: Text(l10n.autoTranslateContentSubtitle),
                    value: _autoTranslateContent,
                    onChanged: (value) async {
                      await _contentSettings?.setAutoTranslateContent(value);
                      if (!mounted) return;
                      setState(() => _autoTranslateContent = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Text(
                    l10n.settingsAppSection,
                    style: sectionTitleStyle,
                  ),
                  if (widget.onShowOnboardingAgain != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settingsShowOnboardingAgain),
                      subtitle: Text(l10n.settingsShowOnboardingAgainSubtitle),
                      trailing: const Icon(Icons.restart_alt_outlined),
                      onTap: () async {
                        final showAgain = widget.onShowOnboardingAgain!;
                        Navigator.of(context).pop();
                        await showAgain();
                      },
                    ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.settingsRateApp),
                    trailing: const Icon(Icons.star_outline_rounded),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await Future<void>.delayed(
                        const Duration(milliseconds: 350),
                      );
                      await AppReviewService.promptFromSettings();
                    },
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
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
                      LegalWebViewScreen.open(
                        context,
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
                      LegalWebViewScreen.open(
                        context,
                        url: LegalUrls.appDisclosures(locale),
                        pageTitle: l10n.settingsAppDisclosures,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
