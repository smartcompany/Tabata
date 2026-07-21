import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/routine_repository.dart';
import '../data/routine_factory.dart';
import '../engine/workout_timer_engine.dart';
import '../engine/workout_timer_labels.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import '../services/app_analytics_service.dart';
import '../services/workout_announce_gap.dart';
import '../services/workout_completion_recorder.dart';
import '../services/workout_settings.dart';
import '../services/workout_sound_coach.dart';
import '../services/workout_voice_coach.dart';
import '../services/workout_voice_phrases.dart';
import '../services/workout_voice_planner.dart';
import '../utils/duration_format.dart';
import '../utils/duration_calculator.dart';
import 'exercise_editor_screen.dart';
import 'routine_editor_screen.dart';
import '../widgets/workout_phase_stage.dart';

enum WorkoutLaunchScope { routine, singleExercise }

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({
    super.key,
    required this.routine,
    required this.repository,
    required this.completionRecorder,
    this.launchScope = WorkoutLaunchScope.routine,
    this.singleExerciseId,
  });

  final Routine routine;
  final RoutineRepository repository;
  final WorkoutCompletionRecorder completionRecorder;
  final WorkoutLaunchScope launchScope;
  final String? singleExerciseId;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> with WidgetsBindingObserver {
  static const _voicePlanner = WorkoutVoicePlanner();
  static const _accent = Color(0xFFE8F55A);
  static const _bg = Color(0xFF0A0A0A);
  static const _statRepsColor = Color(0xFF4FC3F7);
  static const _statSetsColor = Color(0xFFFFB74D);

  WorkoutTimerEngine? _engine;
  WorkoutVoiceCoach? _voiceCoach;
  WorkoutSoundCoach? _soundCoach;
  WorkoutTimerSnapshot? _previousSnapshot;
  WorkoutTimerSnapshot? _lastSoundSnapshot;
  Future<void>? _announceQueue;
  bool _completionRecorded = false;
  bool _startRecorded = false;
  late Routine _activeRoutine;
  var _continueInBackground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _activeRoutine = widget.routine;
    unawaited(_loadWorkoutSettings());
    WakelockPlus.enable();
    unawaited(
      AppAnalyticsService.logProductEvent(
        'workout_opened',
        properties: {
          'routine_source': _activeRoutine.id.startsWith('ai-')
              ? 'ai'
              : 'other',
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_engine != null) return;
    _engine = _createEngine(_activeRoutine);
    _engine!.addListener(_onTick);
    _initVoiceCoach(AppLocalizations.of(context));
  }

  WorkoutTimerEngine _createEngine(Routine routine) {
    final l10n = AppLocalizations.of(context);
    return WorkoutTimerEngine(
      routine,
      labels: WorkoutTimerLabels(
        prepare: l10n.phasePrepare,
        completedMessage: l10n.workoutCompletedMessage,
      ),
    );
  }

  void _reloadEngine(Routine routine) {
    _engine?.removeListener(_onTick);
    _engine?.dispose();
    _previousSnapshot = null;
    _lastSoundSnapshot = null;
    _startRecorded = false;
    _activeRoutine = routine;
    _engine = _createEngine(routine)..addListener(_onTick);
    _engine!.holdForAnnounce();
    _scheduleAnnounce();
    setState(() {});
  }

  Future<void> _initVoiceCoach(AppLocalizations l10n) async {
    if (!mounted) return;
    _soundCoach = WorkoutSoundCoach();
    _voiceCoach = WorkoutVoiceCoach(
      phrases: WorkoutVoicePhrases.fromL10n(l10n),
      locale: Localizations.localeOf(context),
      onAudioSessionRestored: () async {
        final coach = _soundCoach;
        final engine = _engine;
        if (coach == null || engine == null) return;
        await coach.refreshAudioSession(allowClockRestart: false);
        await coach.syncClock(
          engine.snapshot,
          blockForIntro: _shouldBlockClock(engine.snapshot),
        );
      },
    );
    await Future.wait([
      _voiceCoach!.init(Localizations.localeOf(context)),
      _soundCoach!.init(),
    ]);
    if (!mounted) return;
    _engine!.holdForAnnounce();
    _scheduleAnnounce();
  }

  void _onTick() {
    final engine = _engine;
    if (engine != null) {
      if (!_startRecorded && engine.elapsedSec > 0) {
        _startRecorded = true;
        unawaited(
          AppAnalyticsService.logProductEvent(
            'workout_started',
            properties: {
              'routine_source': _activeRoutine.id.startsWith('ai-')
                  ? 'ai'
                  : 'other',
            },
          ),
        );
      }
      final current = engine.snapshot;
      final introCues = _voicePlanner.plan(
        previous: _previousSnapshot,
        current: current,
      );
      if (_shouldHoldTimerForAnnounce(introCues) && !current.isPaused) {
        engine.holdForAnnounce();
      }

      final soundPrevious = _lastSoundSnapshot;
      _soundCoach?.handleSnapshot(
        soundPrevious,
        current,
        blockForIntro: _shouldBlockClock(current),
      );
      _lastSoundSnapshot = current;
    }
    _scheduleAnnounce();
    setState(() {});
    if (_engine!.snapshot.isCompleted) {
      HapticFeedback.mediumImpact();
      _maybeRecordCompletion();
    }
  }

  Future<void> _maybeRecordCompletion() async {
    if (_completionRecorded) return;
    _completionRecorded = true;

    final engine = _engine;
    if (engine == null || !mounted) return;

    await widget.completionRecorder.recordCompletedWorkout(
      context: context,
      routine: _activeRoutine,
      elapsedSec: engine.elapsedSec,
    );
  }

  void _scheduleAnnounce() {
    final engine = _engine;
    if (engine == null) return;

    final capturedCurrent = engine.snapshot;
    _announceQueue = (_announceQueue ?? Future<void>.value()).then((_) async {
      final previous = _previousSnapshot;
      final introCues = _voicePlanner.plan(
        previous: previous,
        current: capturedCurrent,
      );
      final holdTimer = _shouldHoldTimerForAnnounce(introCues);
      if (holdTimer && !capturedCurrent.isPaused && !engine.isAnnounceHold) {
        engine.holdForAnnounce();
      }
      if (needsWorkRelaxSessionGap(previous, capturedCurrent)) {
        await Future<void>.delayed(workRelaxSessionGap);
      }
      await _voiceCoach?.handleSnapshot(
        previous,
        capturedCurrent,
      );
      if (holdTimer) {
        engine.releaseAnnounceHold();
        await _soundCoach?.syncClock(engine.snapshot);
      }
      _previousSnapshot = capturedCurrent;
    });
  }

  bool _shouldHoldTimerForAnnounce(List<VoiceCue> cues) {
    return WorkoutVoicePlanner.shouldHoldTimerForAnnounce(
      cues,
      holdCountdown: defaultTargetPlatform == TargetPlatform.android,
    );
  }

  bool _shouldBlockClock(WorkoutTimerSnapshot current) {
    final engine = _engine;
    if (engine == null) return false;
    if (engine.isAnnounceHold) return true;
    final cues = _voicePlanner.plan(
      previous: _previousSnapshot,
      current: current,
    );
    return WorkoutVoicePlanner.hasBlockingIntroCues(cues);
  }

  Future<void> _loadWorkoutSettings() async {
    final settings = await WorkoutSettings.load();
    if (!mounted) return;
    setState(() {
      _continueInBackground = settings.continueInBackground;
      _soundCoach?.backgroundKeepAlive = settings.continueInBackground;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    final elapsed = _engine?.elapsedSec ?? 0;
    if (!_completionRecorded && elapsed > 0) {
      final planned = routineDurationSec(_activeRoutine);
      final percent = planned <= 0 ? 0 : ((elapsed / planned) * 100).round();
      final progressBucket = percent < 25
          ? 'under_25_percent'
          : percent < 50
              ? '25_to_50_percent'
              : percent < 75
                  ? '50_to_75_percent'
                  : '75_percent_plus';
      final snap = _engine?.snapshot;
      final phaseKind = snap?.phase.kind.name ?? 'unknown';
      unawaited(
        AppAnalyticsService.logProductEvent(
          'workout_abandoned',
          properties: {
            'progress_bucket': progressBucket,
            'phase_kind': phaseKind,
            'elapsed_sec_bucket': AppAnalyticsService.elapsedSecBucket(elapsed),
            'exercise_index': snap?.exerciseIndex ?? 0,
            'is_first_workout': !widget.completionRecorder.hasCompletedWorkout,
            'routine_source': _activeRoutine.id.startsWith('ai-') ? 'ai' : 'other',
          },
        ),
      );
    }
    _engine?.removeListener(_onTick);
    _engine?.pause();

    final soundCoach = _soundCoach;
    final voiceCoach = _voiceCoach;
    _soundCoach = null;
    _voiceCoach = null;

    // Stop clock immediately — do not wait for the TTS announce queue.
    unawaited(soundCoach?.dispose() ?? Future<void>.value());

    (_announceQueue ?? Future<void>.value())
        .then((_) => voiceCoach?.dispose())
        .catchError((_) {});

    _engine?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _soundCoach?.inBackground = false;
      final engine = _engine;
      if (engine != null && _continueInBackground && !engine.snapshot.isCompleted) {
        unawaited(_refreshBackgroundAudio(engine));
        setState(() {});
      }
      return;
    }
    if (!_isBackgroundLifecycle(state)) return;

    if (_continueInBackground) {
      final engine = _engine;
      if (engine == null ||
          engine.snapshot.isCompleted ||
          engine.snapshot.isPaused) {
        return;
      }
      _soundCoach?.inBackground = true;
      unawaited(_refreshBackgroundAudio(engine));
      return;
    }

    final engine = _engine;
    if (engine == null ||
        engine.snapshot.isCompleted ||
        engine.snapshot.isPaused) {
      return;
    }
    engine.pause();
    _soundCoach?.syncClock(
      engine.snapshot,
      blockForIntro: _shouldBlockClock(engine.snapshot),
    );
    setState(() {});
  }

  bool _isBackgroundLifecycle(AppLifecycleState state) {
    return state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden;
  }

  Future<void> _refreshBackgroundAudio(WorkoutTimerEngine engine) async {
    final coach = _soundCoach;
    if (coach == null) return;
    await coach.refreshAudioSession(allowClockRestart: false);
    await coach.syncClock(
      engine.snapshot,
      blockForIntro: _shouldBlockClock(engine.snapshot),
    );
  }

  Future<void> _openEdit() async {
    final engine = _engine;
    if (engine == null) return;

    final stored = widget.repository.findById(_activeRoutine.id);
    if (stored == null) return;

    engine.pause();
    if (!mounted) return;

    if (widget.launchScope == WorkoutLaunchScope.singleExercise) {
      final exerciseId = widget.singleExerciseId;
      if (exerciseId == null) return;

      final exercises = stored.orderedExercises;
      final index = exercises.indexWhere((item) => item.id == exerciseId);
      if (index < 0) return;

      final updated = await Navigator.of(context).push<Exercise>(
        MaterialPageRoute(
          builder: (_) => ExerciseEditorScreen(exercise: exercises[index]),
        ),
      );
      if (updated == null || !mounted) return;

      final nextExercises = List<Exercise>.from(exercises);
      nextExercises[index] = updated;
      final saved = stored.copyWith(
        exercises: reindexExercises(nextExercises),
      );
      await widget.repository.upsert(saved);
      if (!mounted) return;
      if (widget.repository.findById(saved.id) == null) {
        Navigator.of(context).pop();
        return;
      }
      _reloadEngine(saved.forSingleExercise(updated));
      return;
    }

    final updated = await Navigator.of(context).push<Routine>(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          repository: widget.repository,
          routine: stored,
        ),
      ),
    );
    if (updated == null || !mounted) return;
    if (widget.repository.findById(updated.id) == null) {
      Navigator.of(context).pop();
      return;
    }
    _reloadEngine(updated);
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
    _soundCoach?.syncClock(
      engine.snapshot,
      blockForIntro: _shouldBlockClock(engine.snapshot),
    );
    setState(() {});
  }

  void _goToPreviousPhase() {
    final engine = _engine!;
    if (!engine.canGoToPreviousPhase) return;
    engine.goToPreviousPhase();
    _soundCoach?.syncClock(
      engine.snapshot,
      blockForIntro: _shouldBlockClock(engine.snapshot),
    );
  }

  void _goToNextPhase() {
    final engine = _engine!;
    if (!engine.canGoToNextPhase) return;
    engine.goToNextPhase();
    _soundCoach?.syncClock(
      engine.snapshot,
      blockForIntro: _shouldBlockClock(engine.snapshot),
    );
  }

  void _goToPreviousExercise() {
    final engine = _engine!;
    if (!engine.canGoToPreviousExercise) return;
    engine.goToPreviousExercise();
    _soundCoach?.syncClock(
      engine.snapshot,
      blockForIntro: _shouldBlockClock(engine.snapshot),
    );
  }

  void _goToNextExercise() {
    final engine = _engine!;
    if (!engine.canGoToNextExercise) return;
    engine.goToNextExercise();
    _soundCoach?.syncClock(
      engine.snapshot,
      blockForIntro: _shouldBlockClock(engine.snapshot),
    );
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
                      if (!snap.isCompleted && widget.repository.findById(_activeRoutine.id) != null)
                        IconButton(
                          onPressed: _openEdit,
                          tooltip: widget.launchScope ==
                                  WorkoutLaunchScope.singleExercise
                              ? l10n.editExerciseTitle
                              : l10n.editRoutineTitle,
                          icon: Icon(
                            Icons.edit_outlined,
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
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _WorkoutNavButton(
                          icon: Icons.skip_previous_rounded,
                          label: l10n.workoutPrevious,
                          enabled: engine.canGoToPreviousExercise,
                          onPressed: _goToPreviousExercise,
                        ),
                        Expanded(
                          child: Column(
                            children: [
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
                          ),
                        ),
                        _WorkoutNavButton(
                          icon: Icons.skip_next_rounded,
                          label: l10n.workoutNext,
                          enabled: engine.canGoToNextExercise,
                          onPressed: _goToNextExercise,
                        ),
                      ],
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
                onPreviousPhase: _goToPreviousPhase,
                onNextPhase: _goToNextPhase,
                canGoToPreviousPhase: engine.canGoToPreviousPhase,
                canGoToNextPhase: engine.canGoToNextPhase,
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

class _WorkoutNavButton extends StatelessWidget {
  const _WorkoutNavButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.22);

    return SizedBox(
      width: 44,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        tooltip: label,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        icon: Icon(icon, color: color, size: 28),
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
                      isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
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
