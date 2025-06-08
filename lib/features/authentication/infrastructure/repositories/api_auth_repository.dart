import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response_model.dart';
import '../services/auth_api_service.dart';

/// API-based implementation of AuthRepository
@Named('api')
@LazySingleton(as: AuthRepository)
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._apiService, this._secureStorage);

  final AuthApiService _apiService;
  final FlutterSecureStorage _secureStorage;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'cached_user';

  @override
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // For API login, we use username field but pass email
      final request = LoginRequestModel(username: email, password: password);
      final response = await _apiService.login(request);

      if (!response.success || response.data == null) {
        throw Exception(response.message);
      }

      final authData = response.data!;

      // Store tokens securely
      await _secureStorage.write(key: _tokenKey, value: authData.token);
      if (authData.refreshToken != null) {
        await _secureStorage.write(
          key: _refreshTokenKey,
          value: authData.refreshToken!,
        );
      }

      // Cache user data
      final user = authData.user.toEntity();
      await _cacheUser(user);

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid email or password');
      }
      throw Exception('Login failed: ${e.message}');
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<User> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Extract username from email (before @)
      final username = email.split('@').first;

      final request = RegisterRequestModel(
        username: username,
        email: email,
        password: password,
        fullName: name,
        roleId: 2, // Default role ID for Technician
      );

      final response = await _apiService.register(request);

      if (!response.success || response.data == null) {
        throw Exception(response.message);
      }

      // For registration, we might need to login after successful registration
      // Or the API might return tokens directly
      if (response.data!.token.isNotEmpty) {
        await _secureStorage.write(key: _tokenKey, value: response.data!.token);
        if (response.data!.refreshToken != null) {
          await _secureStorage.write(
            key: _refreshTokenKey,
            value: response.data!.refreshToken!,
          );
        }
      }

      final user = response.data!.user.toEntity();
      await _cacheUser(user);

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('User already exists');
      }
      throw Exception('Registration failed: ${e.message}');
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    // API might not support Google Sign-In directly
    // This would typically involve OAuth2 flow
    throw UnimplementedError('Google Sign-In not supported in API mode');
  }

  @override
  Future<User> signInWithApple() async {
    // API might not support Apple Sign-In directly
    // This would typically involve OAuth2 flow
    throw UnimplementedError('Apple Sign-In not supported in API mode');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // This would need a password reset endpoint
    throw UnimplementedError('Password reset not implemented for API mode');
  }

  @override
  Future<void> signOut() async {
    try {
      // Try to call logout endpoint if available
      await _apiService.logout();
    } catch (e) {
      // Continue with local cleanup even if API call fails
      print('Logout API call failed: $e');
    }

    // Clear stored tokens and user data
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userKey);
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      // First check cached user
      final cachedUser = await _getCachedUser();
      if (cachedUser != null) {
        return cachedUser;
      }

      // If no cached user but we have a token, fetch from API
      final token = await getAuthToken();
      if (token != null) {
        final response = await _apiService.getProfile();
        if (response.success && response.data != null) {
          final user = response.data!.user.toEntity();
          await _cacheUser(user);
          return user;
        }
      }

      return null;
    } catch (e) {
      print('Get current user failed: $e');
      return null;
    }
  }

  @override
  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  @override
  Future<void> storeAuthToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<void> removeAuthToken() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> sendEmailVerification() async {
    throw UnimplementedError('Email verification not implemented for API mode');
  }

  @override
  Future<void> verifyEmail(String verificationCode) async {
    throw UnimplementedError('Email verification not implemented for API mode');
  }

  @override
  Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    throw UnimplementedError('Profile update not implemented for API mode');
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    throw UnimplementedError('Password change not implemented for API mode');
  }

  @override
  Future<void> deleteAccount() async {
    throw UnimplementedError('Account deletion not implemented for API mode');
  }

  /// Refresh authentication token
  Future<String?> refreshAuthToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) return null;

      final request = RefreshTokenRequestModel(refreshToken: refreshToken);
      final response = await _apiService.refreshToken(request);

      if (response.success && response.data != null) {
        await _secureStorage.write(key: _tokenKey, value: response.data!);
        return response.data!;
      }

      return null;
    } catch (e) {
      print('Token refresh failed: $e');
      return null;
    }
  }

  /// Cache user data locally
  Future<void> _cacheUser(User user) async {
    final userJson = user.toModel().toJson();
    await _secureStorage.write(key: _userKey, value: userJson.toString());
  }

  /// Get cached user data
  Future<User?> _getCachedUser() async {
    try {
      final userJsonString = await _secureStorage.read(key: _userKey);
      if (userJsonString != null) {
        // Note: This is a simplified approach. In production, you'd use proper JSON parsing
        // For now, we'll return null and rely on API calls
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
