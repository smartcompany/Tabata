import '../engine/workout_timer_engine.dart';

enum VoiceCueKind { exerciseName, phaseStart, countdown, repCount, completed }

class VoiceCue {
  const VoiceCue._(
    this.kind, {
    this.phaseKind,
    this.label,
    this.phaseDurationSec,
    this.seconds,
    this.repNumber,
    this.totalReps,
    this.exerciseName,
  });

  const VoiceCue.exerciseName(String name)
      : this._(VoiceCueKind.exerciseName, exerciseName: name);

  const VoiceCue.phaseStart({
    required WorkoutPhaseKind phaseKind,
    required String label,
    required int phaseDurationSec,
  }) : this._(
          VoiceCueKind.phaseStart,
          phaseKind: phaseKind,
          label: label,
          phaseDurationSec: phaseDurationSec,
        );

  const VoiceCue.countdown(int seconds)
      : this._(VoiceCueKind.countdown, seconds: seconds);

  const VoiceCue.repCount({
    required int repNumber,
    required int totalReps,
  }) : this._(
          VoiceCueKind.repCount,
          repNumber: repNumber,
          totalReps: totalReps,
        );

  const VoiceCue.completed() : this._(VoiceCueKind.completed);

  final VoiceCueKind kind;
  final WorkoutPhaseKind? phaseKind;
  final String? label;
  final int? phaseDurationSec;
  final int? seconds;
  final int? repNumber;
  final int? totalReps;
  final String? exerciseName;
}

class WorkoutVoicePlanner {
  const WorkoutVoicePlanner();

  /// Cues that must finish before the phase countdown may tick.
  static bool hasBlockingIntroCues(List<VoiceCue> cues) {
    return cues.any(
      (cue) =>
          cue.kind == VoiceCueKind.exerciseName ||
          cue.kind == VoiceCueKind.phaseStart ||
          cue.kind == VoiceCueKind.repCount,
    );
  }

  List<VoiceCue> plan({
    required WorkoutTimerSnapshot? previous,
    required WorkoutTimerSnapshot current,
    bool countSecondsWithTts = true,
  }) {
    if (current.isPaused) return const [];

    if (current.isCompleted) {
      if (previous?.isCompleted == true) return const [];
      return const [VoiceCue.completed()];
    }

    final cues = <VoiceCue>[];

    if (_exerciseChanged(previous, current) &&
        current.exerciseName.isNotEmpty) {
      cues.add(VoiceCue.exerciseName(current.exerciseName));
    }

    if (_phaseChanged(previous, current)) {
      if (current.phase.isCountRep) {
        final sequenceStart = previous == null ||
            previous.isCompleted ||
            previous.phase.phaseGroupKey != current.phase.phaseGroupKey;
        if (sequenceStart) {
          cues.add(
            VoiceCue.phaseStart(
              phaseKind: current.phase.kind,
              label: current.phase.label,
              phaseDurationSec:
                  current.phase.totalCountReps * current.phase.durationSec,
            ),
          );
        }
        cues.add(
          VoiceCue.repCount(
            repNumber: current.phase.countRepNumber,
            totalReps: current.phase.totalCountReps,
          ),
        );
      } else {
        cues.add(
          VoiceCue.phaseStart(
            phaseKind: current.phase.kind,
            label: current.phase.label,
            phaseDurationSec: current.phase.durationSec,
          ),
        );
      }
    } else if (previous != null &&
        countSecondsWithTts &&
        current.phase.isCountRep &&
        _countRepSecondElapsed(previous, current)) {
      cues.add(VoiceCue.countdown(current.remainingSec));
    } else if (previous != null &&
        !current.phase.isCountRep &&
        _shouldCountdown(
          previousRemaining: previous.remainingSec,
          currentRemaining: current.remainingSec,
          phaseDuration: current.phase.durationSec,
        )) {
      cues.add(VoiceCue.countdown(current.remainingSec));
    }

    return cues;
  }

  bool _phaseChanged(
    WorkoutTimerSnapshot? previous,
    WorkoutTimerSnapshot current,
  ) {
    if (previous == null || previous.isCompleted) return true;
    if (previous.phase.kind != current.phase.kind) return true;
    if (previous.phase.label != current.phase.label) return true;
    if (previous.phase.phaseGroupKey != current.phase.phaseGroupKey) {
      return true;
    }
    if (previous.phase.countRepNumber != current.phase.countRepNumber) {
      return true;
    }
    if (previous.exerciseIndex != current.exerciseIndex) return true;
    if (previous.setIndex != current.setIndex) return true;
    if (previous.repIndex != current.repIndex) return true;
    return false;
  }

  bool _exerciseChanged(
    WorkoutTimerSnapshot? previous,
    WorkoutTimerSnapshot current,
  ) {
    if (previous == null || previous.isCompleted) return true;
    return previous.exerciseIndex != current.exerciseIndex;
  }

  bool _countRepSecondElapsed(
    WorkoutTimerSnapshot previous,
    WorkoutTimerSnapshot current,
  ) {
    if (!_sameCountRepContext(previous, current)) return false;
    if (previous.remainingSec - current.remainingSec != 1) return false;
    return current.remainingSec > 0;
  }

  bool _sameCountRepContext(
    WorkoutTimerSnapshot previous,
    WorkoutTimerSnapshot current,
  ) {
    return previous.phase.isCountRep &&
        current.phase.isCountRep &&
        previous.phase.phaseGroupKey == current.phase.phaseGroupKey &&
        previous.phase.countRepNumber == current.phase.countRepNumber &&
        previous.exerciseIndex == current.exerciseIndex &&
        previous.setIndex == current.setIndex &&
        previous.repIndex == current.repIndex;
  }

  bool _shouldCountdown({
    required int previousRemaining,
    required int currentRemaining,
    required int phaseDuration,
  }) {
    if (phaseDuration <= 3) return false;
    if (currentRemaining < 1 || currentRemaining > 3) return false;
    return previousRemaining == currentRemaining + 1;
  }
}

String phaseStartSpeech({
  required WorkoutPhaseKind phaseKind,
  required String label,
  required String prepareTitle,
  required String workTitle,
  required String relaxTitle,
}) {
  final kindTitle = switch (phaseKind) {
    WorkoutPhaseKind.prepare => prepareTitle,
    WorkoutPhaseKind.work => workTitle,
    WorkoutPhaseKind.relax => relaxTitle,
    WorkoutPhaseKind.completed => '',
  };
  if (label.isEmpty || label == kindTitle) return kindTitle;
  return '$kindTitle, $label';
}
