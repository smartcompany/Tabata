import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';
import 'package:tabata_timer/l10n/health_connect_workout_type_labels.dart';

import '../models/health_activity_type.dart';
import '../models/health_connect_workout_types.dart';
import '../utils/health_platform_l10n.dart';

class HealthActivityOption {
  const HealthActivityOption({required this.id, required this.label});

  final String id;
  final String label;
}

enum HealthActivityMenuEntryKind { option, sectionHeader, divider }

class HealthActivityMenuEntry {
  const HealthActivityMenuEntry.option({
    required this.id,
    required this.label,
  }) : kind = HealthActivityMenuEntryKind.option;

  const HealthActivityMenuEntry.sectionHeader(this.label)
      : id = null,
        kind = HealthActivityMenuEntryKind.sectionHeader;

  const HealthActivityMenuEntry.divider()
      : id = null,
        label = '',
        kind = HealthActivityMenuEntryKind.divider;

  final String? id;
  final String label;
  final HealthActivityMenuEntryKind kind;
}

/// 플랫폼별 Health 운동 유형 목록 (iOS: Apple Health curated, Android: HC 지원 전체).
abstract final class HealthActivityCatalog {
  static bool get usesHealthConnectList => !kIsWeb && Platform.isAndroid;

  /// Canonical app ids (AI / iOS picker) → Health Connect menu ids.
  static const Map<String, String> iosToHealthConnectIds = {
    'high_intensity_interval_training': 'HIGH_INTENSITY_INTERVAL_TRAINING',
    'functional_strength_training': 'STRENGTH_TRAINING',
    'traditional_strength_training': 'WEIGHTLIFTING',
    'flexibility': 'YOGA',
    'other': 'OTHER',
  };

  static const Map<String, String> healthConnectToIosIds = {
    'HIGH_INTENSITY_INTERVAL_TRAINING': 'high_intensity_interval_training',
    'STRENGTH_TRAINING': 'functional_strength_training',
    'CALISTHENICS': 'functional_strength_training',
    'WEIGHTLIFTING': 'traditional_strength_training',
    'YOGA': 'flexibility',
    'PILATES': 'flexibility',
    'OTHER': 'other',
  };

  /// Id to use in the platform picker menu for a stored routine value.
  static String? menuIdFor(String? id) {
    if (id == null || id.isEmpty) return null;
    if (usesHealthConnectList) {
      if (HealthConnectWorkoutTypes.toWorkoutType(id) != null) return id;
      final mapped = iosToHealthConnectIds[id];
      if (mapped != null &&
          HealthConnectWorkoutTypes.toWorkoutType(mapped) != null) {
        return mapped;
      }
      return null;
    }
    if (RoutineHealthActivityType.fromId(id) != null) return id;
    return healthConnectToIosIds[id];
  }

  static List<HealthActivityOption> options(AppLocalizations l10n) {
    if (usesHealthConnectList) {
      return [
        for (final entry in menuEntries(l10n))
          if (entry.kind == HealthActivityMenuEntryKind.option)
            HealthActivityOption(id: entry.id!, label: entry.label),
      ];
    }
    return [
      for (final type in RoutineHealthActivityType.values)
        HealthActivityOption(id: type.id, label: type.label(l10n)),
    ];
  }

  static List<HealthActivityMenuEntry> menuEntries(AppLocalizations l10n) {
    if (!usesHealthConnectList) {
      return [
        for (final type in RoutineHealthActivityType.values)
          HealthActivityMenuEntry.option(
            id: type.id,
            label: type.label(l10n),
          ),
      ];
    }

    String label(String id) => HealthConnectWorkoutTypeLabels.label(l10n, id);

    final entries = <HealthActivityMenuEntry>[
      HealthActivityMenuEntry.sectionHeader(
        l10n.healthConnectWorkoutTypesRecommended,
      ),
      for (final id in HealthConnectWorkoutTypes.priorityIds)
        HealthActivityMenuEntry.option(id: id, label: label(id)),
      const HealthActivityMenuEntry.divider(),
      for (final id in HealthConnectWorkoutTypes.otherIds(
        compare: (a, b) => label(a).compareTo(label(b)),
      ))
        HealthActivityMenuEntry.option(id: id, label: label(id)),
    ];
    return entries;
  }

  static String noneLabel(AppLocalizations l10n) =>
      HealthPlatformL10n(l10n).activityTypeNone;

  static String labelFor(AppLocalizations l10n, String id) {
    final menuId = menuIdFor(id) ?? id;
    if (usesHealthConnectList) {
      final hc = HealthConnectWorkoutTypes.toWorkoutType(menuId);
      if (hc != null) {
        return HealthConnectWorkoutTypeLabels.label(l10n, menuId);
      }
    }
    final iosId = menuIdFor(id) ?? id;
    final ios = RoutineHealthActivityType.fromId(iosId);
    if (ios != null) return ios.label(l10n);
    final fallbackIos = RoutineHealthActivityType.fromId(id);
    if (fallbackIos != null) return fallbackIos.label(l10n);
    return id;
  }

  static HealthWorkoutActivityType? toWorkoutType(String? id) {
    if (id == null || id.isEmpty) return null;
    final directHc = HealthConnectWorkoutTypes.toWorkoutType(id);
    if (directHc != null) return directHc;
    final mappedHc = iosToHealthConnectIds[id];
    if (mappedHc != null) {
      final fromMapped = HealthConnectWorkoutTypes.toWorkoutType(mappedHc);
      if (fromMapped != null) return fromMapped;
    }
    return RoutineHealthActivityType.fromId(id)?.toHealthWorkoutType() ??
        RoutineHealthActivityType.fromId(healthConnectToIosIds[id])
            ?.toHealthWorkoutType();
  }
}
