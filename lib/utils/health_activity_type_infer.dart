import '../models/exercise_phase.dart';
import '../models/health_activity_type.dart';
import '../models/routine.dart';

/// Picks a health-app workout type from routine content when AI/server omit one.
String inferHealthActivityType(Routine routine) {
  final text = [
    routine.title,
    routine.description,
    for (final exercise in routine.exercises) ...[
      exercise.name,
      exercise.instruction,
      for (final phase in exercise.phases) phase.label,
    ],
  ].join(' ').toLowerCase();

  if (_matches(text, const [
    'yoga',
    'pilates',
    'stretch',
    '스트레칭',
    '유연',
    '가동성',
    'flexibility',
    '필라테스',
  ])) {
    return RoutineHealthActivityType.flexibility.id;
  }

  if (_matches(text, const [
    'dumbbell',
    'barbell',
    'kettlebell',
    '바벨',
    '웨이트',
    '헬스장',
    'weightlifting',
    'weight lift',
  ])) {
    return RoutineHealthActivityType.traditionalStrengthTraining.id;
  }

  if (_looksLikeInterval(routine, text)) {
    return RoutineHealthActivityType.highIntensityIntervalTraining.id;
  }

  return RoutineHealthActivityType.functionalStrengthTraining.id;
}

bool _matches(String text, List<String> needles) {
  for (final needle in needles) {
    if (text.contains(needle.toLowerCase())) return true;
  }
  return false;
}

bool _looksLikeInterval(Routine routine, String text) {
  if (_matches(text, const [
    'tabata',
    'hiit',
    '고강도',
    '인터벌',
    'interval',
    '서킷',
    'circuit',
  ])) {
    return true;
  }

  var intervalish = 0;
  var total = 0;
  for (final exercise in routine.exercises) {
    if (exercise.phases.length < 2) continue;
    total += 1;
    ExercisePhase? work;
    ExercisePhase? relax;
    for (final phase in exercise.phases) {
      work ??= phase.kind == ExercisePhaseKind.work ? phase : null;
      relax ??= phase.kind == ExercisePhaseKind.relax ? phase : null;
    }
    if (work == null || relax == null) continue;
    if (work.timingMode == PhaseTimingMode.count) continue;
    if (work.durationSec > 0 &&
        work.durationSec <= 45 &&
        relax.durationSec > 0 &&
        relax.durationSec <= 30) {
      intervalish += 1;
    }
  }
  return total > 0 && intervalish / total >= 0.5;
}
