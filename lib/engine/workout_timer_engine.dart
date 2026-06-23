import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../models/exercise_phase.dart';
import '../models/routine.dart';
import 'workout_timer_labels.dart';

enum WorkoutPhaseKind { prepare, work, relax, completed }

class WorkoutPhase {
  const WorkoutPhase({
    required this.kind,
    required this.label,
    required this.durationSec,
  });

  final WorkoutPhaseKind kind;
  final String label;
  final int durationSec;
}

class WorkoutTimerSnapshot {
  const WorkoutTimerSnapshot({
    required this.phase,
    required this.remainingSec,
    required this.exerciseIndex,
    required this.setIndex,
    required this.repIndex,
    required this.exerciseName,
    required this.routineTitle,
    required this.totalExercises,
    required this.totalSets,
    required this.totalReps,
    required this.isPaused,
    required this.isCompleted,
  });

  final WorkoutPhase phase;
  final int remainingSec;
  final int exerciseIndex;
  final int setIndex;
  final int repIndex;
  final String exerciseName;
  final String routineTitle;
  final int totalExercises;
  final int totalSets;
  final int totalReps;
  final bool isPaused;
  final bool isCompleted;

  double get progress {
    if (phase.durationSec == 0) return 1;
    return 1 - (remainingSec / phase.durationSec);
  }
}

class WorkoutTimerEngine extends ChangeNotifier {
  WorkoutTimerEngine(this.routine, {required WorkoutTimerLabels labels})
      : _labels = labels {
    _buildPhaseQueue();
    _snapshot = _createSnapshot();
  }

  final Routine routine;
  final WorkoutTimerLabels _labels;
  late final List<_QueuedPhase> _phases;
  int _phaseIndex = 0;
  int _remainingSec = 0;
  bool _isPaused = false;
  Timer? _timer;
  late WorkoutTimerSnapshot _snapshot;

  WorkoutTimerSnapshot get snapshot => _snapshot;

  List<Exercise> get _exercises => routine.orderedExercises;

  void start() {
    if (_snapshot.isCompleted) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    _isPaused = true;
    _timer?.cancel();
    _refreshSnapshot();
  }

  void resume() {
    if (_snapshot.isCompleted) return;
    _isPaused = false;
    start();
  }

  void skipPhase() {
    if (_snapshot.isCompleted) return;
    _advancePhase();
  }

  void skipExercise() {
    if (_snapshot.isCompleted) return;
    final current = _phases[_phaseIndex].exerciseIndex;
    while (_phaseIndex < _phases.length &&
        _phases[_phaseIndex].exerciseIndex == current) {
      _phaseIndex++;
    }
    _loadCurrentPhase();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (_remainingSec > 1) {
      _remainingSec--;
      _refreshSnapshot();
      return;
    }
    _advancePhase();
  }

  void _advancePhase() {
    _phaseIndex++;
    if (_phaseIndex >= _phases.length) {
      _timer?.cancel();
      _remainingSec = 0;
      _refreshSnapshot(completed: true);
      return;
    }
    _loadCurrentPhase();
  }

  void _loadCurrentPhase() {
    final current = _phases[_phaseIndex];
    _remainingSec = current.phase.durationSec;
    if (_remainingSec == 0) {
      _advancePhase();
      return;
    }
    _refreshSnapshot();
  }

  void _buildPhaseQueue() {
    _phases = [];
    for (var ei = 0; ei < _exercises.length; ei++) {
      final exercise = _exercises[ei];
      var prepareUsed = false;
      for (var set = 1; set <= exercise.sets; set++) {
        for (var rep = 1; rep <= exercise.reps; rep++) {
          final isFirstRep = set == 1 && rep == 1;
          if (isFirstRep &&
              !prepareUsed &&
              exercise.prepare.durationSec > 0) {
            _phases.add(
              _QueuedPhase(
                exerciseIndex: ei,
                setIndex: set,
                repIndex: rep,
                phase: WorkoutPhase(
                  kind: WorkoutPhaseKind.prepare,
                  label: _labels.prepare,
                  durationSec: exercise.prepare.durationSec,
                ),
              ),
            );
            prepareUsed = true;
          }
          for (final step in exercise.orderedPhases) {
            if (step.durationSec <= 0) continue;
            _phases.add(
              _QueuedPhase(
                exerciseIndex: ei,
                setIndex: set,
                repIndex: rep,
                phase: WorkoutPhase(
                  kind: step.kind == ExercisePhaseKind.work
                      ? WorkoutPhaseKind.work
                      : WorkoutPhaseKind.relax,
                  label: step.label,
                  durationSec: step.durationSec,
                ),
              ),
            );
          }
        }
      }
    }
    if (_phases.isNotEmpty) {
      _remainingSec = _phases.first.phase.durationSec;
    }
  }

  WorkoutTimerSnapshot _createSnapshot({bool completed = false}) {
    if (completed || _phases.isEmpty || _phaseIndex >= _phases.length) {
      return WorkoutTimerSnapshot(
        phase: WorkoutPhase(
          kind: WorkoutPhaseKind.completed,
          label: _labels.completedMessage,
          durationSec: 0,
        ),
        remainingSec: 0,
        exerciseIndex: _exercises.length,
        setIndex: 0,
        repIndex: 0,
        exerciseName: '',
        routineTitle: routine.title,
        totalExercises: _exercises.length,
        totalSets: 0,
        totalReps: 0,
        isPaused: _isPaused,
        isCompleted: true,
      );
    }

    final current = _phases[_phaseIndex];
    final exercise = _exercises[current.exerciseIndex];
    return WorkoutTimerSnapshot(
      phase: current.phase,
      remainingSec: _remainingSec,
      exerciseIndex: current.exerciseIndex + 1,
      setIndex: current.setIndex,
      repIndex: current.repIndex,
      exerciseName: exercise.name,
      routineTitle: routine.title,
      totalExercises: _exercises.length,
      totalSets: exercise.sets,
      totalReps: exercise.reps,
      isPaused: _isPaused,
      isCompleted: false,
    );
  }

  void _refreshSnapshot({bool completed = false}) {
    _snapshot = _createSnapshot(completed: completed);
    notifyListeners();
  }
}

class _QueuedPhase {
  const _QueuedPhase({
    required this.exerciseIndex,
    required this.setIndex,
    required this.repIndex,
    required this.phase,
  });

  final int exerciseIndex;
  final int setIndex;
  final int repIndex;
  final WorkoutPhase phase;
}
