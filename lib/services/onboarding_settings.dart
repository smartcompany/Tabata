import 'package:shared_preferences/shared_preferences.dart';

abstract final class OnboardingSettings {
  static const _completedKey = 'onboarding_completed_v1';

  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_completedKey) ?? false;
  }

  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completedKey, true);
  }

  static Future<void> resetCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedKey);
  }
}
