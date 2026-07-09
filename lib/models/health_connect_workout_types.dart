import 'package:health/health.dart';

/// Health Connect [ExerciseSessionRecord] types supported by `health` plugin
/// (`HealthConstants.workoutTypeMap` on Android).
abstract final class HealthConnectWorkoutTypes {
  static const supportedIds = [
    'AMERICAN_FOOTBALL',
    'AUSTRALIAN_FOOTBALL',
    'BADMINTON',
    'BASEBALL',
    'BASKETBALL',
    'BIKING',
    'BOXING',
    'CALISTHENICS',
    'CARDIO_DANCE',
    'CRICKET',
    'CROSS_COUNTRY_SKIING',
    'DANCING',
    'DOWNHILL_SKIING',
    'ELLIPTICAL',
    'FENCING',
    'FRISBEE_DISC',
    'GOLF',
    'GUIDED_BREATHING',
    'GYMNASTICS',
    'HANDBALL',
    'HIGH_INTENSITY_INTERVAL_TRAINING',
    'HIKING',
    'ICE_SKATING',
    'MARTIAL_ARTS',
    'PARAGLIDING',
    'PILATES',
    'RACQUETBALL',
    'ROCK_CLIMBING',
    'ROWING',
    'ROWING_MACHINE',
    'RUGBY',
    'RUNNING',
    'RUNNING_TREADMILL',
    'SAILING',
    'SCUBA_DIVING',
    'SKATING',
    'SKIING',
    'SNOWBOARDING',
    'SNOWSHOEING',
    'SOCIAL_DANCE',
    'SOFTBALL',
    'SQUASH',
    'STAIR_CLIMBING',
    'STAIR_CLIMBING_MACHINE',
    'STRENGTH_TRAINING',
    'SURFING',
    'SWIMMING_OPEN_WATER',
    'SWIMMING_POOL',
    'TABLE_TENNIS',
    'TENNIS',
    'VOLLEYBALL',
    'WALKING',
    'WATER_POLO',
    'WEIGHTLIFTING',
    'WHEELCHAIR',
    'WHEELCHAIR_RUN_PACE',
    'WHEELCHAIR_WALK_PACE',
    'YOGA',
    'OTHER',
  ];

  /// Tabata에 자주 쓰는 유형을 목록 상단에 둡니다.
  static const priorityIds = [
    'HIGH_INTENSITY_INTERVAL_TRAINING',
    'STRENGTH_TRAINING',
    'WEIGHTLIFTING',
    'CALISTHENICS',
    'OTHER',
  ];

  static HealthWorkoutActivityType? toWorkoutType(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final type in HealthWorkoutActivityType.values) {
      if (type.name == id) return type;
    }
    return null;
  }

  static List<String> otherIds({
    required int Function(String a, String b) compare,
  }) {
    final prioritySet = priorityIds.toSet();
    final others =
        supportedIds.where((id) => !prioritySet.contains(id)).toList();
    others.sort(compare);
    return others;
  }

  static List<String> sortedIds() {
    final priority = {
      for (var i = 0; i < priorityIds.length; i++) priorityIds[i]: i,
    };
    final ids = List<String>.from(supportedIds);
    ids.sort((a, b) {
      final pa = priority[a];
      final pb = priority[b];
      if (pa != null || pb != null) {
        if (pa == null) return 1;
        if (pb == null) return -1;
        if (pa != pb) return pa.compareTo(pb);
      }
      return displayLabel(a).compareTo(displayLabel(b));
    });
    return ids;
  }

  static String displayLabel(String id) {
    return id
        .split('_')
        .map((part) {
          if (part.isEmpty) return part;
          if (part == 'HIIT') return 'HIIT';
          return part[0].toUpperCase() + part.substring(1).toLowerCase();
        })
        .join(' ')
        .replaceAll('Hiit', 'HIIT');
  }
}
