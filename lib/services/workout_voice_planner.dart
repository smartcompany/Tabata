import '../engine/workout_timer_engine.dart';

enum VoiceCueKind { phaseStart, countdown, completed }

class VoiceCue {
  const VoiceCue._(
    this.kind, {
    this.phaseKind,
    this.label,
    this.seconds,
  });

  const VoiceCue.phaseStart({
    required WorkoutPhaseKind phaseKind,
    required String label,
  }) : this._(
          VoiceCueKind.phaseStart,
          phaseKind: phaseKind,
          label: label,
        );

  const VoiceCue.countdown(int seconds)
      : this._(VoiceCueKind.countdown, seconds: seconds);

  const VoiceCue.completed() : this._(VoiceCueKind.completed);

  final VoiceCueKind kind;
  final WorkoutPhaseKind? phaseKind;
  final String? label;
  final int? seconds;
}

class WorkoutVoicePlanner {
  const WorkoutVoicePlanner();

  List<VoiceCue> plan({
    required WorkoutTimerSnapshot? previous,
    required WorkoutTimerSnapshot current,
  }) {
    if (current.isPaused) return const [];

    if (current.isCompleted) {
      if (previous?.isCompleted == true) return const [];
      return const [VoiceCue.completed()];
    }

    final cues = <VoiceCue>[];

    if (_phaseChanged(previous, current)) {
      cues.add(
        VoiceCue.phaseStart(
          phaseKind: current.phase.kind,
          label: current.phase.label,
        ),
      );
    } else if (previous != null &&
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
    if (previous.exerciseIndex != current.exerciseIndex) return true;
    if (previous.setIndex != current.setIndex) return true;
    if (previous.repIndex != current.repIndex) return true;
    return false;
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
