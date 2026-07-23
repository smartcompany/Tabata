import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/exercise_limits.dart';
import '../models/exercise_phase.dart';
import '../utils/exercise_formatter.dart';
import 'duration_input_control.dart';
import 'integer_input_control.dart';

class ExercisePhaseEditorCard extends StatefulWidget {
  const ExercisePhaseEditorCard({
    super.key,
    required this.phase,
    required this.index,
    required this.onChanged,
    required this.onDelete,
    this.canDelete = true,
  });

  final ExercisePhase phase;
  final int index;
  final ValueChanged<ExercisePhase> onChanged;
  final VoidCallback onDelete;
  final bool canDelete;

  @override
  State<ExercisePhaseEditorCard> createState() => _ExercisePhaseEditorCardState();
}

class _ExercisePhaseEditorCardState extends State<ExercisePhaseEditorCard> {
  late final TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.phase.label);
  }

  @override
  void didUpdateWidget(covariant ExercisePhaseEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase.id != widget.phase.id &&
        _labelController.text != widget.phase.label) {
      _labelController.text = widget.phase.label;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _emit({
    String? label,
    int? durationSec,
    PhaseTimingMode? timingMode,
    int? countReps,
    int? secondsPerRep,
    CountOrder? countOrder,
  }) {
    widget.onChanged(
      widget.phase.copyWith(
        label: label ?? _labelController.text.trim(),
        durationSec: durationSec ?? widget.phase.durationSec,
        timingMode: timingMode ?? widget.phase.timingMode,
        countReps: countReps ?? widget.phase.countReps,
        secondsPerRep: secondsPerRep ?? widget.phase.secondsPerRep,
        countOrder: countOrder ?? widget.phase.countOrder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final kindLabel =
        ExerciseFormatter.phaseKindLabel(widget.phase.kind, l10n);
    final kindColor = widget.phase.kind == ExercisePhaseKind.work
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final needsLabel = _labelController.text.trim().isEmpty;
    final labelPromptColor = needsLabel
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Card(
      key: widget.key,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: widget.index,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.drag_handle),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kindColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    kindLabel,
                    style: TextStyle(
                      color: kindColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.canDelete)
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: l10n.phaseLabel,
                labelStyle: TextStyle(color: labelPromptColor),
                floatingLabelStyle: TextStyle(color: labelPromptColor),
                hintText: widget.phase.kind == ExercisePhaseKind.work
                    ? l10n.workLabelHint
                    : l10n.relaxLabelHint,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
                ),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validationLabelRequired;
                }
                return null;
              },
              onChanged: (_) {
                setState(() {});
                _emit();
              },
            ),
            if (widget.phase.kind == ExercisePhaseKind.work ||
                widget.phase.kind == ExercisePhaseKind.relax) ...[
              const SizedBox(height: 12),
              SegmentedButton<PhaseTimingMode>(
                segments: [
                  ButtonSegment(
                    value: PhaseTimingMode.duration,
                    label: Text(l10n.phaseTimingModeDuration),
                  ),
                  ButtonSegment(
                    value: PhaseTimingMode.count,
                    label: Text(l10n.phaseTimingModeCount),
                  ),
                ],
                selected: {widget.phase.timingMode},
                onSelectionChanged: (selection) {
                  final mode = selection.first;
                  if (mode == PhaseTimingMode.count &&
                      widget.phase.timingMode != PhaseTimingMode.count) {
                    _emit(
                      timingMode: mode,
                      countOrder: CountOrder.descending,
                    );
                  } else {
                    _emit(timingMode: mode);
                  }
                },
              ),
            ],
            if (widget.phase.isCountMode) ...[
              const SizedBox(height: 12),
              Text(
                l10n.countOrderLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<CountOrder>(
                segments: [
                  ButtonSegment(
                    value: CountOrder.ascending,
                    label: Text(l10n.countOrderAscending),
                  ),
                  ButtonSegment(
                    value: CountOrder.descending,
                    label: Text(l10n.countOrderDescending),
                  ),
                ],
                selected: {widget.phase.countOrder},
                onSelectionChanged: (selection) {
                  _emit(countOrder: selection.first);
                },
              ),
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.countSettingsTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.labelPhaseCount,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      IntegerInputControl(
                        value: widget.phase.countReps,
                        min: ExerciseLimits.minCountReps,
                        max: ExerciseLimits.maxCountReps,
                        pickerTitle: l10n.labelPhaseCount,
                        unitLabel: l10n.unitReps,
                        hintText: l10n.tapToSetPhaseCount,
                        onChanged: (value) => _emit(countReps: value),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.labelSecondsPerRep,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DurationInputControl(
                        valueSec: widget.phase.secondsPerRep,
                        minSec: ExerciseLimits.minSecondsPerRep,
                        maxSec: ExerciseLimits.maxSecondsPerRep,
                        pickerTitle: l10n.labelSecondsPerRep,
                        onChanged: (value) => _emit(secondsPerRep: value),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              DurationInputControl(
                valueSec: widget.phase.durationSec,
                minSec: ExerciseLimits.minWorkRelaxDurationSec,
                maxSec: 120,
                pickerTitle: kindLabel,
                onChanged: (value) => _emit(durationSec: value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
