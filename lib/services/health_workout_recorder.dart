import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../models/routine.dart';
import 'health_activity_catalog.dart';
import 'workout_settings.dart';

/// Saves completed Tabata workouts to Apple Health (iOS) or Health Connect (Android).
abstract final class HealthWorkoutRecorder {
  static final Health _health = Health();
  static var _configured = false;

  static const _workoutTypes = [HealthDataType.WORKOUT];

  static List<HealthDataAccess> get _workoutPermissions =>
      Platform.isAndroid ? [HealthDataAccess.WRITE] : [HealthDataAccess.READ_WRITE];

  static bool get isSupported =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  static Future<bool> isHealthAppReady() async {
    if (!isSupported) return false;
    await _ensureConfigured();
    if (Platform.isIOS) return true;
    return _health.isHealthConnectAvailable();
  }

  static Future<void> promptInstallHealthConnect() async {
    if (!Platform.isAndroid) return;
    await _ensureConfigured();
    await _health.installHealthConnect();
  }

  static Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// Android: Health Connect 쓰기 권한 실제 부여 여부. iOS: 확인 불가(null) → true 취급.
  static Future<bool> hasWritePermission() async {
    if (!isSupported) return false;
    try {
      await _ensureConfigured();
      if (Platform.isAndroid && !await _health.isHealthConnectAvailable()) {
        return false;
      }
      final granted = await _health.hasPermissions(
        _workoutTypes,
        permissions: _workoutPermissions,
      );
      if (Platform.isIOS) return granted ?? true;
      return granted == true;
    } on UnsupportedError catch (error, stackTrace) {
      debugPrint('[HealthWorkoutRecorder] hasWritePermission: $error');
      debugPrint('$stackTrace');
      return false;
    }
  }

  static Future<bool> requestWritePermission() async {
    if (!isSupported) return false;
    try {
      await _ensureConfigured();
      if (Platform.isAndroid && !await _health.isHealthConnectAvailable()) {
        return false;
      }
      await _health.requestAuthorization(
        _workoutTypes,
        permissions: _workoutPermissions,
      );
      return hasWritePermission();
    } on UnsupportedError catch (error, stackTrace) {
      debugPrint('[HealthWorkoutRecorder] requestWritePermission: $error');
      debugPrint('$stackTrace');
      return false;
    }
  }

  static Future<bool> recordCompletedWorkout({
    required Routine routine,
    required DateTime start,
    required DateTime end,
  }) async {
    if (!isSupported) return false;

    final settings = await WorkoutSettings.load();
    if (!settings.saveToHealthApp) {
      debugPrint('[HealthWorkoutRecorder] saveToHealthApp is off');
      return false;
    }

    final activityType = HealthActivityCatalog.toWorkoutType(
      routine.healthActivityType,
    );
    if (activityType == null) {
      debugPrint(
        '[HealthWorkoutRecorder] Unknown activity type: ${routine.healthActivityType}',
      );
      return false;
    }

    if (!end.isAfter(start)) return false;

    try {
      await _ensureConfigured();
      if (Platform.isAndroid && !await _health.isHealthConnectAvailable()) {
        debugPrint('[HealthWorkoutRecorder] Health Connect unavailable');
        return false;
      }

      if (!await hasWritePermission()) {
        final granted = await requestWritePermission();
        if (!granted) {
          debugPrint('[HealthWorkoutRecorder] Write permission not granted');
          return false;
        }
      }

      final saved = await _health.writeWorkoutData(
        activityType: activityType,
        start: start,
        end: end,
        title: routine.title,
        recordingMethod: RecordingMethod.manual,
      );
      if (!saved) {
        debugPrint('[HealthWorkoutRecorder] writeWorkoutData returned false');
      }
      return saved;
    } catch (error, stackTrace) {
      debugPrint('[HealthWorkoutRecorder] Failed to save workout: $error');
      debugPrint('$stackTrace');
      return false;
    }
  }
}
