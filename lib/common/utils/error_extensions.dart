import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Extension to enhance DioException with better error analysis
extension DioExceptionAnalysis on DioException {
  /// Determines if this is a network connectivity issue
  bool get isNetworkError {
    return type == DioExceptionType.connectionError ||
        type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout ||
        (message?.contains('SocketException') ?? false);
  }

  /// Determines if this is a server error (5xx)
  bool get isServerError {
    final statusCode = response?.statusCode;
    return statusCode != null && statusCode >= 500 && statusCode < 600;
  }

  /// Determines if this is a client error (4xx)
  bool get isClientError {
    final statusCode = response?.statusCode;
    return statusCode != null && statusCode >= 400 && statusCode < 500;
  }

  /// Determines if this is an authentication error
  bool get isAuthError {
    return response?.statusCode == 401;
  }

  /// Determines if this is a permission error
  bool get isPermissionError {
    return response?.statusCode == 403;
  }

  /// Determines if this is a not found error
  bool get isNotFoundError {
    return response?.statusCode == 404;
  }

  /// Determines if this error might be temporary and worth retrying
  bool get isRetryable {
    // Network errors are usually retryable
    if (isNetworkError) return true;

    // Server errors (5xx) are usually retryable
    if (isServerError) return true;

    // Rate limiting (429) is retryable
    if (response?.statusCode == 429) return true;

    // Request timeout errors are retryable
    if (type == DioExceptionType.receiveTimeout || type == DioExceptionType.sendTimeout) return true;

    return false;
  }

  /// Gets the error message from the response body
  String? get serverMessage {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String? ?? data['detail'] as String?;
    }
    return null;
  }

  /// Gets validation errors from the response
  List<String> get validationErrors {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is List) {
        return errors.cast<String>();
      }
      if (errors is Map<String, dynamic>) {
        return errors.values.expand((e) => e is List ? e : [e]).cast<String>().toList();
      }
    }
    return [];
  }

  /// Creates a user-friendly error message
  String get userFriendlyMessage {
    // Check for specific server messages first
    final serverMsg = serverMessage;
    if (serverMsg != null) {
      // Handle specific known server errors
      if (serverMsg.contains('Object reference not set to an instance of an object')) {
        return 'The requested item was not found. It may have been deleted or moved.';
      }
      if (serverMsg.contains('Invalid GUID format')) {
        return 'Invalid ID format. Please check the link and try again.';
      }
      if (serverMsg.contains('Access denied')) {
        return 'You don\'t have permission to access this resource.';
      }
      return serverMsg;
    }

    // Handle by status code
    switch (response?.statusCode) {
      case 400:
        final errors = validationErrors;
        if (errors.isNotEmpty) {
          return 'Validation error: ${errors.first}';
        }
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication required. Please log in again.';
      case 403:
        return 'Access denied. You don\'t have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'Conflict detected. The resource may have been modified by another user.';
      case 422:
        final errors = validationErrors;
        if (errors.isNotEmpty) {
          return 'Validation failed: ${errors.join(', ')}';
        }
        return 'Invalid data provided. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error occurred. Please try again later.';
      case 502:
      case 503:
      case 504:
        return 'Service temporarily unavailable. Please try again.';
    }

    // Handle by error type
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. The server is taking too long to respond.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        if (message?.contains('SocketException') ?? false) {
          return 'Network connection error. Please check your internet.';
        }
        return 'An unexpected error occurred.';
      default:
        return 'Network error occurred. Please try again.';
    }
  }

  /// Creates debug information for developers
  String get debugInfo {
    final buffer = StringBuffer();
    buffer.writeln('DioException Debug Info:');
    buffer.writeln('  Type: $type');
    buffer.writeln('  Status Code: ${response?.statusCode}');
    buffer.writeln('  Request URL: ${requestOptions.uri}');
    buffer.writeln('  Request Method: ${requestOptions.method}');
    buffer.writeln('  Error Message: $message');

    if (response?.data != null) {
      buffer.writeln('  Response Data: ${response!.data}');
    }

    if (requestOptions.headers.isNotEmpty) {
      buffer.writeln('  Request Headers: ${requestOptions.headers}');
    }

    return buffer.toString();
  }
}

/// Helper class for creating standardized error responses
class ErrorResponse {
  const ErrorResponse({
    required this.message,
    this.isRetryable = false,
    this.statusCode,
    this.errorCode,
    this.debugInfo,
  });

  final String message;
  final bool isRetryable;
  final int? statusCode;
  final String? errorCode;
  final String? debugInfo;

  /// Creates ErrorResponse from DioException
  factory ErrorResponse.fromDioException(DioException e) {
    return ErrorResponse(
      message: e.userFriendlyMessage,
      isRetryable: e.isRetryable,
      statusCode: e.response?.statusCode,
      errorCode: e.type.name,
      debugInfo: kDebugMode ? e.debugInfo : null,
    );
  }

  /// Creates ErrorResponse from generic Exception
  factory ErrorResponse.fromException(Exception e) {
    return ErrorResponse(
      message: e.toString().replaceFirst('Exception: ', ''),
      isRetryable: false,
      debugInfo: kDebugMode ? e.toString() : null,
    );
  }

  /// Creates ErrorResponse for network errors
  factory ErrorResponse.networkError([String? customMessage]) {
    return ErrorResponse(
      message: customMessage ?? 'Network connection error. Please check your internet.',
      isRetryable: true,
      errorCode: 'NETWORK_ERROR',
    );
  }

  /// Creates ErrorResponse for validation errors
  factory ErrorResponse.validationError(String message) {
    return ErrorResponse(message: message, isRetryable: false, statusCode: 400, errorCode: 'VALIDATION_ERROR');
  }

  /// Creates ErrorResponse for authentication errors
  factory ErrorResponse.authError([String? customMessage]) {
    return ErrorResponse(
      message: customMessage ?? 'Authentication required. Please log in again.',
      isRetryable: false,
      statusCode: 401,
      errorCode: 'AUTH_ERROR',
    );
  }

  /// Creates ErrorResponse for permission errors
  factory ErrorResponse.permissionError([String? customMessage]) {
    return ErrorResponse(
      message: customMessage ?? 'You don\'t have permission to perform this action.',
      isRetryable: false,
      statusCode: 403,
      errorCode: 'PERMISSION_ERROR',
    );
  }

  /// Creates ErrorResponse for not found errors
  factory ErrorResponse.notFoundError([String? customMessage]) {
    return ErrorResponse(
      message: customMessage ?? 'The requested resource was not found.',
      isRetryable: false,
      statusCode: 404,
      errorCode: 'NOT_FOUND_ERROR',
    );
  }

  @override
  String toString() {
    return 'ErrorResponse(message: $message, isRetryable: $isRetryable, statusCode: $statusCode)';
  }
}
