import 'package:uuid/uuid.dart';

import '../models/exercise.dart';
import '../models/exercise_phase.dart';
import '../models/phase_config.dart';
import '../models/routine.dart';

const _uuid = Uuid();

Routine createRotatorCuffRoutine() {
  return Routine(
    id: 'rotator-cuff-seed',
    title: '회전근개 재활 루틴',
    description: '어깨 회전근개 강화 및 마름모근 스트레칭',
    exercises: [
      Exercise(
        id: _uuid.v4(),
        name: '팽귄 운동',
        instruction:
            '어깨에 수건을 끼고 겨드랑이에 고정한 뒤, 팔꿈치를 좌우로 움직입니다.',
        order: 0,
        prepare: const TimedPhase(durationSec: 5),
        phases: [
          ExercisePhase(
            id: _uuid.v4(),
            kind: ExercisePhaseKind.work,
            label: '팔을 벌리기',
            durationSec: 8,
            order: 0,
          ),
          ExercisePhase(
            id: _uuid.v4(),
            kind: ExercisePhaseKind.relax,
            label: '팔을 오므리기',
            durationSec: 8,
            order: 1,
          ),
        ],
        reps: 10,
        sets: 5,
      ),
      Exercise(
        id: _uuid.v4(),
        name: '천사 날개 운동',
        instruction: '벽에 등을 붙이고 팔꿈치를 위아래로 움직입니다.',
        order: 1,
        prepare: const TimedPhase(durationSec: 5),
        phases: [
          ExercisePhase(
            id: _uuid.v4(),
            kind: ExercisePhaseKind.work,
            label: '팔꿈치를 폈다 올리기',
            durationSec: 5,
            order: 0,
          ),
          ExercisePhase(
            id: _uuid.v4(),
            kind: ExercisePhaseKind.relax,
            label: '팔꿈치를 내리기',
            durationSec: 5,
            order: 1,
          ),
        ],
        reps: 5,
        sets: 5,
      ),
      Exercise(
        id: _uuid.v4(),
        name: '마름모근 스트레칭',
        instruction: '반대편 어깨를 손으로 잡고 당겨 스트레칭합니다.',
        order: 2,
        prepare: const TimedPhase(durationSec: 5),
        phases: [
          ExercisePhase(
            id: _uuid.v4(),
            kind: ExercisePhaseKind.work,
            label: '스트레칭',
            durationSec: 10,
            order: 0,
          ),
          ExercisePhase(
            id: _uuid.v4(),
            kind: ExercisePhaseKind.relax,
            label: '이완',
            durationSec: 5,
            order: 1,
          ),
        ],
        reps: 5,
        sets: 1,
      ),
    ],
  );
}
