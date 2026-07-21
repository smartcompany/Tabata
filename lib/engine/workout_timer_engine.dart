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
    this.countRepNumber = 0,
    this.totalCountReps = 0,
    this.phaseGroupKey = '',
  });

  final WorkoutPhaseKind kind;
  final String label;
  final int durationSec;
  final int countRepNumber;
  final int totalCountReps;
  final String phaseGroupKey;

  bool get isCountRep => countRepNumber > 0 && totalCountReps > 0;
}

class WorkoutTimerSnapshot {
  const WorkoutTimerSnapshot({
    required this.phase,
    required this.remainingSec,
    required this.exerciseIndex,
    required this.setIndex,
    required this.repIndex,
    required this.exerciseName,
    this.exerciseInstruction = '',
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
  /// Plain-text how-to for the current exercise (spoken during prepare).
  final String exerciseInstruction;
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

  int get remainingRepsInSet => totalReps - repIndex + 1;

  int get remainingSetsInExercise => totalSets - setIndex + 1;
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
  int _elapsedSec = 0;
  bool _isPaused = false;
  bool _announceHold = false;
  Timer? _timer;
  DateTime? _wallClockAnchor;
  late WorkoutTimerSnapshot _snapshot;

  WorkoutTimerSnapshot get snapshot => _snapshot;

  int get elapsedSec => _elapsedSec;

  bool get isAnnounceHold => _announceHold;

  WorkoutPhase? get nextPhase {
    if (_snapshot.isCompleted) return null;
    final nextIndex = _navigationUnitEnd(_phaseIndex) + 1;
    if (nextIndex >= _phases.length) return null;
    return _phases[nextIndex].phase;
  }

  bool get canGoToPreviousPhase =>
      !_snapshot.isCompleted && _navigationUnitStart(_phaseIndex) > 0;

  bool get canGoToNextPhase => !_snapshot.isCompleted;

  bool get canGoToPreviousExercise =>
      !_snapshot.isCompleted && _currentExerciseIndex > 0;

  bool get canGoToNextExercise =>
      !_snapshot.isCompleted &&
      _currentExerciseIndex < _exercises.length - 1;

  List<Exercise> get _exercises => routine.orderedExercises;

  int get _currentExerciseIndex {
    if (_snapshot.isCompleted || _phases.isEmpty) return 0;
    return _phases[_phaseIndex].exerciseIndex;
  }

  void start() {
    if (_snapshot.isCompleted || _isPaused || _announceHold) return;
    _timer?.cancel();
    _wallClockAnchor ??= DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      _tickOnWallClock();
    });
  }

  void _tickOnWallClock() {
    if (_snapshot.isCompleted || _isPaused || _announceHold) return;
    final anchor = _wallClockAnchor;
    if (anchor == null) return;
    final now = DateTime.now();
    if (now.difference(anchor).inMilliseconds < 900) return;
    _wallClockAnchor = now;
    _tick();
  }

  /// Freezes the countdown while intro speech plays (exercise name, phase, rep).
  void holdForAnnounce() {
    _announceHold = true;
    _timer?.cancel();
    _wallClockAnchor = null;
  }

  void releaseAnnounceHold() {
    if (!_announceHold) return;
    _announceHold = false;
    _wallClockAnchor = DateTime.now();
    start();
  }

  void pause() {
    _isPaused = true;
    _announceHold = false;
    _timer?.cancel();
    _wallClockAnchor = null;
    _refreshSnapshot();
  }

  void resume() {
    if (_snapshot.isCompleted) return;
    _isPaused = false;
    _wallClockAnchor = DateTime.now();
    start();
  }

  void skipPhase() {
    if (_snapshot.isCompleted) return;
    _advancePhase();
  }

  void goToPreviousPhase() {
    if (!canGoToPreviousPhase) return;
    final unitStart = _navigationUnitStart(_phaseIndex);
    _phaseIndex = _navigationUnitStart(unitStart - 1);
    _loadCurrentPhase();
  }

