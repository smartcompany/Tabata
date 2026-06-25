import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_repository.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import '../services/routine_share_service.dart';
import '../utils/duration_calculator.dart';
import '../widgets/exercise_summary.dart';
import 'routine_editor_screen.dart';
import 'workout_screen.dart';

class RoutineDetailScreen extends StatefulWidget {
  const RoutineDetailScreen({
    super.key,
    required this.repository,
    required this.routineId,
  });

  final RoutineRepository repository;
  final String routineId;

  @override
  State<RoutineDetailScreen> createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends State<RoutineDetailScreen> {
  final _shareService = RoutineShareService();
  final _shareButtonKey = GlobalKey();
  Routine? _routine;

  @override
  void initState() {
    super.initState();
    _routine = widget.repository.findById(widget.routineId);
  }

  void _reload() {
    setState(() => _routine = widget.repository.findById(widget.routineId));
  }

  Future<void> _edit() async {
    final routine = _routine;
    if (routine == null) return;
    await Navigator.of(context).push<Routine>(
      MaterialPageRoute(
        builder: (_) => RoutineEditorScreen(
          repository: widget.repository,
          routine: routine,
        ),
      ),
    );
    if (!mounted) return;
    if (widget.repository.findById(widget.routineId) == null) {
      Navigator.of(context).pop();
      return;
    }
    _reload();
  }

  Future<void> _share() async {
    final routine = _routine;
    if (routine == null) return;
    await _shareService.share(
      routine,
      sharePositionOrigin: _sharePositionOrigin(),
    );
  }

  Rect? _sharePositionOrigin() {
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }

    final context = this.context;
    if (!context.mounted) return null;
    final size = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 1,
      height: 1,
    );
  }

  Future<void> _deleteLocally() async {
    final l10n = AppLocalizations.of(context);
    final isServer = widget.repository.isServerProfile(widget.routineId);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRoutineTitle),
        content: Text(
          isServer ? l10n.deleteLocalCopyMessage : l10n.deleteRoutineMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await widget.repository.delete(widget.routineId);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _rollback() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.rollbackConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await widget.repository.rollbackToServer(widget.routineId);
      if (!mounted) return;
      _reload();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.rollbackSuccess)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.rollbackError)),
      );
    }
  }

  void _openWorkout(Routine routine) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(routine: routine),
        fullscreenDialog: true,
      ),
    );
  }

  void _start() {
    final routine = _routine;
    if (routine == null) return;
    _openWorkout(routine);
  }

  void _startExercise(Exercise exercise) {
    final routine = _routine;
    if (routine == null) return;
    _openWorkout(routine.forSingleExercise(exercise));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final routine = _routine;
    if (routine == null) {
      return Scaffold(
        body: Center(child: Text(l10n.routineNotFound)),
      );
    }

    final isDownloaded = widget.repository.isDownloadedLocally(widget.routineId);
    if (!isDownloaded) {
      return Scaffold(
        appBar: AppBar(title: Text(routine.title)),
        body: Center(child: Text(l10n.routineNotFound)),
      );
    }

    final exercises = routine.orderedExercises;
    final totalSec = routineDurationSec(routine);

    return Scaffold(
      appBar: AppBar(
        title: Text(routine.title),
        actions: [
          if (widget.repository.isServerProfile(widget.routineId))
            IconButton(
              onPressed: _rollback,
              icon: const Icon(Icons.restore),
              tooltip: l10n.rollbackTooltip,
            ),
          IconButton(
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editTooltip,
          ),
          IconButton(
            key: _shareButtonKey,
            onPressed: _share,
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.shareTooltip,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          24 + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          if (routine.description.isNotEmpty) ...[
            Text(
              routine.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
          ],
          EstimatedDurationCard(totalSec: totalSec),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.exerciseListTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: _start,
                icon: const Icon(Icons.play_arrow, size: 18),
                label: Text(l10n.startAll),
                style: FilledButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...exercises.map(
            (exercise) => ExerciseDetailCard(
              exercise: exercise,
              onTap: _edit,
              onStart: () => _startExercise(exercise),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deleteLocally,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.deleteRoutineTitle),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
