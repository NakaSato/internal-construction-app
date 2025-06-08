import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../config/app_constants.dart';
import '../config/environment_config.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio() {
    final dio = Dio();

    // Base configuration
    dio.options = BaseOptions(
      baseUrl: EnvironmentConfig.apiBaseUrl,
      connectTimeout: AppConstants.apiTimeout,
      receiveTimeout: AppConstants.apiTimeout,
      sendTimeout: AppConstants.apiTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    if (EnvironmentConfig.enableDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
        ),
      );
    }

    // Add auth interceptor
    dio.interceptors.add(AuthInterceptor());

    // Add error interceptor
    dio.interceptors.add(ErrorInterceptor());

    return dio;
  }
}

/// Interceptor for adding authentication tokens to requests
class AuthInterceptor extends Interceptor {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login/register endpoints
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh')) {
      handler.next(options);
      return;
    }

    // Add authentication token from secure storage
    final token = await _secureStorage.read(key: _tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token refresh on 401 errors
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/')) {
      try {
        final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
        if (refreshToken != null) {
          // Try to refresh the token
          final refreshResponse = await _refreshToken(refreshToken);
          if (refreshResponse != null) {
            // Update token and retry request
            await _secureStorage.write(key: _tokenKey, value: refreshResponse);
            err.requestOptions.headers['Authorization'] =
                'Bearer $refreshResponse';

            // Retry the original request
            final response = await Dio().fetch(err.requestOptions);
            handler.resolve(response);
            return;
          }
        }

        // If refresh failed, clear tokens and redirect to login
        await _secureStorage.delete(key: _tokenKey);
        await _secureStorage.delete(key: _refreshTokenKey);
        // TODO: Navigate to login screen
      } catch (e) {
        print('Token refresh failed: $e');
        // Clear tokens on refresh failure
        await _secureStorage.delete(key: _tokenKey);
        await _secureStorage.delete(key: _refreshTokenKey);
      }
    }

    handler.next(err);
  }

  /// Refresh authentication token
  Future<String?> _refreshToken(String refreshToken) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        '${EnvironmentConfig.apiBaseUrl}/api/v1/Auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as String?;
      }
      return null;
    } catch (e) {
      print('Token refresh API call failed: $e');
      return null;
    }
  }
}

/// Interceptor for handling common errors
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        message = _handleStatusCode(err.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet connection.';
        break;
      case DioExceptionType.unknown:
        message = 'An unexpected error occurred.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Certificate error.';
        break;
    }

    // Create a custom error with user-friendly message
    final customError = DioException(
      requestOptions: err.requestOptions,
      message: message,
      type: err.type,
      response: err.response,
    );

    handler.next(customError);
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Forbidden. You don\'t have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 422:
        return 'Validation error. Please check your input.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
