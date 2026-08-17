import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/models/exercise_phase.dart';

void main() {
  test('count sequence is always high to low', () {
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
    expect(phase.countRepSequence, [3, 2, 1]);
  });

  test('stored ascending countOrder still runs descending', () {
    const phase = ExercisePhase(
      id: 'p1',
      kind: ExercisePhaseKind.work,
      label: '스쿼트',
      durationSec: 5,
      order: 0,
      timingMode: PhaseTimingMode.count,
      countReps: 3,
      secondsPerRep: 5,
      countOrder: CountOrder.ascending,
    );
    expect(phase.countRepSequence, [3, 2, 1]);
  });

  test('relax count mode converts to duration keeping total time', () {
    const phase = ExercisePhase(
      id: 'p1',
      kind: ExercisePhaseKind.relax,
      label: '휴식',
      durationSec: 5,
      order: 0,
      timingMode: PhaseTimingMode.count,
      countReps: 10,
      secondsPerRep: 8,
    );
    final converted = phase.withRelaxForcedToDuration();
    expect(converted.timingMode, PhaseTimingMode.duration);
    expect(converted.durationSec, 80);
    expect(converted.isCountMode, isFalse);
  });
}
