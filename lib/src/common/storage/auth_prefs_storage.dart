import 'package:shared_preferences/shared_preferences.dart';

class AuthPrefsStorage {
  static const String _rememberKey = 'remember_me_enabled';
  static const String _emailKey = 'remember_email';
  static const String _passwordKey = 'remember_password';

  const AuthPrefsStorage();

  Future<void> saveRememberedCredentials({
    required bool remember,
    String? email,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberKey, remember);
    if (remember) {
      if (email != null) await prefs.setString(_emailKey, email);
      if (password != null) await prefs.setString(_passwordKey, password);
    } else {
      await prefs.remove(_emailKey);
      await prefs.remove(_passwordKey);
    }
  }

  Future<({bool remember, String? email, String? password})>
  readRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_rememberKey) ?? false;
    if (!remember) return (remember: false, email: null, password: null);
    final email = prefs.getString(_emailKey);
    final password = prefs.getString(_passwordKey);
    return (remember: remember, email: email, password: password);
  }

  Future<void> clearRemembered() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rememberKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
  }
}
