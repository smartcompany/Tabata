import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utils/tts_locale.dart';
import '../engine/workout_timer_engine.dart';
import 'workout_android_audio.dart';
import 'workout_audio_session.dart';
import 'workout_voice_phrases.dart';
import 'workout_voice_planner.dart';

class WorkoutVoiceCoach {
  WorkoutVoiceCoach({
    required WorkoutVoicePhrases phrases,
    required Locale locale,
    this.onAudioSessionRestored,
    WorkoutVoicePlanner planner = const WorkoutVoicePlanner(),
  })  : _phrases = phrases,
        _locale = locale,
        _planner = planner;

  final WorkoutVoicePhrases _phrases;
  final Future<void> Function()? onAudioSessionRestored;
  final WorkoutVoicePlanner _planner;
  final FlutterTts _tts = FlutterTts();

  Locale _locale;
  bool _initialized = false;
  bool _speaking = false;
  bool _backgroundDucked = false;
  bool _disposed = false;
  int _speechGeneration = 0;
  Future<void>? _deferredSpeech;

  Future<void> init(Locale locale) async {
    _locale = locale;
    await _configureTts();
    _initialized = true;
  }

  Future<void> _configureTts() async {
    final candidates = ttsFallbackLanguagesForLocale(_locale);
    for (final language in candidates) {
      final result = await _tts.setLanguage(language);
      if (result == 1) break;
    }
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);

