import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for non-sensitive preference storage operations
@LazySingleton()
class PreferencesService {
  const PreferencesService(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  static const String _rememberMeKey = 'remember_me';
  static const String _savedUsernameKey = 'saved_username';
  static const String _appThemeKey = 'app_theme';
  static const String _notificationEnabledKey = 'notification_enabled';

  /// Get remember me preference
  bool getRememberMe() {
    return _sharedPreferences.getBool(_rememberMeKey) ?? false;
  }

  /// Set remember me preference
  Future<bool> setRememberMe(bool value) async {
    return await _sharedPreferences.setBool(_rememberMeKey, value);
  }

  /// Get saved username
  String? getSavedUsername() {
    return _sharedPreferences.getString(_savedUsernameKey);
  }

  /// Save username for remember me feature
  Future<bool> setSavedUsername(String username) async {
    return await _sharedPreferences.setString(_savedUsernameKey, username);
  }

  /// Clear saved username
  Future<bool> clearSavedUsername() async {
    return await _sharedPreferences.remove(_savedUsernameKey);
  }

  /// Get app theme preference
  String? getAppTheme() {
    return _sharedPreferences.getString(_appThemeKey);
  }

  /// Set app theme preference
  Future<bool> setAppTheme(String theme) async {
    return await _sharedPreferences.setString(_appThemeKey, theme);
  }

  /// Get notification enabled preference
  bool getNotificationEnabled() {
    return _sharedPreferences.getBool(_notificationEnabledKey) ?? true;
  }

  /// Set notification enabled preference
  Future<bool> setNotificationEnabled(bool enabled) async {
    return await _sharedPreferences.setBool(_notificationEnabledKey, enabled);
  }

  /// Clear all preferences
  Future<bool> clearAll() async {
    return await _sharedPreferences.clear();
  }

  /// Clear login-related preferences
  Future<void> clearLoginPreferences() async {
    await clearSavedUsername();
    await setRememberMe(false);
  }
}
