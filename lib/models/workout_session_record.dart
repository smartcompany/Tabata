class WorkoutSessionRecord {
  const WorkoutSessionRecord({
    required this.id,
    required this.routineId,
    required this.routineTitle,
    required this.startedAt,
    required this.endedAt,
    required this.durationSec,
    required this.exerciseCount,
    this.healthActivityType,
    this.healthSynced = false,
  });

  final String id;
  final String routineId;
  final String routineTitle;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSec;
  final int exerciseCount;
  final String? healthActivityType;
  final bool healthSynced;

  Map<String, dynamic> toJson() => {
        'id': id,
        'routineId': routineId,
        'routineTitle': routineTitle,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'durationSec': durationSec,
        'exerciseCount': exerciseCount,
        if (healthActivityType != null) 'healthActivityType': healthActivityType,
        'healthSynced': healthSynced,
      };

  factory WorkoutSessionRecord.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionRecord(
      id: json['id'] as String,
      routineId: json['routineId'] as String,
      routineTitle: json['routineTitle'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      durationSec: (json['durationSec'] as num).toInt(),
      exerciseCount: (json['exerciseCount'] as num).toInt(),
      healthActivityType: json['healthActivityType'] as String?,
      healthSynced: json['healthSynced'] as bool? ?? false,
    );
  }

  WorkoutSessionRecord copyWith({bool? healthSynced}) {
    return WorkoutSessionRecord(
      id: id,
      routineId: routineId,
      routineTitle: routineTitle,
      startedAt: startedAt,
      endedAt: endedAt,
      durationSec: durationSec,
      exerciseCount: exerciseCount,
      healthActivityType: healthActivityType,
      healthSynced: healthSynced ?? this.healthSynced,
    );
  }

  /// Picks the latest session and merges [healthSynced].
  static WorkoutSessionRecord merge(
    WorkoutSessionRecord a,
    WorkoutSessionRecord b,
  ) {
    final primary = a.endedAt.isAfter(b.endedAt) ? a : b;
    final other = identical(primary, a) ? b : a;
    return primary.copyWith(
      healthSynced: primary.healthSynced || other.healthSynced,
    );
  }
}

class WorkoutDailyStats {
  const WorkoutDailyStats({
    required this.day,
    required this.sessionCount,
    required this.totalDurationSec,
  });

  final int day;
  final int sessionCount;
  final int totalDurationSec;
}
