import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
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
      if (authData.token != null) {
        await _secureStorage.write(key: _tokenKey, value: authData.token!);
      }
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

      // Registration only returns user data, not tokens
      // User needs to login after registration
      final user = response.data!.toEntity();
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
  Future<void> sendPasswordResetEmail(String email) async {
    // This would need a password reset endpoint
    throw UnimplementedError('Password reset not implemented for API mode');
  }

  @override
  Future<void> signOut() async {
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

      // If no cached user but we have a token, we can't fetch from API
      // since there's no profile endpoint in the spec
      // Return null and let the app handle re-authentication
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Get current user failed: $e');
      }
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
  Future<User> verifyEmail(String verificationCode) async {
    throw UnimplementedError('Email verification not implemented for API mode');
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    throw UnimplementedError('Profile update not implemented for API mode');
  }

  @override
  Stream<User?> get authStateChanges {
    // For API auth, we can't easily stream auth state changes like Firebase
    // Return a simple stream that checks current user periodically
    return Stream.periodic(const Duration(seconds: 30), (_) async {
      return await getCurrentUser();
    }).asyncMap((future) => future);
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

      final response = await _apiService.refreshToken(refreshToken);

      if (response.success && response.data != null) {
        await _secureStorage.write(key: _tokenKey, value: response.data!);
        return response.data!;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Token refresh failed: $e');
      }
      return null;
    }
  }

  /// Cache user data locally
  Future<void> _cacheUser(User user) async {
    final userJson = user.toModel().toJson();
    await _secureStorage.write(key: _userKey, value: jsonEncode(userJson));
  }

  /// Get cached user data
  Future<User?> _getCachedUser() async {
    try {
      final userJsonString = await _secureStorage.read(key: _userKey);
      if (userJsonString != null && userJsonString.isNotEmpty) {
        final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
        final userModel = UserModel.fromJson(userJson);
        return userModel.toEntity();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get cached user: $e');
      }
      return null;
    }
  }
}
