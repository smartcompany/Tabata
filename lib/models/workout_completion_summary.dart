import '../models/routine.dart';
import '../utils/workout_calorie_estimate.dart';

class WorkoutCompletionSummary {
  const WorkoutCompletionSummary({
    required this.routineTitle,
    required this.durationSec,
    required this.exerciseCount,
    required this.exerciseNames,
    required this.estimatedCaloriesKcal,
    this.avgHeartRateBpm = 0,
    this.maxHeartRateBpm = 0,
    this.healthActivityType,
  });

  final String routineTitle;
  final int durationSec;
  final int exerciseCount;
  final List<String> exerciseNames;
  final int estimatedCaloriesKcal;
  final double avgHeartRateBpm;
  final double maxHeartRateBpm;
  final String? healthActivityType;

  bool get hasHeartRate => avgHeartRateBpm > 0 || maxHeartRateBpm > 0;

  factory WorkoutCompletionSummary.fromRoutine({
    required Routine routine,
    required int durationSec,
    double avgHeartRateBpm = 0,
    double maxHeartRateBpm = 0,
  }) {
    final names = routine.orderedExercises
        .map((e) => e.name.trim())
        .where((n) => n.isNotEmpty)
        .toList();
    return WorkoutCompletionSummary(
      routineTitle: routine.title.trim().isEmpty ? 'Tabata' : routine.title.trim(),
      durationSec: durationSec,
      exerciseCount: routine.exercises.length,
      exerciseNames: names,
      estimatedCaloriesKcal: estimateWorkoutCaloriesKcal(
        durationSec: durationSec,
        healthActivityType: routine.healthActivityType,
      ),
      avgHeartRateBpm: avgHeartRateBpm,
      maxHeartRateBpm: maxHeartRateBpm,
      healthActivityType: routine.healthActivityType,
    );
  }

  /// Sample data for debug preview.
  factory WorkoutCompletionSummary.debugSample() {
    return const WorkoutCompletionSummary(
      routineTitle: '상체 워밍업',
      durationSec: 13 * 60 + 24,
      exerciseCount: 3,
      exerciseNames: ['암서클', '어깨 스트레칭', '푸시업'],
      estimatedCaloriesKcal: 96,
      avgHeartRateBpm: 118,
      maxHeartRateBpm: 142,
      healthActivityType: 'functional_strength_training',
    );
  }
}
