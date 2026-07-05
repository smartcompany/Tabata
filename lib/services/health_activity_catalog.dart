import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/health_activity_type.dart';
import '../models/health_connect_workout_types.dart';
import '../utils/health_platform_l10n.dart';

class HealthActivityOption {
  const HealthActivityOption({required this.id, required this.label});

  final String id;
  final String label;
}

/// 플랫폼별 Health 운동 유형 목록 (iOS: Apple Health curated, Android: HC 지원 전체).
abstract final class HealthActivityCatalog {
  static bool get usesHealthConnectList =>
      !kIsWeb && Platform.isAndroid;

  static List<HealthActivityOption> options(AppLocalizations l10n) {
    if (usesHealthConnectList) {
      return [
        for (final id in HealthConnectWorkoutTypes.sortedIds())
          HealthActivityOption(
            id: id,
            label: HealthConnectWorkoutTypes.displayLabel(id),
          ),
      ];
    }
    return [
      for (final type in RoutineHealthActivityType.values)
        HealthActivityOption(id: type.id, label: type.label(l10n)),
    ];
  }

  static String noneLabel(AppLocalizations l10n) =>
      HealthPlatformL10n(l10n).activityTypeNone;

  static String labelFor(AppLocalizations l10n, String id) {
    if (usesHealthConnectList) {
      final hc = HealthConnectWorkoutTypes.toWorkoutType(id);
      if (hc != null) {
        return HealthConnectWorkoutTypes.displayLabel(id);
      }
    }
    final ios = RoutineHealthActivityType.fromId(id);
    if (ios != null) return ios.label(l10n);
    return id;
  }

  static HealthWorkoutActivityType? toWorkoutType(String? id) {
    if (id == null || id.isEmpty) return null;
    if (usesHealthConnectList) {
      return HealthConnectWorkoutTypes.toWorkoutType(id);
    }
    return RoutineHealthActivityType.fromId(id)?.toHealthWorkoutType();
  }
}
