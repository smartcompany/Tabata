import 'package:shared_preferences/shared_preferences.dart';

class SoundSettings {
  SoundSettings(this._prefs);

  static const _keyEnabled = 'sound_effects_enabled';

  final SharedPreferences _prefs;

  bool get enabled => _prefs.getBool(_keyEnabled) ?? true;

  Future<void> setEnabled(bool value) => _prefs.setBool(_keyEnabled, value);

  static Future<SoundSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SoundSettings(prefs);
  }
}
