import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _nicknameKey = 'nickname';
  static const _tokenKey = 'auth_token';
  static const _limitKey = 'expense_limit';
  static const _lastLoginKey = 'last_login_at';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<void> saveNickname(String nickname) async {
    final prefs = await _prefs;
    await prefs.setString(_nicknameKey, nickname);
  }

  Future<String?> getNickname() async {
    final prefs = await _prefs;
    return prefs.getString(_nicknameKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  Future<void> clearAuth() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_nicknameKey);
    await prefs.remove(_lastLoginKey);
  }

  Future<void> clearAllUserData() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_nicknameKey);
    await prefs.remove(_limitKey);
    await prefs.remove(_lastLoginKey);
  }

  Future<void> saveBudgetLimit(int limit) async {
    final prefs = await _prefs;
    await prefs.setInt(_limitKey, limit);
  }

  Future<int> getBudgetLimit() async {
    final prefs = await _prefs;
    return prefs.getInt(_limitKey) ?? 1000;
  }
}
