import 'package:shared_preferences/shared_preferences.dart';

class WorkoutSettings {
  WorkoutSettings(this._prefs);

  static const _keyCountSecondsWithTts = 'workout_count_seconds_with_tts_v1';
  static const _keySaveToAppleHealth = 'workout_save_to_apple_health_v1';
  static const _keyAppleHealthPreferenceAsked =
      'workout_apple_health_preference_asked_v1';

  final SharedPreferences _prefs;

  /// When true (default), count-mode phases speak each elapsed second via TTS.
  /// When false, per-second beeps play instead.
  bool get countSecondsWithTts =>
      _prefs.getBool(_keyCountSecondsWithTts) ?? true;

  Future<void> setCountSecondsWithTts(bool value) async {
    await _prefs.setBool(_keyCountSecondsWithTts, value);
  }

  bool get saveToAppleHealth =>
      _prefs.getBool(_keySaveToAppleHealth) ?? false;

  Future<void> setSaveToAppleHealth(bool value) async {
    await _prefs.setBool(_keySaveToAppleHealth, value);
  }

  bool get appleHealthPreferenceAsked =>
      _prefs.getBool(_keyAppleHealthPreferenceAsked) ?? false;

  Future<void> setAppleHealthPreferenceAsked(bool value) async {
    await _prefs.setBool(_keyAppleHealthPreferenceAsked, value);
  }

  static Future<WorkoutSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return WorkoutSettings(prefs);
  }
}
