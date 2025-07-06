import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../storage/secure_storage_service.dart';

/// Service responsible for JWT token management, validation, and refresh operations.
///
/// This service follows the authentication best practices outlined in the API documentation:
/// - Secure token storage using flutter_secure_storage
/// - Automatic token refresh before expiration
/// - Token validation and parsing
/// - Secure logout with token cleanup
@LazySingleton()
class TokenService {
  const TokenService(this._secureStorage, this._dio);

  final SecureStorageService _secureStorage;
  final Dio _dio;

  // Token validation constants
  static const int _tokenRefreshThresholdMinutes = 5;
  static const String _apiBaseUrl = '/api/v1';

  /// Parse JWT token payload
  Map<String, dynamic>? _parseJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Check if JWT token is expired
  bool _isTokenExpired(String token) {
    final payload = _parseJwtPayload(token);
    if (payload == null) return true;

    final exp = payload['exp'];
    if (exp == null) return true;

    final expiryDate = DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
    return DateTime.now().isAfter(expiryDate);
  }

  /// Get JWT token expiry date
  DateTime? _getTokenExpiryDate(String token) {
    final payload = _parseJwtPayload(token);
    if (payload == null) return null;

    final exp = payload['exp'];
    if (exp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch((exp as int) * 1000);
  }

  /// Get the current access token from secure storage
  Future<String?> getAccessToken() async {
    return await _secureStorage.getAccessToken();
  }

  /// Get the current refresh token from secure storage
  Future<String?> getRefreshToken() async {
    return await _secureStorage.getRefreshToken();
  }

  /// Save authentication tokens securely
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await Future.wait([_secureStorage.saveAccessToken(accessToken), _secureStorage.saveRefreshToken(refreshToken)]);
  }

  /// Check if the current access token is valid and not expired
  Future<bool> isTokenValid() async {
    final token = await getAccessToken();
    if (token == null) return false;

    try {
      return !_isTokenExpired(token);
    } catch (e) {
      // Invalid token format
      return false;
    }
  }

  /// Check if the access token needs to be refreshed (expires within threshold)
  Future<bool> shouldRefreshToken() async {
    final token = await getAccessToken();
    if (token == null) return false;

    try {
      final expiryDate = _getTokenExpiryDate(token);
      if (expiryDate == null) return true;

      final now = DateTime.now();
      final timeUntilExpiry = expiryDate.difference(now);

      return timeUntilExpiry.inMinutes <= _tokenRefreshThresholdMinutes;
    } catch (e) {
      return true; // Refresh if we can't parse the token
    }
  }

  /// Extract user information from the current access token
  Future<Map<String, dynamic>?> getUserFromToken() async {
    final token = await getAccessToken();
    if (token == null) return null;

    try {
      final payload = _parseJwtPayload(token);
      if (payload == null) return null;

      return {
        'userId': payload['sub'] ?? payload['userId'],
        'username': payload['username'],
        'email': payload['email'],
        'fullName': payload['fullName'],
        'roleName': payload['roleName'],
        'roleId': payload['roleId'],
        'exp': payload['exp'],
        'iat': payload['iat'],
      };
    } catch (e) {
      return null;
    }
  }

  /// Get the user's role from the access token
  Future<String?> getUserRole() async {
    final userInfo = await getUserFromToken();
    return userInfo?['roleName'];
  }

  /// Get the user's ID from the access token
  Future<String?> getUserId() async {
    final userInfo = await getUserFromToken();
    return userInfo?['userId'];
  }

  /// Refresh the access token using the refresh token
  Future<TokenRefreshResult> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      return TokenRefreshResult.failure('No refresh token available');
    }

    try {
      final response = await _dio.post(
        '$_apiBaseUrl/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['token'];
        final newRefreshToken = data['refreshToken'];

        await saveTokens(accessToken: newAccessToken, refreshToken: newRefreshToken);

        return TokenRefreshResult.success(newAccessToken);
      } else {
        return TokenRefreshResult.failure('Token refresh failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Refresh token is invalid or expired
        await clearTokens();
        return TokenRefreshResult.failure('Refresh token expired');
      }
      return TokenRefreshResult.failure('Network error during token refresh');
    } catch (e) {
      return TokenRefreshResult.failure('Unexpected error during token refresh');
    }
  }

  /// Get a valid access token, refreshing if necessary
  Future<String?> getValidAccessToken() async {
    if (await isTokenValid() && !await shouldRefreshToken()) {
      return await getAccessToken();
    }

    final refreshResult = await refreshToken();
    if (refreshResult.isSuccess) {
      return refreshResult.token;
    }

    return null;
  }

  /// Clear all authentication tokens (logout)
  Future<void> clearTokens() async {
    await _secureStorage.clearTokens();
  }

  /// Logout the user by clearing tokens and optionally notifying the server
  Future<LogoutResult> logout({bool notifyServer = true}) async {
    try {
      if (notifyServer) {
        final token = await getAccessToken();
        if (token != null) {
          // Attempt to notify server of logout (best effort)
          try {
            await _dio.post(
              '$_apiBaseUrl/auth/logout',
              options: Options(headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}),
            );
          } catch (e) {
            // Continue with local logout even if server notification fails
          }
        }
      }

      await clearTokens();
      return LogoutResult.success();
    } catch (e) {
      return LogoutResult.failure('Error during logout: ${e.toString()}');
    }
  }

  /// Validate token format and structure
  bool isValidTokenFormat(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      // Try to decode the payload
      final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

      return payload is Map<String, dynamic>;
    } catch (e) {
      return false;
    }
  }

  /// Get token expiration time
  Future<DateTime?> getTokenExpirationTime() async {
    final token = await getAccessToken();
    if (token == null) return null;

    try {
      return _getTokenExpiryDate(token);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has specific role
  Future<bool> hasRole(String requiredRole) async {
    final userRole = await getUserRole();
    return userRole?.toLowerCase() == requiredRole.toLowerCase();
  }

  /// Check if user is admin
  Future<bool> isAdmin() async {
    return await hasRole('Admin');
  }

  /// Check if user is manager
  Future<bool> isManager() async {
    return await hasRole('Manager');
  }

  /// Check if user is technician
  Future<bool> isTechnician() async {
    return await hasRole('Technician');
  }
}

/// Result class for token refresh operations
class TokenRefreshResult {
  final bool isSuccess;
  final String? token;
  final String? error;

  const TokenRefreshResult._({required this.isSuccess, this.token, this.error});

  factory TokenRefreshResult.success(String token) {
    return TokenRefreshResult._(isSuccess: true, token: token);
  }

  factory TokenRefreshResult.failure(String error) {
    return TokenRefreshResult._(isSuccess: false, error: error);
  }
}

/// Result class for logout operations
class LogoutResult {
  final bool isSuccess;
  final String? error;

  const LogoutResult._({required this.isSuccess, this.error});

  factory LogoutResult.success() {
    return const LogoutResult._(isSuccess: true);
  }

  factory LogoutResult.failure(String error) {
    return LogoutResult._(isSuccess: false, error: error);
  }
}
