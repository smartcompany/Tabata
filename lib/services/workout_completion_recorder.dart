import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../data/workout_history_repository.dart';
import '../models/health_activity_type.dart';
import '../models/routine.dart';
import '../models/workout_session_record.dart';
import 'health_workout_recorder.dart';
import 'workout_settings.dart';

const _uuid = Uuid();

/// Saves every completed workout locally and optionally syncs to Health.
class WorkoutCompletionRecorder {
  WorkoutCompletionRecorder(this._historyRepository);

  final WorkoutHistoryRepository _historyRepository;

  Future<void> recordCompletedWorkout({
    required BuildContext context,
    required Routine routine,
    required int elapsedSec,
  }) async {
    if (elapsedSec <= 0) return;

    final end = DateTime.now();
    final start = end.subtract(Duration(seconds: elapsedSec));
    final sessionId = _uuid.v4();

    final session = WorkoutSessionRecord(
      id: sessionId,
      routineId: routine.id,
      routineTitle: routine.title,
      startedAt: start,
      endedAt: end,
      durationSec: elapsedSec,
      exerciseCount: routine.exercises.length,
      healthActivityType: routine.healthActivityType,
    );
    await _historyRepository.add(session);

    if (routine.healthActivityType == null) return;

    final settings = await WorkoutSettings.load();
    if (!settings.saveToAppleHealth) return;

    final saved = await HealthWorkoutRecorder.recordCompletedWorkout(
      routine: routine,
      start: start,
      end: end,
    );
    if (saved) {
      await _historyRepository.updateHealthSynced(sessionId, true);
    }

    if (!context.mounted || !saved) return;

    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.healthWorkoutSavedSnack(
            RoutineHealthActivityType.labelFor(
              l10n,
              routine.healthActivityType!,
            ),
          ),
        ),
      ),
    );
  }
}
