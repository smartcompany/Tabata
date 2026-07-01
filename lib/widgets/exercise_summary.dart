import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/exercise.dart';
import '../utils/duration_calculator.dart';
import '../utils/exercise_formatter.dart';
import 'description_blocks_view.dart';

class ExerciseDetailCard extends StatefulWidget {
  const ExerciseDetailCard({
    super.key,
    required this.exercise,
    this.onEdit,
    this.onStart,
  });

  final Exercise exercise;
  final VoidCallback? onEdit;
  final VoidCallback? onStart;

  @override
  State<ExerciseDetailCard> createState() => _ExerciseDetailCardState();
}

class _ExerciseDetailCardState extends State<ExerciseDetailCard> {
  bool _detailsExpanded = false;

  void _toggleDetails() {
    setState(() => _detailsExpanded = !_detailsExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final exercise = widget.exercise;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (exercise.effectiveInstructionBlocks.isNotEmpty) ...[
          const SizedBox(height: 6),
          DescriptionBlocksView(blocks: exercise.effectiveInstructionBlocks),
        ],
      ],
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _toggleDetails,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: header),
                  Icon(
                    _detailsExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
              if (_detailsExpanded) ...[
                const SizedBox(height: 12),
                _infoRow(
                  context,
                  l10n.labelPrepare,
                  l10n.durationSeconds(exercise.prepare.durationSec),
                ),
                ...exercise.orderedPhases.map(
                  (phase) => _infoRow(
                    context,
                    ExerciseFormatter.phaseKindLabel(phase.kind, l10n),
                    ExerciseFormatter.phaseWithDuration(
                      phase.label,
                      phase.durationSec,
                      l10n,
                    ),
                  ),
                ),
                _infoRow(
                  context,
                  l10n.labelReps,
                  l10n.countReps(exercise.reps),
                ),
                _infoRow(
                  context,
                  l10n.labelSets,
                  l10n.countSets(exercise.sets),
                ),
                const SizedBox(height: 8),
                Text(
                  ExerciseFormatter.oneSetDuration(exercise, l10n),
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ],
              if (widget.onEdit != null || widget.onStart != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Spacer(),
                    if (widget.onEdit != null)
                      OutlinedButton.icon(
                        onPressed: widget.onEdit,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(l10n.editTooltip),
                      ),
                    if (widget.onEdit != null && widget.onStart != null)
                      const SizedBox(width: 8),
                    if (widget.onStart != null)
                      FilledButton.icon(
                        onPressed: widget.onStart,
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: Text(l10n.start),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class ExerciseListTileCard extends StatelessWidget {
  const ExerciseListTileCard({
    super.key,
    required this.exercise,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  final Exercise exercise;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
        leading: ReorderableDragStartListener(
          index: index,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.drag_handle),
          ),
        ),
        title: Text(
          ExerciseFormatter.displayName(exercise, l10n),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(ExerciseFormatter.listSubtitle(exercise, l10n)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}

class EstimatedDurationCard extends StatelessWidget {
  const EstimatedDurationCard({super.key, required this.totalSec});

  final int totalSec;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.schedule_outlined),
            const SizedBox(width: 12),
            Text(
              l10n.estimatedDuration(formatDuration(totalSec, l10n)),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
