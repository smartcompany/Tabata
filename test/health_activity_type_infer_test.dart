import 'package:flutter_test/flutter_test.dart';
import 'package:tabata_timer/models/exercise.dart';
import 'package:tabata_timer/models/exercise_phase.dart';
import 'package:tabata_timer/models/phase_config.dart';
import 'package:tabata_timer/models/routine.dart';
import 'package:tabata_timer/utils/health_activity_type_infer.dart';

Exercise _exercise({
  required String name,
  required List<ExercisePhase> phases,
}) {
  return Exercise(
    id: 'e1',
    name: name,
    instruction: '',
    order: 0,
    prepare: const TimedPhase(durationSec: 10),
    phases: phases,
    reps: 8,
    sets: 1,
  );
}

ExercisePhase _phase({
  required ExercisePhaseKind kind,
  required int durationSec,
  PhaseTimingMode timingMode = PhaseTimingMode.duration,
}) {
  return ExercisePhase(
    id: 'p-${kind.name}',
    kind: kind,
    label: kind.name,
    durationSec: durationSec,
    order: kind == ExercisePhaseKind.work ? 0 : 1,
    timingMode: timingMode,
  );
}

void main() {
  test('infers HIIT for tabata-style title', () {
    final routine = Routine(
      id: 'r1',
      title: '클래식 타바타',
      description: '',
      exercises: [
        _exercise(
          name: '점프 스쿼트',
          phases: [
            _phase(kind: ExercisePhaseKind.work, durationSec: 20),
            _phase(kind: ExercisePhaseKind.relax, durationSec: 10),
          ],
        ),
      ],
    );
    expect(
      inferHealthActivityType(routine),
      'high_intensity_interval_training',
    );
  });

  test('infers flexibility for yoga routines', () {
    final routine = Routine(
      id: 'r2',
      title: '모닝 요가',
      description: '스트레칭 중심',
      exercises: [
        _exercise(
          name: '다운독',
          phases: [
            _phase(kind: ExercisePhaseKind.work, durationSec: 60),
          ],
        ),
      ],
    );
    expect(inferHealthActivityType(routine), 'flexibility');
  });

  test('defaults to functional strength', () {
    final routine = Routine(
      id: 'r3',
      title: '어깨 재활',
      description: '맨몸 기능성',
      exercises: [
        _exercise(
          name: '팽귄 운동',
          phases: [
            _phase(
              kind: ExercisePhaseKind.work,
              durationSec: 3,
              timingMode: PhaseTimingMode.count,
            ),
          ],
        ),
      ],
    );
    expect(
      inferHealthActivityType(routine),
      'functional_strength_training',
    );
  });
}
