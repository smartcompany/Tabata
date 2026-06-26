import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContentSettings {
  ContentSettings(this._prefs);

  static const _keyAutoTranslate = 'content_auto_translate_v1';

  final SharedPreferences _prefs;

  static final _listeners = <VoidCallback>[];

  static void addListener(VoidCallback listener) => _listeners.add(listener);

  static void removeListener(VoidCallback listener) =>
      _listeners.remove(listener);

  /// When true (default), server-loaded routine text is translated to the app language.
  bool get autoTranslateContent =>
      _prefs.getBool(_keyAutoTranslate) ?? true;

  Future<void> setAutoTranslateContent(bool value) async {
    await _prefs.setBool(_keyAutoTranslate, value);
    for (final listener in List<VoidCallback>.from(_listeners)) {
      listener();
    }
  }

  static Future<ContentSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ContentSettings(prefs);
  }
}
