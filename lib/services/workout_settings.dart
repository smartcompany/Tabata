import 'package:shared_preferences/shared_preferences.dart';

class WorkoutSettings {
  WorkoutSettings(this._prefs);

  static const _keyCountSecondsWithTts = 'workout_count_seconds_with_tts_v1';

  final SharedPreferences _prefs;

  /// When true (default), count-mode phases speak each elapsed second via TTS.
  /// When false, per-second beeps play instead.
  bool get countSecondsWithTts =>
      _prefs.getBool(_keyCountSecondsWithTts) ?? true;

  Future<void> setCountSecondsWithTts(bool value) async {
    await _prefs.setBool(_keyCountSecondsWithTts, value);
  }

  static Future<WorkoutSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return WorkoutSettings(prefs);
  }
}
