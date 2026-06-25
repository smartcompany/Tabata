import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/models/exercise_phase.dart';

void main() {
  test('ascending count sequence', () {
    const phase = ExercisePhase(
      id: 'p1',
      kind: ExercisePhaseKind.work,
      label: '스쿼트',
      durationSec: 5,
      order: 0,
      timingMode: PhaseTimingMode.count,
      countReps: 3,
      secondsPerRep: 5,
    );
    expect(phase.countRepSequence, [1, 2, 3]);
  });

  test('descending count sequence', () {
    const phase = ExercisePhase(
      id: 'p1',
      kind: ExercisePhaseKind.work,
      label: '스쿼트',
      durationSec: 5,
      order: 0,
      timingMode: PhaseTimingMode.count,
      countReps: 3,
      secondsPerRep: 5,
      countOrder: CountOrder.descending,
    );
    expect(phase.countRepSequence, [3, 2, 1]);
  });
}
