import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../engine/workout_timer_engine.dart';
import '../models/routine.dart';

/// Flutter ↔ iOS WatchConnectivity bridge for workout mirroring.
class WatchWorkoutBridge {
  WatchWorkoutBridge._();

  static const _channel = MethodChannel('com.smartcompany.tabata/watch_workout');

  static final WatchWorkoutBridge instance = WatchWorkoutBridge._();

  final _commandController = StreamController<WatchCommand>.broadcast();
  final _heartRateController =
      StreamController<WatchHeartRateUpdate>.broadcast();
  final _reachabilityController = StreamController<bool>.broadcast();
  final _requestRoutinesController = StreamController<void>.broadcast();

  bool _listening = false;
  String? _lastSyncSignature;
  String? _lastRoutineListSignature;

  Stream<WatchCommand> get commands => _commandController.stream;
  Stream<WatchHeartRateUpdate> get heartRates => _heartRateController.stream;
  Stream<bool> get reachability => _reachabilityController.stream;
  Stream<void> get routineListRequests => _requestRoutinesController.stream;

  bool get isSupported => !kIsWeb && Platform.isIOS;

  void ensureListening() {
    if (!isSupported || _listening) return;
    _listening = true;
    _channel.setMethodCallHandler(_onMethodCall);
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'watchCommand':
        final args = call.arguments;
        if (args is Map && args['command'] is String) {
          _commandController.add(
            WatchCommand(
              args['command'] as String,
              routineId: args['routineId'] as String?,
            ),
          );
        }
      case 'heartRate':
        final args = call.arguments;
        if (args is Map) {
          final bpm = (args['bpm'] as num?)?.toDouble() ?? 0;
          if (bpm > 0) {
            _heartRateController.add(
              WatchHeartRateUpdate(
                bpm: bpm,
                avgBpm: (args['avgBpm'] as num?)?.toDouble() ?? 0,
                maxBpm: (args['maxBpm'] as num?)?.toDouble() ?? 0,
              ),
            );
          }
        }
      case 'watchReachability':
        final args = call.arguments;
        if (args is Map && args['reachable'] is bool) {
          _reachabilityController.add(args['reachable'] as bool);
        }
      case 'requestRoutines':
        _requestRoutinesController.add(null);
    }
  }

  Future<bool> isWatchReachable() async {
    if (!isSupported) return false;
    try {
      final value = await _channel.invokeMethod<bool>('isWatchReachable');
      return value ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isWatchPaired() async {
    if (!isSupported) return false;
    try {
      final value = await _channel.invokeMethod<bool>('isWatchPaired');
      return value ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Returns a Watch-requested routine id queued while the phone app was
  /// terminated / Flutter was not ready. Clears the native pending slot.
  Future<String?> consumePendingStartRoutine() async {
    if (!isSupported) return null;
    ensureListening();
    try {
      final value =
          await _channel.invokeMethod<String>('consumePendingStartRoutine');
      if (value == null || value.isEmpty) return null;
      return value;
    } catch (error) {
      debugPrint('WatchWorkoutBridge.consumePendingStartRoutine failed: $error');
      return null;
    }
  }

  Future<void> syncRoutineList(List<Routine> routines, {bool force = false}) async {
    if (!isSupported) return;
    ensureListening();

    final payload = routines
        .map((r) => <String, dynamic>{'id': r.id, 'title': r.title})
        .toList(growable: false);
    final signature = payload.map((e) => '${e['id']}|${e['title']}').join(';');
    if (!force && signature == _lastRoutineListSignature) return;
    _lastRoutineListSignature = signature;

    try {
      await _channel.invokeMethod<void>('syncRoutineList', <String, dynamic>{
        'routines': payload,
      });
    } catch (error) {
      debugPrint('WatchWorkoutBridge.syncRoutineList failed: $error');
    }
  }

  Future<void> syncSnapshot(
    WorkoutTimerSnapshot snap, {
    String? healthActivityType,
    bool force = false,
  }) async {
    if (!isSupported) return;
    ensureListening();

    final signature =
        '${snap.phase.kind.name}|${snap.remainingSec}|${snap.isPaused}|'
        '${snap.isCompleted}|${snap.phase.label}|${snap.setIndex}|${snap.repIndex}';
    if (!force && signature == _lastSyncSignature) return;
    _lastSyncSignature = signature;

    try {
      await _channel.invokeMethod<void>('syncSnapshot', <String, dynamic>{
        'phaseKind': snap.phase.kind.name,
        'label': snap.phase.label,
        'remainingSec': snap.remainingSec,
        'exerciseName': snap.exerciseName,
        'setIndex': snap.setIndex,
        'repIndex': snap.repIndex,
        'totalSets': snap.totalSets,
        'totalReps': snap.totalReps,
        'isPaused': snap.isPaused,
        'isCompleted': snap.isCompleted,
        'routineTitle': snap.routineTitle,
        'healthActivityType': ?healthActivityType,
      });
    } catch (error) {
      debugPrint('WatchWorkoutBridge.syncSnapshot failed: $error');
    }
  }

  Future<void> endSession() async {
    if (!isSupported) return;
    _lastSyncSignature = null;
    try {
      await _channel.invokeMethod<void>('endSession');
    } catch (error) {
      debugPrint('WatchWorkoutBridge.endSession failed: $error');
    }
  }

  Future<void> notifyStartFailed() async {
    if (!isSupported) return;
    _lastSyncSignature = null;
    try {
      await _channel.invokeMethod<void>('notifyStartFailed');
    } catch (error) {
      debugPrint('WatchWorkoutBridge.notifyStartFailed failed: $error');
    }
  }
}

class WatchCommand {
  const WatchCommand(this.command, {this.routineId});

  final String command;
  final String? routineId;
}

class WatchHeartRateUpdate {
  const WatchHeartRateUpdate({
    required this.bpm,
    required this.avgBpm,
    required this.maxBpm,
  });

  final double bpm;
  final double avgBpm;
  final double maxBpm;
}
