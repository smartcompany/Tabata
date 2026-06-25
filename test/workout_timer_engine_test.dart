import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/engine/workout_timer_engine.dart';
import 'package:tabata_timer/engine/workout_timer_labels.dart';
import 'package:tabata_timer/models/exercise.dart';
import 'package:tabata_timer/models/exercise_phase.dart';
import 'package:tabata_timer/models/phase_config.dart';
import 'package:tabata_timer/models/routine.dart';

Routine _countRoutine({
  int countReps = 3,
  int secondsPerRep = 2,
  CountOrder countOrder = CountOrder.ascending,
}) {
  return Routine(
    id: 'r1',
    title: '테스트',
    description: '',
    exercises: [
      Exercise(
        id: 'e1',
        name: '스쿼트',
        instruction: '',
        prepare: const TimedPhase(durationSec: 0),
        phases: [
          ExercisePhase(
            id: 'p1',
            kind: ExercisePhaseKind.work,
            label: '스쿼트',
            durationSec: 20,
            order: 0,
            timingMode: PhaseTimingMode.count,
            countReps: countReps,
            secondsPerRep: secondsPerRep,
            countOrder: countOrder,
          ),
        ],
        reps: 1,
        sets: 1,
        order: 0,
      ),
    ],
  );
}

void main() {
  test('count mode expands into per-rep queue items', () {
    final engine = WorkoutTimerEngine(
      _countRoutine(),
      labels: const WorkoutTimerLabels(
        prepare: '준비',
        completedMessage: '완료',
      ),
    );

    expect(engine.snapshot.phase.isCountRep, isTrue);
    expect(engine.snapshot.phase.countRepNumber, 1);
    expect(engine.snapshot.phase.totalCountReps, 3);
    expect(engine.snapshot.phase.durationSec, 2);

    engine.start();
    engine.skipPhase();
    expect(engine.snapshot.phase.countRepNumber, 2);

    engine.skipPhase();
    expect(engine.snapshot.phase.countRepNumber, 3);

    engine.skipPhase();
    expect(engine.snapshot.isCompleted, isTrue);
  });

  test('descending count order queues high to low rep numbers', () {
    final engine = WorkoutTimerEngine(
      _countRoutine(countOrder: CountOrder.descending),
      labels: const WorkoutTimerLabels(
        prepare: '준비',
        completedMessage: '완료',
      ),
    );

    expect(engine.snapshot.phase.countRepNumber, 3);

    engine.skipPhase();
    expect(engine.snapshot.phase.countRepNumber, 2);

    engine.skipPhase();
    expect(engine.snapshot.phase.countRepNumber, 1);
  });
}
