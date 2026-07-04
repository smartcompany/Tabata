import 'package:flutter/material.dart';

import '../data/routine_repository.dart';
import '../screens/workout_screen.dart';
import '../services/workout_completion_recorder.dart';

/// Opens a workout when the user taps a scheduled local notification.
class WorkoutLaunchCoordinator {
  WorkoutLaunchCoordinator({
    required this.navigatorKey,
    required this.repository,
    required this.completionRecorder,
  });

  static const payloadPrefix = 'workout_start:';

  final GlobalKey<NavigatorState> navigatorKey;
  final RoutineRepository repository;
  final WorkoutCompletionRecorder completionRecorder;

  String? _pendingRoutineId;
  bool _homeReady = false;

  void Function(String? payload)? onPayloadOpened;

  void onHomeReady() {
    _homeReady = true;
    _tryLaunchPending();
  }

  void handlePayload(String? payload) {
    if (payload == null || !payload.startsWith(payloadPrefix)) return;
    onPayloadOpened?.call(payload);
    _pendingRoutineId = payload.substring(payloadPrefix.length);
    _tryLaunchPending();
  }

  void _tryLaunchPending() {
    final routineId = _pendingRoutineId;
    if (!_homeReady || routineId == null) return;

    final routine = repository.findById(routineId);
    _pendingRoutineId = null;
    if (routine == null) return;

    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingRoutineId = routineId;
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (_) => WorkoutScreen(
          routine: routine,
          completionRecorder: completionRecorder,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}
