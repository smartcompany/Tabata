import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_repository.dart';
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
    await _shareService.share(routine);
  }

  void _start() {
    final routine = _routine;
    if (routine == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(routine: routine),
        fullscreenDialog: true,
      ),
    );
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

    final exercises = routine.orderedExercises;
    final totalSec = routineDurationSec(routine);

    return Scaffold(
      appBar: AppBar(
        title: Text(routine.title),
        actions: [
          IconButton(
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editTooltip,
          ),
          IconButton(
            onPressed: _share,
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.shareTooltip,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
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
          Text(
            l10n.exerciseListTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...exercises.map(
            (exercise) => ExerciseDetailCard(
              exercise: exercise,
              onTap: _edit,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _start,
        icon: const Icon(Icons.play_arrow),
        label: Text(l10n.start),
      ),
    );
  }
}
