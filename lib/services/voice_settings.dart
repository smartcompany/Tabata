import 'package:shared_preferences/shared_preferences.dart';

class VoiceSettings {
  VoiceSettings(this._prefs);

  static const _keyEnabled = 'voice_guidance_enabled';

  final SharedPreferences _prefs;

  bool get enabled => _prefs.getBool(_keyEnabled) ?? true;

  Future<void> setEnabled(bool value) => _prefs.setBool(_keyEnabled, value);

  static Future<VoiceSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return VoiceSettings(prefs);
  }
}
