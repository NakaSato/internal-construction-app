import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';

/// Abstract class for all use cases in the application
///
/// This provides a consistent interface for business logic operations
/// following Clean Architecture principles.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// For use cases that don't require parameters
class NoParams {}
