import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  Future<bool> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<bool> saveAuthToken(String token) async {
    return saveString(_keyAuthToken, token);
  }

  Future<String?> getAuthToken() async {
    return getString(_keyAuthToken);
  }

  Future<bool> saveUserId(String userId) async {
    return saveString(_keyUserId, userId);
  }

  Future<String?> getUserId() async {
    return getString(_keyUserId);
  }

  Future<bool> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_keyOnboardingCompleted, completed);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  Future<bool> clear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }
}
