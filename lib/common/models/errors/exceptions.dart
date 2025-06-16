/// Base exception class for all application exceptions
///
/// This provides a consistent interface for all exceptions throughout the app.
abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when server returns an error
class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);
}

/// Exception thrown when there's a network connectivity issue
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network connection failed']);
}

/// Exception thrown when cached data is not found
class CacheException extends AppException {
  const CacheException([super.message = 'Cache data not found']);
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  const AuthenticationException([super.message = 'Authentication failed']);
}

/// Exception thrown when authorization fails
class AuthorizationException extends AppException {
  const AuthorizationException([super.message = 'Authorization failed']);
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed']);
}

/// Exception thrown when a resource is not found
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

/// Exception thrown when a resource already exists
class ConflictException extends AppException {
  const ConflictException([super.message = 'Resource already exists']);
}

/// Exception thrown when request timeout occurs
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timeout']);
}
