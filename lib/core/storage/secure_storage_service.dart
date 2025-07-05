import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

/// Service for secure storage operations
@LazySingleton()
class SecureStorageService {
  const SecureStorageService(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'cached_user';

  /// Get the access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Get the refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// Get cached user data
  Future<String?> getCachedUser() async {
    return await _secureStorage.read(key: _userKey);
  }

  /// Save cached user data
  Future<void> saveCachedUser(String userData) async {
    await _secureStorage.write(key: _userKey, value: userData);
  }

  /// Clear cached user data
  Future<void> clearCachedUser() async {
    await _secureStorage.delete(key: _userKey);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
