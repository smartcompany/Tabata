import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_fork.dart';
import '../data/routine_repository.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import '../utils/duration_calculator.dart';
import '../utils/exercise_formatter.dart';

abstract final class ImportExercisesSheet {
  static Future<List<Exercise>?> show({
    required BuildContext context,
    required RoutineRepository repository,
    required String excludeRoutineId,
  }) {
    return showModalBottomSheet<List<Exercise>>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ImportExercisesSheetBody(
        repository: repository,
        excludeRoutineId: excludeRoutineId,
      ),
    );
  }
}

class _ImportExercisesSheetBody extends StatefulWidget {
  const _ImportExercisesSheetBody({
    required this.repository,
    required this.excludeRoutineId,
  });

  final RoutineRepository repository;
  final String excludeRoutineId;

  @override
  State<_ImportExercisesSheetBody> createState() =>
      _ImportExercisesSheetBodyState();
}

class _ImportExercisesSheetBodyState extends State<_ImportExercisesSheetBody> {
  Routine? _selectedRoutine;
  final Set<String> _selectedExerciseIds = {};

  List<Routine> get _sourceRoutines => widget.repository.myRoutines
      .where((routine) => routine.id != widget.excludeRoutineId)
      .toList();

  void _selectRoutine(Routine routine) {
    setState(() {
      _selectedRoutine = routine;
      _selectedExerciseIds.clear();
    });
  }

  void _backToRoutineList() {
    setState(() {
      _selectedRoutine = null;
      _selectedExerciseIds.clear();
    });
  }

  void _toggleExercise(String exerciseId, bool selected) {
    setState(() {
      if (selected) {
        _selectedExerciseIds.add(exerciseId);
      } else {
        _selectedExerciseIds.remove(exerciseId);
      }
    });
  }

  void _toggleSelectAll(List<Exercise> exercises) {
    setState(() {
      if (_selectedExerciseIds.length == exercises.length) {
        _selectedExerciseIds.clear();
      } else {
        _selectedExerciseIds
          ..clear()
          ..addAll(exercises.map((exercise) => exercise.id));
      }
    });
  }

  void _confirmImport(List<Exercise> sourceExercises) {
    if (_selectedExerciseIds.isEmpty) return;
    final imported = forkSelectedExercises(
      sourceExercises,
      _selectedExerciseIds,
      startOrder: 0,
    );
    Navigator.of(context).pop(imported);
  }

  String _routineSubtitle(AppLocalizations l10n, Routine routine) {
    return l10n.routineCountDuration(
      routine.orderedExercises.length,
      formatDurationShort(routineDurationSec(routine), l10n),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;
    final selectedRoutine = _selectedRoutine;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        16 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: SizedBox(
        height: maxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selectedRoutine == null)
              _buildRoutinePicker(context, l10n)
            else
              _buildExercisePicker(context, l10n, selectedRoutine),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutinePicker(BuildContext context, AppLocalizations l10n) {
    final routines = _sourceRoutines;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.importExercisesTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.importExercisesChooseRoutine,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 16),
          if (routines.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  l10n.importExercisesNoOtherRoutines,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: routines.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final routine = routines[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      title: Text(
                        routine.title,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(_routineSubtitle(l10n, routine)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _selectRoutine(routine),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExercisePicker(
    BuildContext context,
    AppLocalizations l10n,
    Routine routine,
  ) {
    final exercises = routine.orderedExercises;
    final allSelected = exercises.isNotEmpty &&
        _selectedExerciseIds.length == exercises.length;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _backToRoutineList,
                icon: const Icon(Icons.arrow_back),
                tooltip: l10n.cancel,
              ),
              Expanded(
                child: Text(
                  routine.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (exercises.isNotEmpty)
                TextButton(
                  onPressed: () => _toggleSelectAll(exercises),
                  child: Text(
                    allSelected
                        ? l10n.importExercisesClearSelection
                        : l10n.importExercisesSelectAll,
                  ),
                ),
            ],
          ),
          if (exercises.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  l10n.importExercisesNoExercisesInRoutine,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: exercises.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final selected = _selectedExerciseIds.contains(exercise.id);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (value) =>
                        _toggleExercise(exercise.id, value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      ExerciseFormatter.displayName(exercise, l10n),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      ExerciseFormatter.listSubtitle(exercise, l10n),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _selectedExerciseIds.isEmpty
                ? null
                : () => _confirmImport(exercises),
            child: Text(
              l10n.importExercisesAddCount(_selectedExerciseIds.length),
            ),
          ),
        ],
      ),
    );
  }
}
