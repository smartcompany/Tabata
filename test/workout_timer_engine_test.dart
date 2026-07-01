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

  test('navigation moves by work/relax unit in count mode', () {
    final engine = WorkoutTimerEngine(
      Routine(
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
                countReps: 3,
                secondsPerRep: 2,
              ),
              ExercisePhase(
                id: 'p2',
                kind: ExercisePhaseKind.relax,
                label: '휴식',
                durationSec: 10,
                order: 1,
                timingMode: PhaseTimingMode.count,
                countReps: 2,
                secondsPerRep: 3,
              ),
            ],
            reps: 1,
            sets: 1,
            order: 0,
          ),
        ],
      ),
      labels: const WorkoutTimerLabels(
        prepare: '준비',
        completedMessage: '완료',
      ),
    );

    expect(engine.snapshot.phase.kind, WorkoutPhaseKind.work);
    expect(engine.snapshot.phase.countRepNumber, 1);
    expect(engine.nextPhase?.kind, WorkoutPhaseKind.relax);

    engine.skipPhase();
    expect(engine.snapshot.phase.countRepNumber, 2);

    engine.goToNextPhase();
    expect(engine.snapshot.phase.kind, WorkoutPhaseKind.relax);
    expect(engine.snapshot.phase.countRepNumber, 1);

    engine.goToPreviousPhase();
    expect(engine.snapshot.phase.kind, WorkoutPhaseKind.work);
    expect(engine.snapshot.phase.countRepNumber, 1);
    expect(engine.snapshot.remainingSec, 2);

    engine.goToNextPhase();
    engine.goToNextPhase();
    expect(engine.snapshot.isCompleted, isTrue);
  });

  test('goToPreviousPhase from mid-count rep only jumps to previous unit', () {
    final engine = WorkoutTimerEngine(
      _countRoutine(),
      labels: const WorkoutTimerLabels(
        prepare: '준비',
        completedMessage: '완료',
      ),
    );

    expect(engine.canGoToPreviousPhase, isFalse);
    engine.skipPhase();
    expect(engine.snapshot.phase.countRepNumber, 2);
    expect(engine.canGoToPreviousPhase, isFalse);

    engine.goToPreviousPhase();
    expect(engine.snapshot.phase.countRepNumber, 2);
  });

  test('exercise navigation jumps to first phase of adjacent exercise', () {
    final engine = WorkoutTimerEngine(
      Routine(
        id: 'r1',
        title: '테스트',
        description: '',
        exercises: [
          Exercise(
            id: 'e1',
            name: '목 좌우 기울이기',
            instruction: '',
            prepare: const TimedPhase(durationSec: 5),
            phases: [
              ExercisePhase(
                id: 'p1',
                kind: ExercisePhaseKind.work,
                label: '기울이기',
                durationSec: 30,
                order: 0,
              ),
            ],
            reps: 1,
            sets: 1,
            order: 0,
          ),
          Exercise(
            id: 'e2',
            name: '어깨 돌리기',
            instruction: '',
            prepare: const TimedPhase(durationSec: 0),
            phases: [
              ExercisePhase(
                id: 'p2',
                kind: ExercisePhaseKind.work,
                label: '돌리기',
                durationSec: 20,
                order: 0,
              ),
            ],
            reps: 1,
            sets: 1,
            order: 1,
          ),
        ],
      ),
      labels: const WorkoutTimerLabels(
        prepare: '준비',
        completedMessage: '완료',
      ),
    );

    expect(engine.snapshot.exerciseName, '목 좌우 기울이기');
    expect(engine.snapshot.exerciseIndex, 1);
    expect(engine.canGoToPreviousExercise, isFalse);
    expect(engine.canGoToNextExercise, isTrue);

    engine.goToNextExercise();
    expect(engine.snapshot.exerciseName, '어깨 돌리기');
    expect(engine.snapshot.exerciseIndex, 2);
    expect(engine.snapshot.phase.label, '돌리기');
    expect(engine.canGoToPreviousExercise, isTrue);
    expect(engine.canGoToNextExercise, isFalse);

    engine.goToPreviousExercise();
    expect(engine.snapshot.exerciseName, '목 좌우 기울이기');
    expect(engine.snapshot.exerciseIndex, 1);
    expect(engine.snapshot.phase.kind, WorkoutPhaseKind.prepare);
    expect(engine.snapshot.remainingSec, 5);
  });

  test('announce hold prevents timer from starting until released', () {
    final engine = WorkoutTimerEngine(
      _countRoutine(),
      labels: const WorkoutTimerLabels(
        prepare: '준비',
        completedMessage: '완료',
      ),
    );

    expect(engine.isAnnounceHold, isFalse);
    engine.holdForAnnounce();
    expect(engine.isAnnounceHold, isTrue);
    expect(engine.snapshot.isPaused, isFalse);

    engine.start();
    expect(engine.snapshot.remainingSec, 2);

    engine.releaseAnnounceHold();
    expect(engine.isAnnounceHold, isFalse);
  });
}
