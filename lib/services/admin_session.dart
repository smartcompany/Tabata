import 'package:shared_preferences/shared_preferences.dart';

class AdminSession {
  AdminSession(this._prefs);

  static const _tokenKey = 'admin_dashboard_token_v1';

  final SharedPreferences _prefs;

  static Future<AdminSession> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AdminSession(prefs);
  }

  String? get token => _prefs.getString(_tokenKey);

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<void> clear() async {
    await _prefs.remove(_tokenKey);
  }
}
