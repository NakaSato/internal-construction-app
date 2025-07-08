import 'package:dio/dio.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/api_response.dart';
import '../models/auth_models.dart';

/// Enhanced authentication API service
class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  /// User login with enhanced error handling
  Future<ApiResponse<LoginResponse>> login({required String username, required String password}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.authLogin,
        data: {'username': username, 'password': password},
      );

      return ApiResponse.fromJson(response.data, (json) => LoginResponse.fromJson(json as Map<String, dynamic>));
    } on DioException catch (e) {
      return _handleAuthError<LoginResponse>(e);
    }
  }

  /// Refresh authentication token
  Future<ApiResponse<String>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.authRefresh,
        data: refreshToken,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return ApiResponse.fromJson(response.data, (json) => json as String);
    } on DioException catch (e) {
      return _handleAuthError<String>(e);
    }
  }

  /// User logout
  Future<ApiResponse<bool>> logout() async {
    try {
      final response = await _apiClient.dio.post(ApiConfig.authLogout);

      return ApiResponse.fromJson(response.data, (json) => json as bool);
    } on DioException catch (e) {
      return _handleAuthError<bool>(e);
    }
  }

  /// Handle authentication-specific errors
  ApiResponse<T> _handleAuthError<T>(DioException error) {
    String message = 'An error occurred';
    List<String> errors = [];

    switch (error.response?.statusCode) {
      case 400:
        message = 'Invalid credentials';
        break;
      case 401:
        message = 'Unauthorized access';
        break;
      case 403:
        message = 'Access forbidden';
        break;
      case 404:
        message = 'Service not found';
        break;
      case 422:
        message = 'Validation failed';
        if (error.response?.data != null) {
          final data = error.response!.data;
          if (data['errors'] != null) {
            errors = (data['errors'] as List).cast<String>();
          }
        }
        break;
      case 500:
        message = 'Server error';
        break;
      default:
        message = error.message ?? 'Network error';
    }

    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors.isNotEmpty ? errors : null,
      error: error.response?.data,
    );
  }
}
