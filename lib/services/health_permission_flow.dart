import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../utils/health_platform_l10n.dart';
import 'app_analytics_service.dart';
import 'health_workout_recorder.dart';
import 'workout_settings.dart';

/// Guides the user through health-app write permission in context.
abstract final class HealthPermissionFlow {
  /// 운동 유형 선택 시 Health Connect / Apple Health 쓰기 권한을 확보합니다.
  static Future<void> maybePromptOnHealthActivityTypeSelected(
    BuildContext context,
  ) async {
    if (!HealthWorkoutRecorder.isSupported) return;

    if (await HealthWorkoutRecorder.hasWritePermission()) {
      final settings = await WorkoutSettings.load();
      if (!settings.saveToHealthApp) {
        await settings.setSaveToAppleHealth(true);
      }
      return;
    }

    if (!context.mounted) return;

    final settings = await WorkoutSettings.load();
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final platform = HealthPlatformL10n(l10n);

    var enable = true;
    if (!settings.appleHealthPreferenceAsked) {
      await AppAnalyticsService.logProductEvent('health_prompt_shown');
      if (!context.mounted) return;
      enable = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: Text(platform.firstWorkoutPromptTitle),
              content: Text(platform.firstWorkoutPromptBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.healthFirstWorkoutPromptNotNow),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.healthFirstWorkoutPromptEnable),
                ),
              ],
            ),
          ) ??
          false;
    }

    if (!context.mounted) return;

    var saveToHealth = false;
    if (enable) {
      if (!await _ensureHealthAppReady(context)) {
        saveToHealth = false;
      } else {
        saveToHealth = await HealthWorkoutRecorder.requestWritePermission();
        await AppAnalyticsService.logProductEvent(
          'health_permission_result',
          properties: {
            'result': saveToHealth ? 'granted' : 'denied_or_unknown',
          },
        );
        if (!saveToHealth && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(platform.permissionRequiredSnack)),
          );
        }
      }
    }

    final latest = await WorkoutSettings.load();
    await latest.setSaveToAppleHealth(saveToHealth);
    await latest.setAppleHealthPreferenceAsked(true);
    await AppAnalyticsService.logProductEvent(
      saveToHealth ? 'health_sync_enabled' : 'health_sync_disabled',
    );
  }

  /// Android: Health Connect 미설치 시 Play Store 설치 화면 안내.
  static Future<bool> _ensureHealthAppReady(BuildContext context) async {
    if (!Platform.isAndroid) return true;
    if (await HealthWorkoutRecorder.isHealthAppReady()) return true;
    if (!context.mounted) return false;

    final l10n = AppLocalizations.of(context);
    final install = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.healthConnectInstallPromptTitle),
        content: Text(l10n.healthConnectInstallPromptBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.healthConnectInstallPromptInstall),
          ),
        ],
      ),
    );
    if (install == true) {
      await HealthWorkoutRecorder.promptInstallHealthConnect();
    }
    return false;
  }

  /// 설정 등에서 권한 요청 전 Health Connect 설치 여부 확인.
  static Future<bool> ensureHealthAppReadyForPermission(
    BuildContext context,
  ) async {
    return _ensureHealthAppReady(context);
  }
}
