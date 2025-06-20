import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../errors/failures.dart';
import '../../../usecases/usecase.dart';
import '../entities/permission.dart';
import '../repositories/permission_repository.dart';

/// Use case for checking multiple permissions at once
class CheckMultiplePermissionsUseCase
    implements UseCase<Map<String, bool>, CheckMultiplePermissionsParams> {
  const CheckMultiplePermissionsUseCase(this.repository);

  final PermissionRepository repository;

  @override
  Future<Either<Failure, Map<String, bool>>> call(
    CheckMultiplePermissionsParams params,
  ) async {
    try {
      final results = <String, bool>{};

      for (final check in params.permissionChecks) {
        final result = await repository.checkUserPermission(
          params.userId,
          check.resource,
          check.action,
        );

        result.fold(
          (failure) => results['${check.resource}:${check.action}'] = false,
          (hasPermission) =>
              results['${check.resource}:${check.action}'] = hasPermission,
        );
      }

      return Right(results);
    } catch (e) {
      return Left(UnknownFailure('Error checking multiple permissions: $e'));
    }
  }
}

class CheckMultiplePermissionsParams extends Equatable {
  const CheckMultiplePermissionsParams({
    required this.userId,
    required this.permissionChecks,
  });

  final String userId;
  final List<PermissionCheck> permissionChecks;

  @override
  List<Object?> get props => [userId, permissionChecks];
}
