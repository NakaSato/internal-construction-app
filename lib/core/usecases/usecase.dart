import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Abstract class for all use cases in the application
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// For use cases that don't require parameters
class NoParams {}
