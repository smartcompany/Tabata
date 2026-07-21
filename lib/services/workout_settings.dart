import 'package:shared_preferences/shared_preferences.dart';

class WorkoutSettings {
  WorkoutSettings(this._prefs);

  static const _keySaveToAppleHealth = 'workout_save_to_apple_health_v1';
  static const _keyAppleHealthPreferenceAsked =
      'workout_apple_health_preference_asked_v1';
  static const _keyContinueInBackground = 'workout_continue_in_background_v1';

  final SharedPreferences _prefs;

  bool get saveToAppleHealth =>
      _prefs.getBool(_keySaveToAppleHealth) ?? false;

  /// Apple Health (iOS) or Health Connect (Android).
  bool get saveToHealthApp => saveToAppleHealth;

  Future<void> setSaveToAppleHealth(bool value) async {
    await _prefs.setBool(_keySaveToAppleHealth, value);
  }

  bool get appleHealthPreferenceAsked =>
      _prefs.getBool(_keyAppleHealthPreferenceAsked) ?? false;

  Future<void> setAppleHealthPreferenceAsked(bool value) async {
    await _prefs.setBool(_keyAppleHealthPreferenceAsked, value);
  }

  /// When true (default), the workout timer keeps advancing while the app is
  /// in the background. When false, entering background pauses the timer.
  bool get continueInBackground =>
      _prefs.getBool(_keyContinueInBackground) ?? true;

  Future<void> setContinueInBackground(bool value) async {
    await _prefs.setBool(_keyContinueInBackground, value);
  }

  static Future<WorkoutSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return WorkoutSettings(prefs);
  }
}
