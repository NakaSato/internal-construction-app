import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
