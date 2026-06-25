import 'package:tabata_timer/l10n/app_localizations.dart';

class WorkoutVoicePhrases {
  const WorkoutVoicePhrases({
    required this.prepare,
    required this.work,
    required this.relax,
    required this.completed,
    required this.countdown,
    required this.repCount,
  });

  factory WorkoutVoicePhrases.fromL10n(AppLocalizations l10n) {
    return WorkoutVoicePhrases(
      prepare: l10n.phasePrepare,
      work: l10n.phaseWork,
      relax: l10n.phaseRelax,
      completed: l10n.workoutCompletedMessage,
      countdown: (seconds) => switch (seconds) {
        3 => l10n.voiceCountThree,
        2 => l10n.voiceCountTwo,
        1 => l10n.voiceCountOne,
        _ => '$seconds',
      },
      repCount: (repNumber) => l10n.countReps(repNumber),
    );
  }

  final String prepare;
  final String work;
  final String relax;
  final String completed;
  final String Function(int seconds) countdown;
  final String Function(int repNumber) repCount;
}
