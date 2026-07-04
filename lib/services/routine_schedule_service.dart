import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:tabata_timer/l10n/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/routine_schedule_repository.dart';
import '../models/routine.dart';
import '../models/routine_schedule.dart';
import '../models/schedule_recurrence.dart';
import '../utils/routine_schedule_format.dart';
import 'routine_schedule_foreground_alerts.dart';
import 'workout_launch_coordinator.dart';

class RoutineScheduleService {
  RoutineScheduleService._();

  static final shared = RoutineScheduleService._();

  static const _channelId = 'routine_workout_reminder_v2';
  static const _channelName = 'Workout reminders';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  late RoutineScheduleRepository _scheduleRepository;
  late WorkoutLaunchCoordinator _launchCoordinator;
  RoutineScheduleForegroundAlerts? _foregroundAlerts;
  bool _initialized = false;

  Future<void> configure({
    required RoutineScheduleRepository scheduleRepository,
    required WorkoutLaunchCoordinator launchCoordinator,
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    if (_initialized) return;

    _scheduleRepository = scheduleRepository;
    _launchCoordinator = launchCoordinator;

    tz.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.local);
    }

    if (kIsWeb) return;

    _foregroundAlerts = RoutineScheduleForegroundAlerts(
      navigatorKey: navigatorKey,
      scheduleRepository: _scheduleRepository,
      launchCoordinator: _launchCoordinator,
    );
    _launchCoordinator.onPayloadOpened =
        _foregroundAlerts!.acknowledgeNotificationPayload;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );

    await _notifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        _launchCoordinator.handlePayload(response.payload);
      },
    );

    final launchDetails =
        await _notifications.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _launchCoordinator.handlePayload(
        launchDetails!.notificationResponse?.payload,
      );
    }

    if (Platform.isAndroid) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Reminders for scheduled workouts',
          importance: Importance.max,
        ),
      );
    }

    _foregroundAlerts!.start();

    _initialized = true;
    await syncAllSchedules();
  }

  bool get isSupported => !kIsWeb;

  RoutineSchedule? scheduleFor(String routineId) =>
      _scheduleRepository.forRoutine(routineId);

  Future<bool> requestPermissions() async {
    if (!isSupported) return false;

    if (Platform.isAndroid) {
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted =
          await androidPlugin?.requestNotificationsPermission() ?? false;
      if (!granted) return false;
      await androidPlugin?.requestExactAlarmsPermission();
      return true;
    }

    if (Platform.isIOS || Platform.isMacOS) {
      final iosPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
      return granted;
    }

    return true;
  }

  void onAppLifecycleState(AppLifecycleState state) {
    final alerts = _foregroundAlerts;
    if (alerts == null) return;
    if (state == AppLifecycleState.resumed) {
      alerts.start();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      alerts.stop();
    }
  }

  Future<bool> scheduleWorkout({
    required Routine routine,
    required RoutineSchedule schedule,
    required AppLocalizations l10n,
  }) async {
    if (!isSupported) return false;

    final now = DateTime.now();
    if (schedule.isExpired(now)) return false;
    if (schedule.recurrence == ScheduleRecurrence.none &&
        !schedule.scheduledAt.isAfter(now)) {
      return false;
    }

    final permitted = await requestPermissions();
    if (!permitted) return false;

    await _scheduleRepository.upsert(schedule);
    await _scheduleNotification(schedule, l10n);
    return true;
  }

  Future<void> cancelForRoutine(String routineId) async {
    if (!isSupported) return;
    await _scheduleRepository.remove(routineId);
    await _notifications.cancel(id: _notificationIdFor(routineId));
  }

  Future<void> syncAllSchedules() async {
    if (!isSupported || !_initialized) return;

    final now = DateTime.now();
    for (final schedule in _scheduleRepository.all()) {
      if (schedule.isExpired(now)) {
        await _scheduleRepository.remove(schedule.routineId);
        await _notifications.cancel(id: _notificationIdFor(schedule.routineId));
      }
    }

    for (final schedule in _scheduleRepository.all()) {
      await _scheduleNotification(schedule, null);
    }
  }

  Future<void> _scheduleNotification(
    RoutineSchedule schedule,
    AppLocalizations? l10n,
  ) async {
    final id = _notificationIdFor(schedule.routineId);
    final title = l10n?.scheduleWorkoutNotificationTitle ?? 'Time to work out';
    final body = l10n != null
        ? l10n.scheduleWorkoutNotificationBody(schedule.routineTitle)
        : schedule.routineTitle;

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: notificationScheduledDate(schedule),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Reminders for scheduled workouts',
          importance: Importance.max,
          priority: Priority.max,
          visibility: NotificationVisibility.public,
          category: AndroidNotificationCategory.reminder,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          presentBanner: true,
          presentList: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchComponentsFor(schedule.recurrence),
      payload: '${WorkoutLaunchCoordinator.payloadPrefix}${schedule.routineId}',
    );
  }

  int _notificationIdFor(String routineId) => routineId.hashCode & 0x7FFFFFFF;
}
