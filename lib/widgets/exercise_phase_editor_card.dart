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
  late final FocusNode _labelFocus;
  var _didNormalizeLabel = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.phase.label);
    _labelFocus = FocusNode();
    _labelFocus.addListener(() => setState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didNormalizeLabel) return;
    _didNormalizeLabel = true;
    _syncLabelFromPhase(widget.phase);
  }

  @override
  void didUpdateWidget(covariant ExercisePhaseEditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase.id != widget.phase.id) {
      _syncLabelFromPhase(widget.phase);
    }
  }

  @override
  void dispose() {
    _labelFocus.dispose();
    _labelController.dispose();
    super.dispose();
  }

  void _syncLabelFromPhase(ExercisePhase phase) {
    final l10n = AppLocalizations.of(context);
    _labelController.text =
        ExerciseFormatter.isUnsetOrKindPhaseLabel(phase.label, phase.kind, l10n)
            ? ''
            : phase.label;
  }

  void _emit({
    String? label,
    int? durationSec,
    PhaseTimingMode? timingMode,
    int? countReps,
    int? secondsPerRep,
  }) {
    final relax = widget.phase.kind == ExercisePhaseKind.relax;
    widget.onChanged(
      widget.phase.copyWith(
        label: label ?? _labelController.text.trim(),
        durationSec: durationSec ??
            (relax && widget.phase.isCountMode
                ? widget.phase.effectiveDurationSec
                : widget.phase.durationSec),
        timingMode: relax
            ? PhaseTimingMode.duration
            : (timingMode ?? widget.phase.timingMode),
        countReps: countReps ?? widget.phase.countReps,
        secondsPerRep: secondsPerRep ?? widget.phase.secondsPerRep,
        countOrder: CountOrder.descending,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final kindLabel =
        ExerciseFormatter.phaseKindLabel(widget.phase.kind, l10n);
    final focused = _labelFocus.hasFocus;

    return Card(
      key: widget.key,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
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
                Expanded(
                  child: TextFormField(
                    controller: _labelController,
                    focusNode: _labelFocus,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      labelText: focused ? l10n.phaseLabel : null,
                      floatingLabelBehavior: focused
                          ? FloatingLabelBehavior.always
                          : FloatingLabelBehavior.never,
                      hintText: focused
                          ? (widget.phase.kind == ExercisePhaseKind.work
                              ? l10n.workLabelHint
                              : l10n.relaxLabelHint)
                          : kindLabel,
                      hintStyle: TextStyle(
                        color: focused
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                            : theme.colorScheme.onSurface,
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => _emit(),
                  ),
                ),
                if (widget.canDelete)
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            if (widget.phase.kind == ExercisePhaseKind.work) ...[
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
                  _emit(timingMode: selection.first);
                },
              ),
            ],
            if (widget.phase.kind == ExercisePhaseKind.work &&
                widget.phase.isCountMode) ...[
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
                valueSec: widget.phase.kind == ExercisePhaseKind.relax &&
                        widget.phase.isCountMode
                    ? widget.phase.effectiveDurationSec
                    : widget.phase.durationSec,
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
