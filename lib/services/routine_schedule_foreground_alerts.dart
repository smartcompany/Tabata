import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';

import '../data/routine_schedule_repository.dart';
import '../models/routine_schedule.dart';
import '../models/schedule_recurrence.dart';
import 'workout_launch_coordinator.dart';

/// Shows an in-app banner when a scheduled workout is due while the app is open.
class RoutineScheduleForegroundAlerts {
  RoutineScheduleForegroundAlerts({
    required this.navigatorKey,
    required this.scheduleRepository,
    required this.launchCoordinator,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final RoutineScheduleRepository scheduleRepository;
  final WorkoutLaunchCoordinator launchCoordinator;

  Timer? _timer;
  final Set<String> _shownKeys = {};

  static const _tickInterval = Duration(seconds: 5);
  static const _dueWindow = Duration(seconds: 90);

  void start() {
    _timer ??= Timer.periodic(_tickInterval, (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }

    final now = DateTime.now();
    for (final schedule in scheduleRepository.all()) {
      final fireTime = _dueFireTime(schedule, now);
      if (fireTime == null) continue;

      final key = _keyFor(schedule.routineId, fireTime);
      if (_shownKeys.contains(key)) continue;
      _shownKeys.add(key);
      _showBanner(schedule);
    }
  }

  /// Call when the user opens a scheduled workout from a system notification.
  void acknowledgeNotificationPayload(String? payload) {
    if (payload == null || !payload.startsWith(WorkoutLaunchCoordinator.payloadPrefix)) {
      return;
    }

    final routineId =
        payload.substring(WorkoutLaunchCoordinator.payloadPrefix.length);
    final schedule = scheduleRepository.forRoutine(routineId);
    if (schedule != null) {
      final fireTime = _dueFireTime(schedule, DateTime.now());
      if (fireTime != null) {
        _shownKeys.add(_keyFor(routineId, fireTime));
      }
    }

    _dismissBanner();
  }

  String _keyFor(String routineId, DateTime fireTime) =>
      '$routineId:${fireTime.toIso8601String()}';

  void _dismissBanner() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    ScaffoldMessenger.maybeOf(context)?.hideCurrentMaterialBanner();
  }

  DateTime? _dueFireTime(RoutineSchedule schedule, DateTime now) {
    if (!schedule.isActiveAt(now)) return null;

    if (schedule.recurrence == ScheduleRecurrence.none) {
      final at = schedule.scheduledAt;
      if (now.isBefore(at)) return null;
      if (now.difference(at) > _dueWindow) return null;
      return at;
    }

    final probe = now.subtract(const Duration(minutes: 3));
    final occurrence = schedule.nextOccurrence(probe);
    if (now.isBefore(occurrence)) return null;
    if (now.difference(occurrence) > _dueWindow) return null;
    return occurrence;
  }

  void _showBanner(RoutineSchedule schedule) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentMaterialBanner();
    messenger.showMaterialBanner(
      MaterialBanner(
        content: Text(l10n.scheduleWorkoutNotificationBody(schedule.routineTitle)),
        leading: const Icon(Icons.notifications_active),
        actions: [
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
              launchCoordinator.handlePayload(
                '${WorkoutLaunchCoordinator.payloadPrefix}${schedule.routineId}',
              );
            },
            child: Text(l10n.startAll),
          ),
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
