import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Configuration class for API client settings
class ApiConfig {
  static const String baseUrl = 'http://localhost:5001';
  static const String apiVersion = 'api/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Authentication endpoints
  static const String authPath = '/Auth';
  static const String loginPath = '/Auth/login';
  static const String registerPath = '/Auth/register';
  static const String refreshPath = '/Auth/refresh';
  static const String logoutPath = '/Auth/logout';

  // Core feature endpoints
  static const String projectsPath = '/Projects';
  static const String usersPath = '/users';
  static const String tasksPath = '/tasks';
  static const String calendarPath = '/Calendar';
  static const String dailyReportsPath = '/daily-reports';
  static const String weeklyReportsPath = '/weekly-reports';
  static const String weeklyRequestsPath = '/weekly-requests';
  static const String workRequestsPath = '/work-requests';
  static const String resourcesPath = '/resources';
  static const String masterPlansPath = '/master-plans';
  static const String phasesPath = '/phases';
  static const String imagesPath = '/images';
  static const String documentsPath = '/documents';
  static const String notificationsPath = '/notifications';
  static const String dashboardPath = '/dashboard';

  // Health and debug endpoints
  static const String healthPath = '/Health';
  static const String debugPath = '/api/Debug';
}

/// Enhanced API client with authentication, error handling, and logging
class ApiClient {
  late final Dio _dio;
  String? _authToken;

  ApiClient({String? baseUrl, String? authToken}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (authToken != null) {
      setAuthToken(authToken);
    }

    _setupInterceptors();
  }

  Dio get dio => _dio;

  /// Set up request/response interceptors for logging and error handling
  void _setupInterceptors() {
    // Request interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }

          if (kDebugMode) {
            print('🚀 API Request: ${options.method} ${options.path}');
            if (options.queryParameters.isNotEmpty) {
              print('📋 Query Parameters: ${options.queryParameters}');
            }
            if (options.data != null) {
              print('📦 Request Data: ${options.data}');
            }
          }

          handler.next(options);
        },

        onResponse: (response, handler) {
          if (kDebugMode) {
            print(
              '✅ API Response: ${response.statusCode} ${response.requestOptions.path}',
            );
            if (response.data != null) {
              print('📄 Response Data: ${response.data}');
            }
          }
          handler.next(response);
        },

        onError: (error, handler) {
          if (kDebugMode) {
            print(
              '❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}',
            );
            print('🔍 Error Message: ${error.message}');
            if (error.response?.data != null) {
              print('📄 Error Data: ${error.response?.data}');
            }
          }
          handler.next(error);
        },
      ),
    );

    // Retry interceptor for failed requests
    _dio.interceptors.add(RetryInterceptor());
  }

  /// Set authentication token for API requests
  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  /// GET request with enhanced error handling
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// POST request with enhanced error handling
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// PUT request with enhanced error handling
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// DELETE request with enhanced error handling
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// PATCH request with enhanced error handling
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Handle Dio exceptions and convert to app-specific exceptions
  ApiException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 408,
          type: ApiExceptionType.timeout,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final message =
            _extractErrorMessage(e.response?.data) ?? 'Server error occurred';

        switch (statusCode) {
          case 400:
            return ApiException(
              message: message,
              statusCode: statusCode,
              type: ApiExceptionType.badRequest,
            );
          case 401:
            return ApiException(
              message: 'Authentication required. Please log in again.',
              statusCode: statusCode,
              type: ApiExceptionType.unauthorized,
            );
          case 403:
            return ApiException(
              message: 'Access forbidden. You don\'t have permission.',
              statusCode: statusCode,
              type: ApiExceptionType.forbidden,
            );
          case 404:
            return ApiException(
              message: 'Resource not found.',
              statusCode: statusCode,
              type: ApiExceptionType.notFound,
            );
          case 422:
            return ApiException(
              message: message,
              statusCode: statusCode,
              type: ApiExceptionType.validationError,
            );
          case 500:
            return ApiException(
              message: 'Internal server error. Please try again later.',
              statusCode: statusCode,
              type: ApiExceptionType.serverError,
            );
          default:
            return ApiException(
              message: message,
              statusCode: statusCode,
              type: ApiExceptionType.unknown,
            );
        }

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled',
          statusCode: 0,
          type: ApiExceptionType.cancelled,
        );

      case DioExceptionType.unknown:
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Network error. Please check your connection.',
          statusCode: 0,
          type: ApiExceptionType.network,
        );
    }
  }

  /// Extract error message from response data
  String? _extractErrorMessage(dynamic data) {
    if (data == null) return null;

    if (data is Map<String, dynamic>) {
      // Try common error message fields
      final message =
          data['message'] ??
          data['error'] ??
          data['detail'] ??
          data['description'];

      if (message is String) return message;

      // Handle validation errors
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
          return firstError.toString();
        }
      }
    }

    return null;
  }

  /// Dispose of the client
  void dispose() {
    _dio.close();
  }
}

/// Custom retry interceptor
class RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 0;
    }

    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      await Future.delayed(retryDelay * (retryCount + 1));

      try {
        final dio = Dio();
        dio.options = err.requestOptions.copyWith() as BaseOptions;
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

/// API exception types for better error handling
enum ApiExceptionType {
  timeout,
  network,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  validationError,
  serverError,
  cancelled,
  unknown,
}

/// Custom API exception class
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final ApiExceptionType type;
  final dynamic data;

  const ApiException({
    required this.message,
    required this.statusCode,
    required this.type,
    this.data,
  });

  @override
  String toString() {
    return 'ApiException(message: $message, statusCode: $statusCode, type: $type)';
  }
}

/// Result wrapper for API responses
class ApiResult<T> {
  final T? data;
  final ApiException? error;
  final bool isSuccess;

  const ApiResult._({this.data, this.error, required this.isSuccess});

  /// Create a successful result
  factory ApiResult.success(T data) {
    return ApiResult._(data: data, isSuccess: true);
  }

  /// Create a failed result
  factory ApiResult.failure(ApiException error) {
    return ApiResult._(error: error, isSuccess: false);
  }

  /// Execute a function on success
  ApiResult<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return ApiResult.success(mapper(data as T));
      } catch (e) {
        return ApiResult.failure(
          ApiException(
            message: e.toString(),
            statusCode: 0,
            type: ApiExceptionType.unknown,
          ),
        );
      }
    }
    return ApiResult.failure(error!);
  }

  /// Execute a function on failure
  ApiResult<T> onError(void Function(ApiException error) handler) {
    if (!isSuccess && error != null) {
      handler(error!);
    }
    return this;
  }
}
