import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android-only hooks for workout audio routing (media stream in silent/vibrate).
class WorkoutAndroidAudio {
  static const _channel = MethodChannel('com.smartcompany.tabata/workout_audio');

  static Future<bool> configureTtsMediaPlayback({int maxAttempts = 8}) async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        final configured = await _channel.invokeMethod<bool>(
          'configureTtsMediaPlayback',
        );
        if (configured == true) return true;
        await Future<void>.delayed(
          Duration(milliseconds: 50 * (attempt + 1)),
        );
      }
      debugPrint('WorkoutAndroidAudio.configureTtsMediaPlayback: TTS not ready');
      return false;
    } catch (error, stackTrace) {
      debugPrint(
        'WorkoutAndroidAudio.configureTtsMediaPlayback failed: $error\n$stackTrace',
      );
      return false;
    }
  }
}
