import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import 'health_workout_recorder.dart';
import 'workout_settings.dart';

/// Guides the user through Apple Health write permission in context.
abstract final class HealthPermissionFlow {
  /// Asks once before the first workout on iOS, then continues either way.
  static Future<void> maybePromptOnFirstWorkoutStart(BuildContext context) async {
    if (!HealthWorkoutRecorder.isSupported) return;

    final settings = await WorkoutSettings.load();
    if (settings.appleHealthPreferenceAsked) return;
    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final enable = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.healthFirstWorkoutPromptTitle),
        content: Text(l10n.healthFirstWorkoutPromptBody),
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
          SnackBar(content: Text(l10n.healthPermissionRequiredSnack)),
        );
      }
    }

    final latest = await WorkoutSettings.load();
    await latest.setSaveToAppleHealth(saveToHealth);
    await latest.setAppleHealthPreferenceAsked(true);
  }
}
