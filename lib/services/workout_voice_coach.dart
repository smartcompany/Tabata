import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utils/tts_locale.dart';
import '../engine/workout_timer_engine.dart';
import 'voice_settings.dart';
import 'workout_voice_phrases.dart';
import 'workout_voice_planner.dart';

class WorkoutVoiceCoach {
  WorkoutVoiceCoach({
    required WorkoutVoicePhrases phrases,
    required VoiceSettings settings,
    required Locale locale,
    WorkoutVoicePlanner planner = const WorkoutVoicePlanner(),
  })  : _phrases = phrases,
        _settings = settings,
        _locale = locale,
        _planner = planner;

  final WorkoutVoicePhrases _phrases;
  final VoiceSettings _settings;
  final WorkoutVoicePlanner _planner;
  final FlutterTts _tts = FlutterTts();

  Locale _locale;
  bool _initialized = false;
  bool _speaking = false;

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
    await _tts.setSpeechRate(0.48);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> handleSnapshot(
    WorkoutTimerSnapshot? previous,
    WorkoutTimerSnapshot current,
  ) async {
    if (!_settings.enabled) return;

    if (current.isPaused) {
      await stop();
      return;
    }

    final cues = _planner.plan(previous: previous, current: current);
    for (final cue in cues) {
      await _speakCue(cue);
    }
  }

  Future<void> stop() async {
    if (!_speaking) return;
    await _tts.stop();
    _speaking = false;
  }

  Future<void> dispose() async {
    await stop();
  }

  Future<void> _speakCue(VoiceCue cue) async {
    if (!_initialized) await init(_locale);

    final text = switch (cue.kind) {
      VoiceCueKind.phaseStart => phaseStartSpeech(
          phaseKind: cue.phaseKind!,
          label: cue.label!,
          prepareTitle: _phrases.prepare,
          workTitle: _phrases.work,
          relaxTitle: _phrases.relax,
        ),
      VoiceCueKind.countdown => _phrases.countdown(cue.seconds!),
      VoiceCueKind.completed => _phrases.completed,
    };

    if (text.isEmpty) return;

    _speaking = true;
    try {
      await _tts.speak(text);
    } catch (error, stackTrace) {
      debugPrint('WorkoutVoiceCoach speak failed: $error\n$stackTrace');
    } finally {
      _speaking = false;
    }
  }
}
