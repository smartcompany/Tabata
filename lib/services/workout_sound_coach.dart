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

  /// Tick + 220ms gap + tock + 220ms gap (440ms loop).
  static const clockLoopAsset = 'sounds/clock_tick_tock_loop.wav';

  bool countSecondsWithTts = true;

  /// When true, keeps a silent clock loop in the background so iOS grants
  /// audio background execution between TTS cues.
  bool backgroundKeepAlive = false;
  bool inBackground = false;

  final AudioPlayer _clockPlayer = AudioPlayer();
  final AudioPlayer _tickPlayer = AudioPlayer();
  final AudioPlayer _eventPlayer = AudioPlayer();

  bool _initialized = false;
  bool _clockSourceReady = false;
  bool _clockPlaying = false;
  bool _clockSilent = false;
  bool _tickReady = false;
  bool _disposed = false;

  Future<void> init() async {
    if (_disposed) return;
    await WorkoutAudioSession.configure();
    if (_disposed) return;
    await WorkoutAudioSession.applyTo(_clockPlayer);
    if (_disposed) return;
    await WorkoutAudioSession.applyTo(_tickPlayer);
    if (_disposed) return;
    await WorkoutAudioSession.applyTo(_eventPlayer);
    if (_disposed) return;
    await _clockPlayer.setReleaseMode(ReleaseMode.loop);
    await _clockPlayer.setVolume(tickVolume);
    await _tickPlayer.setReleaseMode(ReleaseMode.stop);
    await _eventPlayer.setReleaseMode(ReleaseMode.stop);
    await _tickPlayer.setVolume(tickVolume);
    await _eventPlayer.setVolume(eventVolume);
    await _prepareClockSource();
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

  Future<void> _prepareClockSource() async {
    if (_disposed) return;
    try {
      final loopPath = await _materializeAsset(clockLoopAsset);
      if (_disposed) return;
      await _clockPlayer.setSourceDeviceFile(loopPath);
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
    WorkoutTimerSnapshot current, {
    bool blockForIntro = false,
  }) async {
    if (_disposed) return;
    if (!_initialized) await init();
    if (_disposed) return;

    await syncClock(current, blockForIntro: blockForIntro);
    await _handleCountModeTick(previous, current);
    await handleEvents(previous, current);
  }

  /// Starts or stops rapid tick-tock clicks for duration mode.
  Future<void> syncClock(
    WorkoutTimerSnapshot current, {
    bool blockForIntro = false,
  }) async {
    if (_disposed) return;
    if (!_initialized) await init();
    if (_disposed) return;

    final shouldPlayAudible = shouldPlayClockLoop(
      current,
      blockForIntro: blockForIntro,
    );
    final shouldPlaySilent = !shouldPlayAudible &&
        _shouldPlaySilentKeepAlive(current, blockForIntro: blockForIntro);
    if (shouldPlayAudible || shouldPlaySilent) {
      await _startClockLoop(silent: shouldPlaySilent);
    } else if (_clockPlaying) {
      await _stopClockLoop();
    }
  }

  bool _shouldPlaySilentKeepAlive(
    WorkoutTimerSnapshot current, {
    bool blockForIntro = false,
  }) {
    if (!backgroundKeepAlive || !inBackground) return false;
    if (blockForIntro) return false;
    if (current.isPaused || current.isCompleted) return false;
    if (current.phase.kind == WorkoutPhaseKind.completed) return false;
    return true;
  }

  @visibleForTesting
  static bool shouldPlayClockLoop(
    WorkoutTimerSnapshot current, {
    bool blockForIntro = false,
  }) {
    if (blockForIntro) return false;
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

  Future<void> _startClockLoop({bool silent = false}) async {
    if (_disposed || !_clockSourceReady) return;
    if (_clockPlaying && _clockSilent == silent) return;
    if (_clockPlaying) {
      await _stopClockLoop();
    }
    _clockPlaying = true;
    _clockSilent = silent;
    try {
      await _clockPlayer.setVolume(silent ? 0 : tickVolume);
      await _clockPlayer.seek(Duration.zero);
      if (_disposed) {
        _clockPlaying = false;
        _clockSilent = false;
        await _clockPlayer.stop();
        return;
      }
      await _clockPlayer.resume();
      if (_disposed) {
        _clockPlaying = false;
        _clockSilent = false;
        await _clockPlayer.stop();
      }
    } catch (error, stackTrace) {
      _clockPlaying = false;
      _clockSilent = false;
      debugPrint('WorkoutSoundCoach clock loop failed: $error\n$stackTrace');
    }
  }

  Future<void> _stopClockLoop() async {
    _clockPlaying = false;
    _clockSilent = false;
    try {
      await _clockPlayer.stop();
      if (!_disposed) {
        await _clockPlayer.seek(Duration.zero);
      }
    } catch (error, stackTrace) {
      debugPrint('WorkoutSoundCoach clock stop failed: $error\n$stackTrace');
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

  Future<void> refreshAudioSession({bool allowClockRestart = true}) async {
    if (!_initialized || _disposed) return;
    final wasClockPlaying = _clockPlaying;
    await _stopClockLoop();
    try {
      await WorkoutAudioSession.configure();
      if (_disposed) return;
      await WorkoutAudioSession.applyTo(_clockPlayer);
      if (_disposed) return;
      await WorkoutAudioSession.applyTo(_tickPlayer);
      if (_disposed) return;
      await WorkoutAudioSession.applyTo(_eventPlayer);
      if (_disposed) return;
      await _prepareClockSource();
      if (allowClockRestart && wasClockPlaying && _clockSourceReady) {
        await _startClockLoop();
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
    await _stopClockLoop();
    _clockSourceReady = false;
    try {
      await _clockPlayer.stop();
      await _tickPlayer.stop();
      await _eventPlayer.stop();
    } catch (_) {}
    try {
      await _clockPlayer.dispose();
      await _tickPlayer.dispose();
      await _eventPlayer.dispose();
    } catch (_) {}
  }
}
