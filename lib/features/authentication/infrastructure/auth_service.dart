import 'package:dio/dio.dart';
import '../../../core/utils/api_error_parser.dart';

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<AuthResult> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      // Handle successful response
      return AuthResult.success(response.data);
    } on DioException catch (e) {
      final errorMessage = ApiErrorParser.parseError(e);
      throw AuthException(errorMessage);
    } catch (e) {
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}

class AuthResult {
  final bool isSuccess;
  final dynamic data;
  final String? error;

  AuthResult.success(this.data) : isSuccess = true, error = null;
  AuthResult.failure(this.error) : isSuccess = false, data = null;
}
