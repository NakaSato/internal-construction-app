import 'package:dio/dio.dart';
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
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // TODO: Add authentication token from secure storage
    // final token = await AuthService.getToken();
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token refresh on 401 errors
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic
      // try {
      //   await AuthService.refreshToken();
      //   final newToken = await AuthService.getToken();
      //   if (newToken != null) {
      //     err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      //     final response = await Dio().fetch(err.requestOptions);
      //     handler.resolve(response);
      //     return;
      //   }
      // } catch (e) {
      //   // Redirect to login on refresh failure
      //   NavigationService.navigateToLogin();
      // }
    }

    handler.next(err);
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
