import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../utils/health_platform_l10n.dart';
import 'health_workout_recorder.dart';
import 'workout_settings.dart';

/// Guides the user through health-app write permission in context.
abstract final class HealthPermissionFlow {
  /// Asks once when the user picks a workout type for health recording.
  static Future<void> maybePromptOnHealthActivityTypeSelected(
    BuildContext context,
  ) async {
    if (!HealthWorkoutRecorder.isSupported) return;

    final settings = await WorkoutSettings.load();
    if (settings.saveToHealthApp) return;
    if (settings.appleHealthPreferenceAsked) return;
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final platform = HealthPlatformL10n(l10n);
    final enable = await showDialog<bool>(
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
    );

    if (!context.mounted) return;

    var saveToHealth = false;
    if (enable == true) {
      saveToHealth = await HealthWorkoutRecorder.requestWritePermission();
      if (!saveToHealth && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(platform.permissionRequiredSnack)),
        );
      }
    }

    final latest = await WorkoutSettings.load();
    await latest.setSaveToAppleHealth(saveToHealth);
    await latest.setAppleHealthPreferenceAsked(true);
  }
}
