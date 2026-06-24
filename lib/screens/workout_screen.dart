import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../engine/workout_timer_engine.dart';
import '../engine/workout_timer_labels.dart';
import '../models/routine.dart';
import '../services/sound_settings.dart';
import '../services/voice_settings.dart';
import '../services/workout_sound_coach.dart';
import '../services/workout_voice_coach.dart';
import '../services/workout_voice_phrases.dart';
import '../utils/duration_format.dart';
import '../widgets/workout_phase_stage.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key, required this.routine});

  final Routine routine;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  static const _accent = Color(0xFFE8F55A);
  static const _bg = Color(0xFF0A0A0A);
  static const _statRepsColor = Color(0xFF4FC3F7);
  static const _statSetsColor = Color(0xFFFFB74D);

  WorkoutTimerEngine? _engine;
  WorkoutVoiceCoach? _voiceCoach;
  WorkoutSoundCoach? _soundCoach;
  WorkoutTimerSnapshot? _previousSnapshot;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_engine != null) return;
    final l10n = AppLocalizations.of(context);
    _engine = WorkoutTimerEngine(
      widget.routine,
      labels: WorkoutTimerLabels(
        prepare: l10n.phasePrepare,
        completedMessage: l10n.workoutCompletedMessage,
      ),
    );
    _engine!.addListener(_onTick);
    _initVoiceCoach(l10n);
  }

  Future<void> _initVoiceCoach(AppLocalizations l10n) async {
    final settings = await VoiceSettings.load();
    final soundSettings = await SoundSettings.load();
    if (!mounted) return;
    _voiceCoach = WorkoutVoiceCoach(
      phrases: WorkoutVoicePhrases.fromL10n(l10n),
      settings: settings,
      locale: Localizations.localeOf(context),
    );
    _soundCoach = WorkoutSoundCoach(settings: soundSettings);
    await Future.wait([
      _voiceCoach!.init(Localizations.localeOf(context)),
      _soundCoach!.init(),
    ]);
    if (!mounted) return;
    _announceSnapshot();
    _engine!.start();
  }

  void _onTick() {
    _announceSnapshot();
    setState(() {});
    if (_engine!.snapshot.isCompleted) {
      HapticFeedback.mediumImpact();
    }
  }

  void _announceSnapshot() {
    final engine = _engine;
    final coach = _voiceCoach;
    final soundCoach = _soundCoach;
    if (engine == null) return;
    final current = engine.snapshot;
    coach?.handleSnapshot(_previousSnapshot, current);
    soundCoach?.handleSnapshot(_previousSnapshot, current);
    _previousSnapshot = current;
  }

  @override
  void dispose() {
    _engine?.removeListener(_onTick);
    _voiceCoach?.dispose();
    _soundCoach?.dispose();
    _engine?.dispose();
    super.dispose();
  }

  void _togglePause() {
    final engine = _engine!;
    final snap = engine.snapshot;
    if (snap.isCompleted) return;
    if (snap.isPaused) {
      engine.resume();
    } else {
      engine.pause();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final engine = _engine;
    if (engine == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }

    final l10n = AppLocalizations.of(context);
    final snap = engine.snapshot;
    final nextPhase = engine.nextPhase;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          snap.routineTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: _accent,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (!snap.isCompleted)
                        IconButton(
                          onPressed: engine.skipExercise,
                          tooltip: l10n.skipExercise,
                          icon: Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                  if (!snap.isCompleted) ...[
                    Text(
                      formatDurationClock(engine.elapsedSec),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.38),
                        fontSize: 14,
                        fontFeatures: const [
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snap.exerciseName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.workoutProgress(
                        snap.exerciseIndex,
                        snap.totalExercises,
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.38),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: WorkoutPhaseStage(
                snap: snap,
                nextPhase: nextPhase,
                l10n: l10n,
                completedAccent: _accent,
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _bg,
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                18,
                20,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              child: snap.isCompleted
                  ? FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(l10n.workoutDone),
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _GlassStatBox(
                                value: '${snap.remainingRepsInSet}',
                                label: l10n.workoutRemainingReps,
                                valueColor: _statRepsColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: _PlayPauseButton(
                                isPaused: snap.isPaused,
                                progress: snap.progress,
                                onPressed: _togglePause,
                                label: snap.isPaused ? l10n.resume : l10n.pause,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _GlassStatBox(
                                value: '${snap.remainingSetsInExercise}',
                                label: l10n.workoutRemainingSets,
                                valueColor: _statSetsColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: engine.skipPhase,
                          child: Text(
                            l10n.skipPhase,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.38),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassStatBox extends StatelessWidget {
  const _GlassStatBox({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPaused,
    required this.progress,
    required this.onPressed,
    required this.label,
  });

  final bool isPaused;
  final double progress;
  final VoidCallback onPressed;
  final String label;

  static const _accent = Color(0xFFE8F55A);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 84,
          height: 84,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.35),
                      blurRadius: 20,
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: CircularProgressIndicator(
                  value: progress.clamp(0, 1),
                  strokeWidth: 3.5,
                  strokeCap: StrokeCap.round,
                  color: _accent,
                  backgroundColor: _accent.withValues(alpha: 0.15),
                ),
              ),
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 4,
                shadowColor: _accent.withValues(alpha: 0.4),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onPressed,
                  child: SizedBox(
                    width: 62,
                    height: 62,
                    child: Icon(
                      isPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      size: 32,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: _accent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
