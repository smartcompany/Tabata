import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

import '../data/workout_history_repository.dart';
import '../models/routine.dart';
import 'health_activity_catalog.dart';
import '../models/workout_session_record.dart';
import '../utils/health_platform_l10n.dart';
import 'health_workout_recorder.dart';
import 'app_analytics_service.dart';
import 'app_review_service.dart';
import 'workout_settings.dart';

const _uuid = Uuid();

/// Saves every completed workout locally and optionally syncs to Health.
class WorkoutCompletionRecorder {
  WorkoutCompletionRecorder(this._historyRepository);

  final WorkoutHistoryRepository _historyRepository;

  bool get hasCompletedWorkout => _historyRepository.allRecords.isNotEmpty;

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

    await AppAnalyticsService.logWorkoutComplete(
      durationSec: elapsedSec,
      exerciseCount: routine.exercises.length,
      routineId: routine.id,
    );

    unawaited(AppReviewService.onWorkoutCompleted());

    if (routine.healthActivityType == null) return;

    final settings = await WorkoutSettings.load();
    if (!settings.saveToHealthApp) return;

    final saved = await HealthWorkoutRecorder.recordCompletedWorkout(
      routine: routine,
      start: start,
      end: end,
    );
    if (saved) {
      await _historyRepository.updateHealthSynced(sessionId, true);
    }
    await AppAnalyticsService.logProductEvent(
      saved
          ? 'health_workout_sync_succeeded'
          : 'health_workout_sync_failed',
      properties: {
        'platform': Platform.isIOS ? 'ios' : 'android',
      },
    );

    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final platform = HealthPlatformL10n(l10n);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved
              ? platform.workoutSavedSnack(
                  HealthActivityCatalog.labelFor(
                    l10n,
                    routine.healthActivityType!,
                  ),
                )
              : platform.workoutSaveFailedSnack,
        ),
      ),
    );
  }
}
