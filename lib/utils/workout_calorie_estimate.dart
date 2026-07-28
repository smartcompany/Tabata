import 'dart:math' as math;

/// Rough calorie estimate using MET × body weight × hours.
///
/// Uses a default adult body weight when the user has not set one.
/// Values are estimates for display / sharing, not medical-grade.
int estimateWorkoutCaloriesKcal({
  required int durationSec,
  String? healthActivityType,
  double bodyWeightKg = 70,
}) {
  if (durationSec <= 0) return 0;
  final met = _metForActivity(healthActivityType);
  final hours = durationSec / 3600.0;
  return math.max(1, (met * bodyWeightKg * hours).round());
}

double _metForActivity(String? activityType) {
  if (activityType == null || activityType.isEmpty) return 5.0;
  final id = activityType.toLowerCase();

  if (id.contains('high_intensity') ||
      id.contains('hiit') ||
      id == 'high_intensity_interval_training') {
    return 8.0;
  }
  if (id.contains('functional_strength') ||
      id == 'functional_strength_training') {
    return 6.0;
  }
  if (id.contains('traditional_strength') ||
      id.contains('strength') ||
      id.contains('weight')) {
    return 5.0;
  }
  if (id.contains('flexibility') ||
      id.contains('yoga') ||
      id.contains('stretch') ||
      id.contains('pilates')) {
    return 2.8;
  }
  if (id.contains('run') || id.contains('jog')) return 7.5;
  if (id.contains('walk')) return 3.5;
  if (id.contains('cycle') || id.contains('bike') || id.contains('cycling')) {
    return 6.8;
  }
  if (id.contains('swim')) return 7.0;
  if (id.contains('dance')) return 5.5;
  if (id.contains('row')) return 6.5;
  if (id.contains('other')) return 4.5;
  return 5.0;
}
