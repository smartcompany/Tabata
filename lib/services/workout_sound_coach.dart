import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../engine/workout_timer_engine.dart';
import 'workout_audio_session.dart';

class WorkoutSoundCoach {
  static const tickVolume = 1.0;
  static const eventVolume = 1.0;

  final AudioPlayer _tickPlayer = AudioPlayer();
  final AudioPlayer _eventPlayer = AudioPlayer();

  bool _initialized = false;
  bool _tickReady = false;

  Future<void> init() async {
    await WorkoutAudioSession.configure();
    await WorkoutAudioSession.applyTo(_tickPlayer);
    await WorkoutAudioSession.applyTo(_eventPlayer);
    await _tickPlayer.setReleaseMode(ReleaseMode.stop);
    await _eventPlayer.setReleaseMode(ReleaseMode.stop);
    await _tickPlayer.setVolume(tickVolume);
    await _eventPlayer.setVolume(eventVolume);
    _initialized = true;
  }

  /// Plays the per-second tick. Call on each timer tick, not behind the voice queue.
  Future<void> handleTick(
    WorkoutTimerSnapshot? previous,
    WorkoutTimerSnapshot current,
  ) async {
    if (!_initialized) await init();
    if (current.isPaused || previous == null) return;
    if (_shouldPlayTick(previous, current)) {
      await _playTick();
    }
  }

  /// Plays set/rep/complete chimes. Call on each timer tick, not behind the voice queue.
  Future<void> handleEvents(
    WorkoutTimerSnapshot? previous,
    WorkoutTimerSnapshot current,
  ) async {
    if (!_initialized) await init();
    if (current.isPaused) return;

    if (current.isCompleted) {
      if (previous?.isCompleted == true) return;
      await _playEvent('sounds/complete.wav', volume: eventVolume);
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

  bool _shouldPlayTick(
    WorkoutTimerSnapshot previous,
    WorkoutTimerSnapshot current,
  ) {
    if (!_samePhaseContext(previous, current)) return false;
    if (previous.remainingSec - current.remainingSec != 1) return false;

    if (current.phase.isCountRep) return true;

    final duration = current.phase.durationSec;
    if (duration > 3 && current.remainingSec <= 3) {
      return false;
    }

    return true;
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

  Future<void> _playTick() async {
    try {
      if (!_tickReady) {
        await _tickPlayer.play(AssetSource('sounds/tick.wav'));
        _tickReady = true;
        return;
      }
      await _tickPlayer.seek(Duration.zero);
      await _tickPlayer.resume();
    } catch (error, stackTrace) {
      debugPrint('WorkoutSoundCoach tick failed: $error\n$stackTrace');
    }
  }

  Future<void> _playEvent(String assetPath, {double? volume}) async {
    try {
      await _eventPlayer.stop();
      await _eventPlayer.setVolume(volume ?? eventVolume);
      await _eventPlayer.play(AssetSource(assetPath));
    } catch (error, stackTrace) {
      debugPrint('WorkoutSoundCoach event failed: $error\n$stackTrace');
    }
  }

  Future<void> refreshAudioSession() async {
    if (!_initialized) return;
    await WorkoutAudioSession.configure();
    await WorkoutAudioSession.applyTo(_tickPlayer);
    await WorkoutAudioSession.applyTo(_eventPlayer);
  }

  Future<void> dispose() async {
    await _tickPlayer.dispose();
    await _eventPlayer.dispose();
  }
}
