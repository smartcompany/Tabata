import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/description_block.dart';
import '../models/exercise.dart';
import '../models/exercise_phase.dart';
import '../models/phase_config.dart';
import '../utils/duration_calculator.dart';
import '../utils/form_validation_scroll.dart';
import '../widgets/description_blocks_editor.dart';
import '../widgets/duration_input_control.dart';
import '../widgets/exercise_phase_editor_card.dart';
import '../widgets/integer_input_control.dart';
import '../widgets/keyboard_dismiss_scope.dart';

class ExerciseEditorScreen extends StatefulWidget {
  const ExerciseEditorScreen({
    super.key,
    required this.exercise,
    this.isNew = false,
  });

  final Exercise exercise;
  final bool isNew;

  @override
  State<ExerciseEditorScreen> createState() => _ExerciseEditorScreenState();
}

class _ExerciseEditorScreenState extends State<ExerciseEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phasesSectionKey = GlobalKey();
  late final TextEditingController _nameController;
  late List<DescriptionBlock> _instructionBlocks;

  late int _prepareSec;
  late int _reps;
  late int _sets;
  late List<ExercisePhase> _phases;

  @override
  void initState() {
    super.initState();
    final exercise = widget.exercise;
    _nameController = TextEditingController(text: exercise.name);
    _instructionBlocks = _initialInstructionBlocks(exercise);
    _prepareSec = exercise.prepare.durationSec;
    _reps = exercise.reps;
    _sets = exercise.sets;
    _phases = List<ExercisePhase>.from(exercise.orderedPhases);
  }

  List<DescriptionBlock> _initialInstructionBlocks(Exercise exercise) {
    final blocks =
        List<DescriptionBlock>.from(exercise.effectiveInstructionBlocks);
    if (widget.isNew && blocks.isEmpty) {
      return [const TextDescriptionBlock(text: '')];
    }
    if (blocks.length == 1) {
      final only = blocks.first;
      if (only is TextDescriptionBlock && only.text.trim().isEmpty) {
        return [];
      }
    }
    return blocks;
  }

  List<DescriptionBlock> _normalizedInstructionBlocks() {
    return _instructionBlocks.where((block) {
      if (block is TextDescriptionBlock) {
        return block.text.trim().isNotEmpty;
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Exercise get _draft {
    final blocks = _normalizedInstructionBlocks();
    return widget.exercise.copyWith(
      name: _nameController.text.trim(),
      instruction: DescriptionBlock.plainText(blocks),
      instructionBlocks: blocks,
      prepare: TimedPhase(durationSec: _prepareSec),
      phases: reindexPhases(_phases),
      reps: _reps,
      sets: _sets,
    );
  }

  int get _oneSetSec => _prepareSec + repDurationSec(_draft);

  void _addPhase(ExercisePhaseKind kind) {
    KeyboardDismissScope.dismiss(context);
    setState(() {
      _phases = [
        ..._phases,
        createEmptyPhase(kind: kind, order: _phases.length),
      ];
    });
  }

  void _updatePhase(int index, ExercisePhase phase) {
    setState(() {
      final updated = List<ExercisePhase>.from(_phases);
      updated[index] = phase;
      _phases = updated;
    });
  }

  void _deletePhase(int index) {
    KeyboardDismissScope.dismiss(context);
    setState(() {
      final updated = List<ExercisePhase>.from(_phases)..removeAt(index);
      _phases = reindexPhases(updated);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    KeyboardDismissScope.dismiss(context);
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final updated = List<ExercisePhase>.from(_phases);
      final item = updated.removeAt(oldIndex);
      updated.insert(newIndex, item);
      _phases = reindexPhases(updated);
    });
  }

  void _save() {
    if (!validateFormAndScrollToError(_formKey)) return;
    if (_phases.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.requireAtLeastOnePhase)),
      );
      scrollToKey(_phasesSectionKey);
      return;
    }
    Navigator.of(context).pop(_draft);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isNew ? l10n.addExerciseTitle : l10n.editExerciseTitle,
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: KeyboardDismissScope(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _sectionTitle(l10n.basicInfoSection),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.exerciseNameLabel,
                  hintText: l10n.exerciseNameHint,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onEditingComplete: () => KeyboardDismissScope.dismiss(context),
                onTapOutside: (_) => KeyboardDismissScope.dismiss(context),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.validationNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DescriptionBlocksEditor(
                routineId: widget.exercise.id,
                blocks: _instructionBlocks,
                onChanged: (blocks) =>
                    setState(() => _instructionBlocks = blocks),
              ),
              const SizedBox(height: 24),
              _sectionTitle(l10n.prepareSection),
              DurationInputControl(
                valueSec: _prepareSec,
                minSec: 0,
                maxSec: 120,
                pickerTitle: l10n.prepareSection,
                onChanged: (value) => setState(() => _prepareSec = value),
              ),
              const SizedBox(height: 24),
              Row(
                key: _phasesSectionKey,
                children: [
                  Expanded(child: _sectionTitle(l10n.phasesSection)),
                  Text(
                    l10n.reorderPhasesHint,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _phases.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final phase = _phases[index];
                  return ExercisePhaseEditorCard(
                    key: ValueKey(phase.id),
                    phase: phase,
                    index: index,
                    canDelete: _phases.length > 1,
                    onChanged: (updated) => _updatePhase(index, updated),
                    onDelete: () => _deletePhase(index),
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _addPhase(ExercisePhaseKind.work),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addWorkPhase),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _addPhase(ExercisePhaseKind.relax),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addRelaxPhase),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle(l10n.repeatSection),
              Text(
                l10n.labelReps,
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
              const SizedBox(height: 8),
              IntegerInputControl(
                value: _reps,
                min: 1,
                max: 99,
                pickerTitle: l10n.labelReps,
                unitLabel: l10n.unitReps,
                hintText: l10n.tapToSetReps,
                onChanged: (value) => setState(() => _reps = value),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.labelSets,
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
              const SizedBox(height: 8),
              IntegerInputControl(
                value: _sets,
                min: 1,
                max: 20,
                pickerTitle: l10n.labelSets,
                unitLabel: l10n.unitSets,
                hintText: l10n.tapToSetSets,
                onChanged: (value) => setState(() => _sets = value),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.previewSection,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.oneSetDuration(formatDuration(_oneSetSec, l10n))),
                      Text(
                        l10n.totalDuration(
                          formatDuration(
                            _prepareSec + repDurationSec(_draft) * _reps * _sets,
                            l10n,
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
