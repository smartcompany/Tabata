import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../engine/workout_timer_engine.dart';
import 'sound_settings.dart';

class WorkoutSoundCoach {
  WorkoutSoundCoach({required SoundSettings settings}) : _settings = settings;

  final SoundSettings _settings;
  final AudioPlayer _tickPlayer = AudioPlayer();
  final AudioPlayer _eventPlayer = AudioPlayer();

  bool _initialized = false;
  bool _tickReady = false;

  Future<void> init() async {
    await _tickPlayer.setReleaseMode(ReleaseMode.stop);
    await _tickPlayer.setVolume(0.55);
    await _eventPlayer.setReleaseMode(ReleaseMode.stop);
    await _eventPlayer.setVolume(0.85);
    _initialized = true;
  }

  Future<void> handleSnapshot(
    WorkoutTimerSnapshot? previous,
    WorkoutTimerSnapshot current,
  ) async {
    if (!_settings.enabled) return;
    if (!_initialized) await init();
    if (current.isPaused) return;

    if (current.isCompleted) {
      if (previous?.isCompleted == true) return;
      await _playEvent('sounds/complete.wav', volume: 1.0);
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
      return;
    }

    if (_shouldPlayTick(previous, current)) {
      await _playTick();
    }
  }

  bool _shouldPlayTick(
    WorkoutTimerSnapshot previous,
    WorkoutTimerSnapshot current,
  ) {
    if (!_samePhaseContext(previous, current)) return false;
    if (previous.remainingSec - current.remainingSec != 1) return false;

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

  Future<void> _playEvent(String assetPath, {double volume = 0.85}) async {
    try {
      await _eventPlayer.stop();
      await _eventPlayer.setVolume(volume);
      await _eventPlayer.play(AssetSource(assetPath));
    } catch (error, stackTrace) {
      debugPrint('WorkoutSoundCoach event failed: $error\n$stackTrace');
    }
  }

  Future<void> dispose() async {
    await _tickPlayer.dispose();
    await _eventPlayer.dispose();
  }
}