    if (defaultTargetPlatform == TargetPlatform.android) {
      final configured = await WorkoutAndroidAudio.configureTtsMediaPlayback();
      if (!configured) {
        await _tts.setAudioAttributesForNavigation();
      }
    }
  }

  Future<void>? _snapshotQueue;

  Future<void> handleSnapshot(
    WorkoutTimerSnapshot? previous,
    WorkoutTimerSnapshot current, {
    bool countSecondsWithTts = true,
  }) {
    final task = (_snapshotQueue ?? Future<void>.value()).then(
      (_) => _handleSnapshot(
        previous,
        current,
        countSecondsWithTts: countSecondsWithTts,
      ),
    );
    _snapshotQueue = task;
    return task;
  }

  Future<void> _handleSnapshot(
    WorkoutTimerSnapshot? previous,
    WorkoutTimerSnapshot current, {
    bool countSecondsWithTts = true,
  }) async {
    if (_disposed) return;
    if (current.isPaused) {
      await stop();
      return;
    }

    final cues = _planner.plan(
      previous: previous,
      current: current,
      countSecondsWithTts: countSecondsWithTts,
    );
    if (cues.isEmpty) return;

    final immediate = <VoiceCue>[];
    final deferred = <VoiceCue>[];
    for (final cue in cues) {
      if (cue.kind == VoiceCueKind.instruction) {
        deferred.add(cue);
      } else {
        immediate.add(cue);
      }
    }

    // 3-2-1 / next-phase cues preempt prepare instruction TTS.
    if (immediate.isNotEmpty) {
      await _cancelDeferredSpeech();
    }

    for (final cue in immediate) {
      await _speakCue(cue);
    }

    if (deferred.isNotEmpty) {
      _startDeferredSpeech(deferred);
    }
  }

  void _startDeferredSpeech(List<VoiceCue> cues) {
    final generation = ++_speechGeneration;
    _deferredSpeech = Future<void>(() async {
      for (final cue in cues) {
        if (_disposed || generation != _speechGeneration) return;
        await _speakCue(cue);
      }
    });
  }

  Future<void> _cancelDeferredSpeech() async {
    _speechGeneration++;
    if (_speaking) {
      try {
        await _tts.stop();
      } catch (_) {}
      _speaking = false;
    }
    await _deferredSpeech;
    _deferredSpeech = null;
    await _endDucking();
  }

  Future<void> stop() async {
    await _cancelDeferredSpeech();
  }

  Future<void> _prepareTtsAudioSession() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await WorkoutAudioSession.applyTtsDucking();
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.duckOthers],
        IosTextToSpeechAudioMode.voicePrompt,
      );
      await _tts.setSharedInstance(true);
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final configured = await WorkoutAndroidAudio.configureTtsMediaPlayback();
      if (!configured) {
        await _tts.setAudioAttributesForNavigation();
      }
    }
  }

  Future<void> _restoreBackgroundAudioSession() async {
    if (_disposed) return;
    await WorkoutAudioSession.configure();
    if (_disposed) return;
    await onAudioSessionRestored?.call();
  }

  /// Duck through chained utterances (exercise name → phase, or 3 → 2 → 1).
  bool _shouldKeepBackgroundDuckedAfter(VoiceCue cue) {
    return switch (cue.kind) {
      VoiceCueKind.exerciseName => true,
      // Long phases: unduck after the intro so the clock loop can play.
      VoiceCueKind.phaseStart => (cue.phaseDurationSec ?? 0) <= 3,
      VoiceCueKind.instruction => false,
      VoiceCueKind.countdown => cue.seconds! > 1,
      VoiceCueKind.repCount => cue.repNumber! < cue.totalReps!,
      VoiceCueKind.completed => false,
    };
  }

  Future<void> _beginDucking() async {
    if (_backgroundDucked) {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setSharedInstance(true);
      }
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      await WorkoutAndroidAudio.configureTtsMediaPlayback();
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Android flutter_tts does not implement autoStopSharedSession.
      await _tts.autoStopSharedSession(false);
    }
    await _prepareTtsAudioSession();
    _backgroundDucked = true;
  }

  Future<void> _endDucking() async {
    if (!_backgroundDucked) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _restoreBackgroundAudioSession();
      await _tts.autoStopSharedSession(true);
    }
    _backgroundDucked = false;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _snapshotQueue;
    await stop();
  }

  Future<void> _speakCue(VoiceCue cue) async {
    if (!_initialized) await init(_locale);

    final text = switch (cue.kind) {
      VoiceCueKind.exerciseName => cue.exerciseName!,
      VoiceCueKind.phaseStart => phaseStartSpeech(
          phaseKind: cue.phaseKind!,
          label: cue.label!,
          prepareTitle: _phrases.prepare,
          workTitle: _phrases.work,
          relaxTitle: _phrases.relax,
        ),
      VoiceCueKind.instruction => cue.instructionText ?? '',
      VoiceCueKind.countdown => _phrases.countdown(cue.seconds!),
      VoiceCueKind.repCount => _phrases.repCount(cue.repNumber!),
      VoiceCueKind.completed => _phrases.completed,
    };

    if (text.isEmpty) return;

    if (cue.kind == VoiceCueKind.countdown &&
        defaultTargetPlatform == TargetPlatform.android) {
      await _speakCountdownOnAndroid(text, cue);
      return;
    }

    _speaking = true;
    try {
      await _beginDucking();
      await _tts.speak(text, focus: true);
    } catch (error, stackTrace) {
      debugPrint('WorkoutVoiceCoach speak failed: $error\n$stackTrace');
    } finally {
      _speaking = false;
      if (!_shouldKeepBackgroundDuckedAfter(cue)) {
        await _endDucking();
      }
    }
  }

  /// Android TTS completion can lag or stall; stop the prior digit and cap wait
  /// so the announce queue does not stack behind [awaitSpeakCompletion].
  Future<void> _speakCountdownOnAndroid(String text, VoiceCue cue) async {
    _speaking = true;
    try {
      await _beginDucking();
      await _tts.stop();
      await _tts.speak(text, focus: true).timeout(
        const Duration(milliseconds: 850),
        onTimeout: () {
          debugPrint('WorkoutVoiceCoach: Android countdown speak timed out');
        },
      );
    } catch (error, stackTrace) {
      debugPrint('WorkoutVoiceCoach speak failed: $error\n$stackTrace');
    } finally {
      _speaking = false;
      if (!_shouldKeepBackgroundDuckedAfter(cue)) {
        await _endDucking();
      }
    }
  }
}
