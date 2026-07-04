import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

/// Platform-specific copy for Apple Health (iOS) vs Health Connect (Android).
class HealthPlatformL10n {
  HealthPlatformL10n(this.l10n);

  final AppLocalizations l10n;

  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  String get label =>
      isAndroid ? l10n.healthConnectLabel : l10n.healthAppleHealthLabel;

  String get infoTitle => isAndroid
      ? l10n.healthConnectInfoTitle
      : l10n.healthAppleHealthInfoTitle;

  String get saveDetail => isAndroid
      ? l10n.healthConnectSaveDetail
      : l10n.healthSaveToAppleHealthDetail;

  String get activityTypeDetail => isAndroid
      ? l10n.healthConnectActivityTypeDetail
      : l10n.healthActivityTypeDetail;

  String get activityTypeSection => isAndroid
      ? l10n.healthConnectInfoTitle
      : l10n.healthActivityTypeSection;

  String routineWillSaveDetail(String type) => isAndroid
      ? l10n.healthConnectRoutineWillSaveDetail(type)
      : l10n.healthRoutineWillSaveDetail(type);

  String workoutSavedSnack(String type) => isAndroid
      ? l10n.healthConnectWorkoutSavedSnack(type)
      : l10n.healthWorkoutSavedSnack(type);

  String get permissionRequiredSnack => isAndroid
      ? l10n.healthConnectPermissionRequiredSnack
      : l10n.healthPermissionRequiredSnack;

  String get firstWorkoutPromptTitle => isAndroid
      ? l10n.healthConnectFirstWorkoutPromptTitle
      : l10n.healthFirstWorkoutPromptTitle;

  String get firstWorkoutPromptBody => isAndroid
      ? l10n.healthConnectFirstWorkoutPromptBody
      : l10n.healthFirstWorkoutPromptBody;
}
