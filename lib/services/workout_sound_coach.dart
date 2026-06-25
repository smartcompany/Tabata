import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../engine/workout_timer_engine.dart';
import 'workout_audio_session.dart';

class WorkoutSoundCoach {
  static const tickVolume = 1.0;
  static const eventVolume = 1.0;
  static const clockStrongAsset = 'sounds/clock_tick_strong.wav';
  static const clockWeakAsset = 'sounds/clock_tock_weak.wav';

  /// Tick-tock interval — rapid clicks for a fast-running clock feel.
  static const clockClickInterval = Duration(milliseconds: 220);

  bool countSecondsWithTts = true;

  final AudioPlayer _clockStrongPlayer = AudioPlayer();
  final AudioPlayer _clockWeakPlayer = AudioPlayer();
  final AudioPlayer _tickPlayer = AudioPlayer();
  final AudioPlayer _eventPlayer = AudioPlayer();

  bool _initialized = false;
  bool _clockSourceReady = false;
  bool _clockPlaying = false;
  bool _clockStrongNext = true;
  Timer? _clockTimer;
  bool _tickReady = false;
  bool _disposed = false;

  Future<void> init() async {
    if (_disposed) return;
    await WorkoutAudioSession.configure();
    if (_disposed) return;
    await WorkoutAudioSession.applyTo(_clockStrongPlayer);
    if (_disposed) return;
    await WorkoutAudioSession.applyTo(_clockWeakPlayer);
    if (_disposed) return;
    await WorkoutAudioSession.applyTo(_tickPlayer);
    if (_disposed) return;
    await WorkoutAudioSession.applyTo(_eventPlayer);
    if (_disposed) return;
    await _clockStrongPlayer.setReleaseMode(ReleaseMode.stop);
    await _clockWeakPlayer.setReleaseMode(ReleaseMode.stop);
    await _tickPlayer.setReleaseMode(ReleaseMode.stop);
    await _eventPlayer.setReleaseMode(ReleaseMode.stop);
    await _clockStrongPlayer.setVolume(tickVolume);
    await _clockWeakPlayer.setVolume(tickVolume);
    await _tickPlayer.setVolume(tickVolume);
    await _eventPlayer.setVolume(eventVolume);
    await _prepareClockSources();
    _initialized = true;
  }

  /// Materialize bundled audio to a device path without path_provider (iOS 26 sim safe).
  Future<String> _materializeAsset(String assetFile) async {
    final data = await rootBundle.load('assets/$assetFile');
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    final hash = Object.hashAll(bytes).toUnsigned(20).toRadixString(16);
    final safeName = assetFile.replaceAll('/', '_');
    final file = File('${Directory.systemTemp.path}/tabata_${hash}_$safeName');
    if (!await file.exists()) {
      await file.writeAsBytes(bytes, flush: true);
    }
    return file.path;
  }

  Future<void> _prepareClockSources() async {
    if (_disposed) return;
    try {
      final strongPath = await _materializeAsset(clockStrongAsset);
      final weakPath = await _materializeAsset(clockWeakAsset);
      if (_disposed) return;
      await _clockStrongPlayer.setSourceDeviceFile(strongPath);
      await _clockWeakPlayer.setSourceDeviceFile(weakPath);
      _clockSourceReady = true;
    } catch (error, stackTrace) {
      _clockSourceReady = false;
      debugPrint(
        'WorkoutSoundCoach clock source prep failed: $error\n$stackTrace',
      );
    }
  }

  /// Keeps clock clicks, per-second ticks, and event chimes in sync with the timer.
  Future<void> handleSnapshot(
    WorkoutTimerSnapshot? previous,
    WorkoutTimerSnapshot current,
  ) async {
    if (_disposed) return;
    if (!_initialized) await init();
    if (_disposed) return;

    await syncClock(current);
    await _handleCountModeTick(previous, current);
    await handleEvents(previous, current);
  }

  /// Starts or stops rapid tick-tock clicks for duration mode.
  Future<void> syncClock(WorkoutTimerSnapshot current) async {
    if (_disposed) return;
    if (!_initialized) await init();
    if (_disposed) return;

    final shouldPlay = shouldPlayClockLoop(current);
    if (shouldPlay) {
      _startClockClicks();
    } else if (_clockPlaying) {
      _stopClockClicks();
    }
  }

  @visibleForTesting
  static bool shouldPlayClockLoop(WorkoutTimerSnapshot current) {
    if (current.isPaused || current.isCompleted) return false;
    if (current.phase.isCountRep) return false;
    if (current.phase.kind == WorkoutPhaseKind.completed) return false;
    final duration = current.phase.durationSec;
    if (duration <= 3) return false;
    return current.remainingSec > 3;
  }

  Future<void> _handleCountModeTick(
    WorkoutTimerSnapshot? previous,
    WorkoutTimerSnapshot current,
  ) async {
    if (_disposed || current.isPaused || previous == null) return;
    if (_shouldPlayCountModeTick(previous, current)) {
      await _playTick();
    }
  }

