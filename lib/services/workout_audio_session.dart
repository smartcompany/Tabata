import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Workout audio: mix with background music; duck music briefly during TTS.
class WorkoutAudioSession {
  static AudioContext get mixWithBackgroundMusic => AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: const AudioContextAndroid(
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.none,
        ),
      );

  /// Applied only while TTS is speaking so other apps' music ducks temporarily.
  static AudioContext get ttsDucking => AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {
            AVAudioSessionOptions.duckOthers,
            AVAudioSessionOptions.mixWithOthers,
          },
        ),
        android: const AudioContextAndroid(
          contentType: AndroidContentType.speech,
          usageType: AndroidUsageType.assistanceNavigationGuidance,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      );

  static Future<void> configure() async {
    if (kIsWeb) return;
    await AudioPlayer.global.setAudioContext(mixWithBackgroundMusic);
  }

  static Future<void> applyTtsDucking() async {
    if (kIsWeb) return;
    await AudioPlayer.global.setAudioContext(ttsDucking);
  }

  static Future<void> applyTo(AudioPlayer player) async {
    if (kIsWeb) return;
    await player.setAudioContext(mixWithBackgroundMusic);
  }
}
