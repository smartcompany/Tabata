import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../data/routine_repository.dart';
import '../engine/workout_timer_engine.dart';
import '../engine/workout_timer_labels.dart';
import '../screens/workout_screen.dart';
import '../services/watch_workout_bridge.dart';
import '../services/workout_completion_recorder.dart';

/// Opens a workout from scheduled notifications or Apple Watch.
class WorkoutLaunchCoordinator {
  WorkoutLaunchCoordinator({
    required this.navigatorKey,
    required this.repository,
    required this.completionRecorder,
  });

  static const payloadPrefix = 'workout_start:';
  static const _dedupeWindow = Duration(seconds: 2);
  static const _watchStartLabels = WorkoutTimerLabels(
    prepare: '준비',
    completedMessage: '완료',
  );

  final GlobalKey<NavigatorState> navigatorKey;
  final RoutineRepository repository;
  final WorkoutCompletionRecorder completionRecorder;

  String? _pendingRoutineId;
  bool _homeReady = false;
  bool _launchScheduled = false;
  int _launchRetryCount = 0;
  String? _lastStartId;
  DateTime? _lastStartAt;

  void Function(String? payload)? onPayloadOpened;

  void onHomeReady() {
    _homeReady = true;
    _tryLaunchPending();
  }

  void handlePayload(String? payload) {
    if (payload == null || !payload.startsWith(payloadPrefix)) return;
    onPayloadOpened?.call(payload);
    startRoutine(payload.substring(payloadPrefix.length));
  }

  /// Starts a full routine (e.g. from Apple Watch list selection).
  /// Safe to call while the phone app is backgrounded / cold-starting.
  void startRoutine(String routineId) {
    final now = DateTime.now();
    final isRestart = WorkoutScreen.isActive;
    if (!isRestart &&
        _lastStartId == routineId &&
        _lastStartAt != null &&
        now.difference(_lastStartAt!) < _dedupeWindow) {
      debugPrint(
        'WorkoutLaunchCoordinator: ignore duplicate start id=$routineId',
      );
      return;
    }
    _lastStartId = routineId;
    _lastStartAt = now;

    debugPrint(
      'WorkoutLaunchCoordinator.startRoutine id=$routineId '
      'homeReady=$_homeReady active=${WorkoutScreen.isActive}',
    );

    _pendingRoutineId = routineId;
    _launchRetryCount = 0;
    _tryLaunchPending();
  }

  void _tryLaunchPending() {
    final routineId = _pendingRoutineId;
    if (!_homeReady || routineId == null) return;

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _scheduleLaunchRetry();
      return;
    }

    // After Watch "end", the workout route may still be mounted briefly while
    // backgrounded. Pop it and retry instead of dropping the new start.
    if (WorkoutScreen.isActive) {
      debugPrint(
        'WorkoutLaunchCoordinator: popping active workout before restart',
      );
      if (navigator.canPop()) {
        navigator.pop();
      }
      SchedulerBinding.instance.scheduleWarmUpFrame();
      SchedulerBinding.instance.scheduleFrame();
      _scheduleLaunchRetry();
      return;
    }

    final routine = repository.findById(routineId);
    if (routine == null) {
      debugPrint('WorkoutLaunchCoordinator: routine not found id=$routineId');
      _pendingRoutineId = null;
      unawaited(WatchWorkoutBridge.instance.notifyStartFailed());
      return;
    }

    // Push a snapshot immediately so the Watch leaves "시작하는 중…" even when
    // the phone is backgrounded and WorkoutScreen has not painted a frame yet.
    final bootstrap = WorkoutTimerEngine(routine, labels: _watchStartLabels);
    unawaited(
      WatchWorkoutBridge.instance.syncSnapshot(
        bootstrap.snapshot,
        healthActivityType: routine.healthActivityType,
        force: true,
      ),
    );
    bootstrap.dispose();

    _pendingRoutineId = null;
    _launchScheduled = false;
    _launchRetryCount = 0;
    navigator.push(
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(
          routine: routine,
          repository: repository,
          completionRecorder: completionRecorder,
        ),
        fullscreenDialog: true,
      ),
    );
    SchedulerBinding.instance.scheduleWarmUpFrame();
    SchedulerBinding.instance.scheduleFrame();
  }

  void _scheduleLaunchRetry() {
    if (_launchRetryCount >= 40) {
      debugPrint('WorkoutLaunchCoordinator: launch retries exhausted');
      final id = _pendingRoutineId;
      _pendingRoutineId = null;
      _launchScheduled = false;
      if (id != null) {
        unawaited(WatchWorkoutBridge.instance.notifyStartFailed());
      }
      return;
    }
    if (_launchScheduled) return;
    _launchScheduled = true;
    _launchRetryCount++;
    SchedulerBinding.instance.scheduleFrame();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _launchScheduled = false;
      _tryLaunchPending();
    });
  }
}