  /// Plays set/rep/complete chimes. Call on each timer tick, not behind the voice queue.
  Future<void> handleEvents(
    WorkoutTimerSnapshot? previous,
    WorkoutTimerSnapshot current,
  ) async {
    if (_disposed) return;
    if (!_initialized) await init();
    if (_disposed || current.isPaused) return;

    if (current.isCompleted) {
      if (previous?.isCompleted == true) return;
      await _playEvent('sounds/complete.wav');
      return;
    }

    if (previous == null) return;

    if (previous.exerciseIndex != current.exerciseIndex ||
        previous.setIndex != current.setIndex) {
      await _playEvent('sounds/set.wav');
      return;
    }

    if (previous.repIndex != current.repIndex) {
      await _playEvent('sounds/rep.wav');
    }
  }

  bool _shouldPlayCountModeTick(
    WorkoutTimerSnapshot previous,
    WorkoutTimerSnapshot current,
  ) {
    if (!current.phase.isCountRep) return false;
    if (!_samePhaseContext(previous, current)) return false;
    if (previous.remainingSec - current.remainingSec != 1) return false;
    return !countSecondsWithTts;
  }

  bool _samePhaseContext(
    WorkoutTimerSnapshot previous,
    WorkoutTimerSnapshot current,
  ) {
    return previous.phase.kind == current.phase.kind &&
        previous.phase.label == current.phase.label &&
        previous.phase.phaseGroupKey == current.phase.phaseGroupKey &&
        previous.phase.countRepNumber == current.phase.countRepNumber &&
        previous.exerciseIndex == current.exerciseIndex &&
        previous.setIndex == current.setIndex &&
        previous.repIndex == current.repIndex;
  }

  void _startClockClicks() {
    if (_disposed || !_clockSourceReady || _clockPlaying) return;
    _clockPlaying = true;
    _clockStrongNext = true;
    unawaited(_playClockClick());
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(clockClickInterval, (_) {
      unawaited(_playClockClick());
    });
  }

  void _stopClockClicks() {
    _clockTimer?.cancel();
    _clockTimer = null;
    _clockPlaying = false;
    unawaited(_clockStrongPlayer.stop());
    unawaited(_clockWeakPlayer.stop());
  }

  Future<void> _playClockClick() async {
    if (_disposed || !_clockSourceReady) return;
    final player = _clockStrongNext ? _clockStrongPlayer : _clockWeakPlayer;
    _clockStrongNext = !_clockStrongNext;
    try {
      await player.seek(Duration.zero);
      await player.resume();
    } catch (error, stackTrace) {
      debugPrint('WorkoutSoundCoach clock click failed: $error\n$stackTrace');
    }
  }

  Future<void> _playTick() async {
    if (_disposed) return;
    try {
      if (!_tickReady) {
        final devicePath = await _materializeAsset('sounds/tick.wav');
        await _tickPlayer.setSourceDeviceFile(devicePath);
        await _tickPlayer.resume();
        _tickReady = true;
        return;
      }
      await _tickPlayer.seek(Duration.zero);
      await _tickPlayer.resume();
    } catch (error, stackTrace) {
      debugPrint('WorkoutSoundCoach tick failed: $error\n$stackTrace');
    }
  }

  Future<void> _playEvent(String assetPath) async {
    if (_disposed) return;
    try {
      final devicePath = await _materializeAsset(assetPath);
      await _eventPlayer.stop();
      await _eventPlayer.setSourceDeviceFile(devicePath);
      await _eventPlayer.setVolume(eventVolume);
      await _eventPlayer.resume();
    } catch (error, stackTrace) {
      debugPrint('WorkoutSoundCoach event failed: $error\n$stackTrace');
    }
  }

  Future<void> refreshAudioSession() async {
    if (!_initialized || _disposed) return;
    final wasClockPlaying = _clockPlaying;
    _stopClockClicks();
    try {
      await WorkoutAudioSession.configure();
      if (_disposed) return;
      await WorkoutAudioSession.applyTo(_clockStrongPlayer);
      if (_disposed) return;
      await WorkoutAudioSession.applyTo(_clockWeakPlayer);
      if (_disposed) return;
      await WorkoutAudioSession.applyTo(_tickPlayer);
      if (_disposed) return;
      await WorkoutAudioSession.applyTo(_eventPlayer);
      if (_disposed) return;
      await _prepareClockSources();
      if (wasClockPlaying && _clockSourceReady) {
        _startClockClicks();
      }
    } catch (error, stackTrace) {
      debugPrint(
        'WorkoutSoundCoach refreshAudioSession failed: $error\n$stackTrace',
      );
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _initialized = false;
    _stopClockClicks();
    _clockSourceReady = false;
    try {
      await _clockStrongPlayer.stop();
      await _clockWeakPlayer.stop();
      await _tickPlayer.stop();
      await _eventPlayer.stop();
    } catch (_) {}
    try {
      await _clockStrongPlayer.dispose();
      await _clockWeakPlayer.dispose();
      await _tickPlayer.dispose();
      await _eventPlayer.dispose();
    } catch (_) {}
  }
}
