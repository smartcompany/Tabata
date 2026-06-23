import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../engine/workout_timer_engine.dart';
import '../engine/workout_timer_labels.dart';
import '../l10n/l10n_extensions.dart';
import '../models/routine.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key, required this.routine});

  final Routine routine;

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  WorkoutTimerEngine? _engine;

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
    )..start();
    _engine!.addListener(_onTick);
  }

  void _onTick() {
    setState(() {});
    if (_engine!.snapshot.isCompleted) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _engine?.removeListener(_onTick);
    _engine?.dispose();
    super.dispose();
  }

  Color _phaseColor(WorkoutPhaseKind kind) {
    return switch (kind) {
      WorkoutPhaseKind.prepare => const Color(0xFF5C6BC0),
      WorkoutPhaseKind.work => const Color(0xFFE53935),
      WorkoutPhaseKind.relax => const Color(0xFF43A047),
      WorkoutPhaseKind.completed => const Color(0xFF1E88E5),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final engine = _engine!;
    final snap = engine.snapshot;
    final phaseColor = _phaseColor(snap.phase.kind);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      snap.routineTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 8),
              if (!snap.isCompleted) ...[
                Text(
                  l10n.workoutProgress(
                    snap.exerciseIndex,
                    snap.totalExercises,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  snap.exerciseName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                snap.phase.kind.title(l10n),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: phaseColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                snap.phase.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                snap.isCompleted ? '✓' : '${snap.remainingSec}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: phaseColor,
                  fontSize: snap.isCompleted ? 72 : 96,
                  fontWeight: FontWeight.w300,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 16),
              if (!snap.isCompleted)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: snap.progress,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    color: phaseColor,
                  ),
                ),
              const Spacer(),
              if (!snap.isCompleted) ...[
                Text(
                  l10n.repSetProgress(
                    snap.repIndex,
                    snap.totalReps,
                    snap.setIndex,
                    snap.totalSets,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ControlButton(
                      icon: Icons.skip_next,
                      label: l10n.skipPhase,
                      onPressed: engine.skipPhase,
                    ),
                    _ControlButton(
                      icon: snap.isPaused ? Icons.play_arrow : Icons.pause,
                      label: snap.isPaused ? l10n.resume : l10n.pause,
                      onPressed: () {
                        if (snap.isPaused) {
                          engine.resume();
                        } else {
                          engine.pause();
                        }
                        setState(() {});
                      },
                    ),
                    _ControlButton(
                      icon: Icons.fast_forward,
                      label: l10n.skipExercise,
                      onPressed: engine.skipExercise,
                    ),
                  ],
                ),
              ] else
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(l10n.workoutDone),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filled(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white24,
            foregroundColor: Colors.white,
            iconSize: 28,
          ),
          onPressed: onPressed,
          icon: Icon(icon),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
