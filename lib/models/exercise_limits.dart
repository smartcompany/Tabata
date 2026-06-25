/// PRD v1.1에서 정의한 최소 허용값. UX용 임의 기본값이 아님.
abstract final class ExerciseLimits {
  static const int minWorkRelaxDurationSec = 1;
  static const int minReps = 1;
  static const int minSets = 1;
  static const int minCountReps = 1;
  static const int maxCountReps = 999;
  static const int minSecondsPerRep = 1;
  static const int maxSecondsPerRep = 120;
  static const int defaultCountReps = 10;
  static const int defaultSecondsPerRep = 5;
}
