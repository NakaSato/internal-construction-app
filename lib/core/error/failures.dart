import 'package:equatable/equatable.dart';

/// Base failure class for error handling
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Server-related failures
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(String message, {this.statusCode}) : super(message);

  @override
  List<Object> get props => [message, if (statusCode != null) statusCode!];
}

/// Network connection failures
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Local database related failures
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure(String message) : super(message);
}

/// Cache related failures
class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(String message, {this.fieldErrors}) : super(message);

  @override
  List<Object> get props => [message, if (fieldErrors != null) fieldErrors!];
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

/// Authorization failures
class ForbiddenFailure extends Failure {
  const ForbiddenFailure(String message) : super(message);
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message);
}

/// Generic application failures
class AppFailure extends Failure {
  const AppFailure(String message) : super(message);
}

/// Unexpected/unknown failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String message) : super(message);
}
