import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../models/exercise.dart';
import '../utils/duration_calculator.dart';
import '../utils/exercise_formatter.dart';

class ExerciseDetailCard extends StatelessWidget {
  const ExerciseDetailCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  final Exercise exercise;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (exercise.instruction.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(exercise.instruction),
          ],
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
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: content,
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
