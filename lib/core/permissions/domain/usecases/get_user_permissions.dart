import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../error/failures.dart';
import '../../../usecases/usecase.dart';
import '../entities/permission.dart';
import '../repositories/permission_repository.dart';

/// Use case for getting user's complete permission context
class GetUserPermissionsUseCase implements UseCase<UserPermissionContext, GetUserPermissionsParams> {
  const GetUserPermissionsUseCase(this.repository);

  final PermissionRepository repository;

  @override
  Future<Either<Failure, UserPermissionContext>> call(GetUserPermissionsParams params) async {
    // Try to get from cache first if requested
    if (params.useCache) {
      final cachedResult = await repository.getCachedUserPermissions(params.userId);
      if (cachedResult.isRight()) {
        final cached = cachedResult.getOrElse(() => null);
        if (cached != null) {
          return Right(cached);
        }
      }
    }

    // Get from remote source
    final result = await repository.getUserPermissions(params.userId);
    
    // Cache the result if successful
    if (result.isRight() && params.cacheResult) {
      final permissions = result.getOrElse(() => throw Exception('Unexpected null'));
      await repository.cacheUserPermissions(permissions);
    }
    
    return result;
  }
}

class GetUserPermissionsParams extends Equatable {
  const GetUserPermissionsParams({
    required this.userId,
    this.useCache = true,
    this.cacheResult = true,
  });

  final String userId;
  final bool useCache;
  final bool cacheResult;

  @override
  List<Object?> get props => [userId, useCache, cacheResult];
}
