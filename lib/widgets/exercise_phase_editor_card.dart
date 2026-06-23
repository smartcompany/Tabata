import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/exercise_phase.dart';
import '../utils/exercise_formatter.dart';
import 'duration_input_control.dart';

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

  void _emit({String? label, int? durationSec}) {
    widget.onChanged(
      widget.phase.copyWith(
        label: label ?? _labelController.text.trim(),
        durationSec: durationSec ?? widget.phase.durationSec,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kindLabel =
        ExerciseFormatter.phaseKindLabel(widget.phase.kind, l10n);
    final kindColor = widget.phase.kind == ExercisePhaseKind.work
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

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
                hintText: widget.phase.kind == ExercisePhaseKind.work
                    ? l10n.workLabelHint
                    : l10n.relaxLabelHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validationLabelRequired;
                }
                return null;
              },
              onChanged: (_) => _emit(),
            ),
            const SizedBox(height: 8),
            DurationInputControl(
              valueSec: widget.phase.durationSec,
              minSec: 1,
              maxSec: 120,
              pickerTitle: kindLabel,
              onChanged: (value) => _emit(durationSec: value),
            ),
          ],
        ),
      ),
    );
  }
}
