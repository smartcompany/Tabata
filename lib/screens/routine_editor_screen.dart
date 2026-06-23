import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_factory.dart';
import '../data/routine_repository.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import '../utils/duration_calculator.dart';
import '../widgets/exercise_summary.dart';
import 'exercise_editor_screen.dart';

class RoutineEditorScreen extends StatefulWidget {
  const RoutineEditorScreen({
    super.key,
    required this.repository,
    required this.routine,
    this.isNew = false,
  });

  final RoutineRepository repository;
  final Routine routine;
  final bool isNew;

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.routine.title);
    _descriptionController =
        TextEditingController(text: widget.routine.description);
    _exercises = List<Exercise>.from(widget.routine.orderedExercises);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Routine get _draft => widget.routine.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        exercises: reindexExercises(_exercises),
      );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_exercises.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.requireAtLeastOneExercise)),
      );
      return;
    }
    await widget.repository.upsert(_draft);
    if (!mounted) return;
    Navigator.of(context).pop(_draft);
  }

  Future<void> _deleteRoutine() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRoutineTitle),
        content: Text(l10n.deleteRoutineMessage),
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
    await widget.repository.delete(widget.routine.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _addExercise() async {
    final exercise = createEmptyExercise(order: _exercises.length);
    final result = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (_) => ExerciseEditorScreen(exercise: exercise, isNew: true),
      ),
    );
    if (result == null) return;
    setState(() => _exercises = [..._exercises, result]);
  }

  Future<void> _editExercise(int index) async {
    final result = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (_) => ExerciseEditorScreen(exercise: _exercises[index]),
      ),
    );
    if (result == null) return;
    setState(() {
      final updated = List<Exercise>.from(_exercises);
      updated[index] = result;
      _exercises = updated;
    });
  }

  void _deleteExercise(int index) {
    setState(() {
      final updated = List<Exercise>.from(_exercises)..removeAt(index);
      _exercises = reindexExercises(updated);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final updated = List<Exercise>.from(_exercises);
      final item = updated.removeAt(oldIndex);
      updated.insert(newIndex, item);
      _exercises = reindexExercises(updated);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final previewRoutine = _draft;
    final totalSec =
        _exercises.isEmpty ? 0 : routineDurationSec(previewRoutine);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? l10n.createRoutineTitle : l10n.editRoutineTitle),
        actions: [
          if (!widget.isNew)
            IconButton(
              onPressed: _deleteRoutine,
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.deleteRoutineTooltip,
            ),
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.routineNameLabel,
                hintText: l10n.routineNameHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validationNameRequired;
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.descriptionOptionalLabel,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            if (_exercises.isNotEmpty) EstimatedDurationCard(totalSec: totalSec),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  l10n.exerciseListTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  l10n.reorderExercisesHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_exercises.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.addExercisesPrompt)),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return ExerciseListTileCard(
                    key: ValueKey(exercise.id),
                    exercise: exercise,
                    index: index,
                    onTap: () => _editExercise(index),
                    onDelete: () => _deleteExercise(index),
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExercise,
        icon: const Icon(Icons.add),
        label: Text(l10n.addExercise),
      ),
    );
  }
}
