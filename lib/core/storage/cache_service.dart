import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for caching application data for offline access and performance
@LazySingleton()
class CacheService {
  const CacheService(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  // Cache keys
  static const String _projectsKey = 'cached_projects';
  static const String _projectDetailPrefix = 'cached_project_detail_';
  static const String _userProfileKey = 'cached_user_profile';
  static const String _appSettingsKey = 'cached_app_settings';
  static const String _workCalendarKey = 'cached_work_calendar';
  static const String _lastSyncTimeKey = 'last_sync_time';
  static const String _offlineModeKey = 'offline_mode_enabled';

  // Cache expiration times (in hours)
  static const int _defaultCacheExpirationHours = 24;
  static const int _projectsCacheExpirationHours = 6;
  static const int _userProfileCacheExpirationHours = 12;

  /// Cache projects list for offline access
  Future<bool> cacheProjects(List<Map<String, dynamic>> projects) async {
    final cacheData = {
      'data': projects,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiration': DateTime.now().add(const Duration(hours: _projectsCacheExpirationHours)).millisecondsSinceEpoch,
    };
    return await _sharedPreferences.setString(_projectsKey, jsonEncode(cacheData));
  }

  /// Get cached projects if not expired
  List<Map<String, dynamic>>? getCachedProjects() {
    final cached = _sharedPreferences.getString(_projectsKey);
    if (cached == null) return null;

    try {
      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      final expiration = cacheData['expiration'] as int;

      if (DateTime.now().millisecondsSinceEpoch > expiration) {
        // Cache expired, remove it
        _sharedPreferences.remove(_projectsKey);
        return null;
      }

      return List<Map<String, dynamic>>.from(cacheData['data'] as List);
    } catch (e) {
      // Invalid cache data, remove it
      _sharedPreferences.remove(_projectsKey);
      return null;
    }
  }

  /// Cache individual project details
  Future<bool> cacheProjectDetail(String projectId, Map<String, dynamic> projectData) async {
    final cacheData = {
      'data': projectData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiration': DateTime.now().add(const Duration(hours: _defaultCacheExpirationHours)).millisecondsSinceEpoch,
    };
    return await _sharedPreferences.setString('$_projectDetailPrefix$projectId', jsonEncode(cacheData));
  }

  /// Get cached project detail if not expired
  Map<String, dynamic>? getCachedProjectDetail(String projectId) {
    final cached = _sharedPreferences.getString('$_projectDetailPrefix$projectId');
    if (cached == null) return null;

    try {
      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      final expiration = cacheData['expiration'] as int;

      if (DateTime.now().millisecondsSinceEpoch > expiration) {
        _sharedPreferences.remove('$_projectDetailPrefix$projectId');
        return null;
      }

      return cacheData['data'] as Map<String, dynamic>;
    } catch (e) {
      _sharedPreferences.remove('$_projectDetailPrefix$projectId');
      return null;
    }
  }

  /// Cache user profile data
  Future<bool> cacheUserProfile(Map<String, dynamic> userProfile) async {
    final cacheData = {
      'data': userProfile,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiration': DateTime.now().add(const Duration(hours: _userProfileCacheExpirationHours)).millisecondsSinceEpoch,
    };
    return await _sharedPreferences.setString(_userProfileKey, jsonEncode(cacheData));
  }

  /// Get cached user profile if not expired
  Map<String, dynamic>? getCachedUserProfile() {
    return _getCachedData(_userProfileKey);
  }

  /// Cache app settings
  Future<bool> cacheAppSettings(Map<String, dynamic> settings) async {
    return await _sharedPreferences.setString(_appSettingsKey, jsonEncode(settings));
  }

  /// Get cached app settings
  Map<String, dynamic>? getCachedAppSettings() {
    final cached = _sharedPreferences.getString(_appSettingsKey);
    if (cached == null) return null;

    try {
      return jsonDecode(cached) as Map<String, dynamic>;
    } catch (e) {
      _sharedPreferences.remove(_appSettingsKey);
      return null;
    }
  }

  /// Cache work calendar data
  Future<bool> cacheWorkCalendar(List<Map<String, dynamic>> calendarData) async {
    final cacheData = {
      'data': calendarData,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiration': DateTime.now().add(const Duration(hours: _defaultCacheExpirationHours)).millisecondsSinceEpoch,
    };
    return await _sharedPreferences.setString(_workCalendarKey, jsonEncode(cacheData));
  }

  /// Get cached work calendar data
  List<Map<String, dynamic>>? getCachedWorkCalendar() {
    final cached = _sharedPreferences.getString(_workCalendarKey);
    if (cached == null) return null;

    try {
      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      final expiration = cacheData['expiration'] as int;

      if (DateTime.now().millisecondsSinceEpoch > expiration) {
        _sharedPreferences.remove(_workCalendarKey);
        return null;
      }

      return List<Map<String, dynamic>>.from(cacheData['data'] as List);
    } catch (e) {
      _sharedPreferences.remove(_workCalendarKey);
      return null;
    }
  }

  /// Set last synchronization time
  Future<bool> setLastSyncTime(DateTime syncTime) async {
    return await _sharedPreferences.setInt(_lastSyncTimeKey, syncTime.millisecondsSinceEpoch);
  }

  /// Get last synchronization time
  DateTime? getLastSyncTime() {
    final timestamp = _sharedPreferences.getInt(_lastSyncTimeKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Check if app should work in offline mode
  bool isOfflineModeEnabled() {
    return _sharedPreferences.getBool(_offlineModeKey) ?? false;
  }

  /// Set offline mode preference
  Future<bool> setOfflineMode(bool enabled) async {
    return await _sharedPreferences.setBool(_offlineModeKey, enabled);
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    final allKeys = _sharedPreferences.getKeys();
    final cacheKeys = allKeys.where(
      (key) => key.startsWith('cached_') || key.startsWith(_projectDetailPrefix) || key == _lastSyncTimeKey,
    );

    for (final key in cacheKeys) {
      await _sharedPreferences.remove(key);
    }
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final allKeys = _sharedPreferences.getKeys();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    for (final key in allKeys) {
      if (key.startsWith('cached_') || key.startsWith(_projectDetailPrefix)) {
        final cached = _sharedPreferences.getString(key);
        if (cached != null) {
          try {
            final cacheData = jsonDecode(cached) as Map<String, dynamic>;
            final expiration = cacheData['expiration'] as int?;

            if (expiration != null && currentTime > expiration) {
              await _sharedPreferences.remove(key);
            }
          } catch (e) {
            // Invalid cache data, remove it
            await _sharedPreferences.remove(key);
          }
        }
      }
    }
  }

  /// Generic method to get cached data with expiration check
  Map<String, dynamic>? _getCachedData(String key) {
    final cached = _sharedPreferences.getString(key);
    if (cached == null) return null;

    try {
      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      final expiration = cacheData['expiration'] as int?;

      if (expiration != null && DateTime.now().millisecondsSinceEpoch > expiration) {
        _sharedPreferences.remove(key);
        return null;
      }

      return cacheData['data'] as Map<String, dynamic>;
    } catch (e) {
      _sharedPreferences.remove(key);
      return null;
    }
  }

  /// Get cache statistics for debugging
  Map<String, dynamic> getCacheStatistics() {
    final allKeys = _sharedPreferences.getKeys();
    final cacheKeys = allKeys
        .where((key) => key.startsWith('cached_') || key.startsWith(_projectDetailPrefix))
        .toList();

    int totalCacheEntries = cacheKeys.length;
    int expiredEntries = 0;
    int validEntries = 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    for (final key in cacheKeys) {
      final cached = _sharedPreferences.getString(key);
      if (cached != null) {
        try {
          final cacheData = jsonDecode(cached) as Map<String, dynamic>;
          final expiration = cacheData['expiration'] as int?;

          if (expiration != null && currentTime > expiration) {
            expiredEntries++;
          } else {
            validEntries++;
          }
        } catch (e) {
          expiredEntries++;
        }
      }
    }

    return {
      'totalCacheEntries': totalCacheEntries,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'lastSyncTime': getLastSyncTime()?.toIso8601String(),
      'offlineModeEnabled': isOfflineModeEnabled(),
    };
  }
}
