import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../models/health_activity_type.dart';
import '../models/routine.dart';
import 'workout_settings.dart';

/// Saves completed Tabata workouts to Apple Health (iOS) or Health Connect (Android).
abstract final class HealthWorkoutRecorder {
  static final Health _health = Health();
  static var _configured = false;

  static bool get isSupported =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  static Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  static Future<bool> requestWritePermission() async {
    if (!isSupported) return false;
    await _ensureConfigured();
    return _health.requestAuthorization(
      [HealthDataType.WORKOUT],
      permissions: [HealthDataAccess.READ_WRITE],
    );
  }

  static Future<bool> recordCompletedWorkout({
    required Routine routine,
    required DateTime start,
    required DateTime end,
  }) async {
    if (!isSupported) return false;

    final settings = await WorkoutSettings.load();
    if (!settings.saveToHealthApp) return false;

    final activity = RoutineHealthActivityType.fromId(routine.healthActivityType);
    if (activity == null) return false;

    if (!end.isAfter(start)) return false;

    await _ensureConfigured();
    final authorized = await _health.requestAuthorization(
      [HealthDataType.WORKOUT],
      permissions: [HealthDataAccess.READ_WRITE],
    );
    if (!authorized) return false;

    try {
      return await _health.writeWorkoutData(
        activityType: activity.toHealthWorkoutType(),
        start: start,
        end: end,
        title: routine.title,
        recordingMethod: RecordingMethod.manual,
      );
    } catch (error, stackTrace) {
      debugPrint('[HealthWorkoutRecorder] Failed to save workout: $error');
      debugPrint('$stackTrace');
      return false;
    }
  }
}
