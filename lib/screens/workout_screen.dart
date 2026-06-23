import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../engine/workout_timer_engine.dart';
import '../engine/workout_timer_labels.dart';
import '../l10n/l10n_extensions.dart';
import '../models/routine.dart';
import '../services/voice_settings.dart';
import '../services/workout_voice_coach.dart';
import '../services/workout_voice_phrases.dart';
import '../utils/duration_format.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key, required this.routine});

  final Routine routine;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  static const _accent = Color(0xFFCDDC39);
  static const _statRepsColor = Color(0xFF4FC3F7);
  static const _statSetsColor = Color(0xFFFFEE58);

  WorkoutTimerEngine? _engine;
  WorkoutVoiceCoach? _voiceCoach;
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
    if (!mounted) return;
    _voiceCoach = WorkoutVoiceCoach(
      phrases: WorkoutVoicePhrases.fromL10n(l10n),
      settings: settings,
      locale: Localizations.localeOf(context),
    );
    await _voiceCoach!.init(Localizations.localeOf(context));
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
    if (engine == null || coach == null) return;
    final current = engine.snapshot;
    coach.handleSnapshot(_previousSnapshot, current);
    _previousSnapshot = current;
  }

  @override
  void dispose() {
    _engine?.removeListener(_onTick);
    _voiceCoach?.dispose();
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

  _PhasePalette _palette(WorkoutPhaseKind kind) {
    return switch (kind) {
      WorkoutPhaseKind.prepare => const _PhasePalette(
          panel: Color(0xFF9FA8DA),
          onPanel: Colors.black,
        ),
      WorkoutPhaseKind.work => const _PhasePalette(
          panel: Color(0xFFCDDC39),
          onPanel: Colors.black,
        ),
      WorkoutPhaseKind.relax => const _PhasePalette(
          panel: Color(0xFF80DEEA),
          onPanel: Colors.black,
        ),
      WorkoutPhaseKind.completed => const _PhasePalette(
          panel: Color(0xFF1B1B1B),
          onPanel: Colors.white,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final engine = _engine;
    if (engine == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }

    final l10n = AppLocalizations.of(context);
    final snap = engine.snapshot;
    final palette = _palette(snap.phase.kind);
    final nextPhase = engine.nextPhase;
    final phaseTitle = snap.phase.kind.title(l10n);
    final showPhaseLabel = !snap.isCompleted &&
        snap.phase.label.isNotEmpty &&
        snap.phase.label != phaseTitle;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white54),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              snap.routineTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _accent,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatDurationClock(engine.elapsedSec),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 15,
                                fontFeatures: [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!snap.isCompleted)
                        IconButton(
                          onPressed: engine.skipExercise,
                          tooltip: l10n.skipExercise,
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: Colors.white54,
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                  if (!snap.isCompleted) ...[
                    const SizedBox(height: 4),
                    Text(
                      snap.exerciseName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.workoutProgress(
                        snap.exerciseIndex,
                        snap.totalExercises,
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: palette.panel,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: snap.isCompleted
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 72,
                                color: _accent,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                snap.phase.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: palette.onPanel,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                phaseTitle,
                                style: TextStyle(
                                  color: palette.onPanel,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (showPhaseLabel) ...[
                                const SizedBox(height: 8),
                                Text(
                                  snap.phase.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: palette.onPanel.withValues(
                                      alpha: 0.72,
                                    ),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              Text(
                                formatDurationClock(snap.remainingSec),
                                style: TextStyle(
                                  color: palette.onPanel,
                                  fontSize: 88,
                                  height: 1,
                                  fontWeight: FontWeight.w300,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                              if (nextPhase != null) ...[
                                const SizedBox(height: 28),
                                _NextPhasePreview(
                                  label: l10n.workoutNext,
                                  phaseTitle: nextPhase.kind.title(l10n),
                                  duration: formatDurationClock(
                                    nextPhase.durationSec,
                                  ),
                                  color: palette.onPanel.withValues(alpha: 0.55),
                                ),
                              ],
                            ],
                          ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFF121212),
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                20 + MediaQuery.paddingOf(context).bottom,
              ),
              child: snap.isCompleted
                  ? FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(l10n.workoutDone),
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatColumn(
                                value: '${snap.remainingRepsInSet}',
                                label: l10n.workoutRemainingReps,
                                valueColor: _statRepsColor,
                              ),
                            ),
                            Expanded(
                              child: _PlayPauseButton(
                                isPaused: snap.isPaused,
                                onPressed: _togglePause,
                                label: snap.isPaused ? l10n.resume : l10n.pause,
                              ),
                            ),
                            Expanded(
                              child: _StatColumn(
                                value: '${snap.remainingSetsInExercise}',
                                label: l10n.workoutRemainingSets,
                                valueColor: _statSetsColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: engine.skipPhase,
                          child: Text(
                            l10n.skipPhase,
                            style: const TextStyle(color: Colors.white38),
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

class _PhasePalette {
  const _PhasePalette({required this.panel, required this.onPanel});

  final Color panel;
  final Color onPanel;
}

class _NextPhasePreview extends StatelessWidget {
  const _NextPhasePreview({
    required this.label,
    required this.phaseTitle,
    required this.duration,
    required this.color,
  });

  final String label;
  final String phaseTitle;
  final String duration;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          phaseTitle,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          duration,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 40,
            height: 1,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton({
    required this.isPaused,
    required this.onPressed,
    required this.label,
  });

  final bool isPaused;
  final VoidCallback onPressed;
  final String label;

  static const _accent = Color(0xFFCDDC39);

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
                  border: Border.all(color: _accent, width: 4),
                ),
              ),
              Material(
                color: Colors.white,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onPressed,
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: Icon(
                      isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                      size: 36,
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