  void goToNextPhase() {
    if (_snapshot.isCompleted) return;
    final unitEnd = _navigationUnitEnd(_phaseIndex);
    if (unitEnd + 1 >= _phases.length) {
      _phaseIndex = _phases.length;
      _timer?.cancel();
      _remainingSec = 0;
      _refreshSnapshot(completed: true);
      return;
    }
    _phaseIndex = unitEnd + 1;
    _loadCurrentPhase();
  }

  void goToPreviousExercise() {
    if (!canGoToPreviousExercise) return;
    _phaseIndex = _firstPhaseIndexForExercise(_currentExerciseIndex - 1);
    _loadCurrentPhase();
  }

  void goToNextExercise() {
    if (!canGoToNextExercise) return;
    _phaseIndex = _firstPhaseIndexForExercise(_currentExerciseIndex + 1);
    _loadCurrentPhase();
  }

  void skipExercise() {
    if (_snapshot.isCompleted) return;
    final current = _phases[_phaseIndex].exerciseIndex;
    while (_phaseIndex < _phases.length &&
        _phases[_phaseIndex].exerciseIndex == current) {
      _phaseIndex++;
    }
    if (_phaseIndex >= _phases.length) {
      _timer?.cancel();
      _remainingSec = 0;
      _refreshSnapshot(completed: true);
      return;
    }
    _loadCurrentPhase();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!_isPaused) {
      _elapsedSec++;
    }
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
            _enqueuePhase(
              exerciseIndex: ei,
              setIndex: set,
              repIndex: rep,
              step: step,
            );
          }
        }
      }
    }
    if (_phases.isNotEmpty) {
      _remainingSec = _phases.first.phase.durationSec;
    }
  }

  void _enqueuePhase({
    required int exerciseIndex,
    required int setIndex,
    required int repIndex,
    required ExercisePhase step,
  }) {
    if (step.isCountMode) {
      if (step.countReps <= 0 || step.secondsPerRep <= 0) return;
      final groupKey = '${exerciseIndex}_${step.id}_${setIndex}_$repIndex';
      final phaseKind = step.kind == ExercisePhaseKind.work
          ? WorkoutPhaseKind.work
          : WorkoutPhaseKind.relax;
      for (final n in step.countRepSequence) {
        _phases.add(
          _QueuedPhase(
            exerciseIndex: exerciseIndex,
            setIndex: setIndex,
            repIndex: repIndex,
            phase: WorkoutPhase(
              kind: phaseKind,
              label: step.label,
              durationSec: step.secondsPerRep,
              countRepNumber: n,
              totalCountReps: step.countReps,
              phaseGroupKey: groupKey,
            ),
          ),
        );
      }
      return;
    }

    if (step.effectiveDurationSec <= 0) return;
    _phases.add(
      _QueuedPhase(
        exerciseIndex: exerciseIndex,
        setIndex: setIndex,
        repIndex: repIndex,
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
        exerciseInstruction: '',
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
      exerciseInstruction: exercise.instructionPlainText.trim(),
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

  /// Count mode expands one work/relax step into many queue items; navigation
  /// moves by whole step (phase group), not individual count ticks.
  String _navigationUnitKey(int index) {
    final groupKey = _phases[index].phase.phaseGroupKey;
    if (groupKey.isNotEmpty) return 'g:$groupKey';
    return 'i:$index';
  }

  int _navigationUnitStart(int index) {
    final key = _navigationUnitKey(index);
    var start = index;
    while (start > 0 && _navigationUnitKey(start - 1) == key) {
      start--;
    }
    return start;
  }

  int _navigationUnitEnd(int index) {
    final key = _navigationUnitKey(index);
    var end = index;
    while (end + 1 < _phases.length && _navigationUnitKey(end + 1) == key) {
      end++;
    }
    return end;
  }

  int _firstPhaseIndexForExercise(int exerciseIndex) {
    for (var i = 0; i < _phases.length; i++) {
      if (_phases[i].exerciseIndex == exerciseIndex) return i;
    }
    return _phases.length;
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
