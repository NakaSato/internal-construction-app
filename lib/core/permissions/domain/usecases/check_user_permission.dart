import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../error/failures.dart';
import '../../../usecases/usecase.dart';
import '../entities/permission.dart';
import '../repositories/permission_repository.dart';

/// Use case for checking if a user has a specific permission
class CheckUserPermissionUseCase implements UseCase<bool, CheckUserPermissionParams> {
  const CheckUserPermissionUseCase(this.repository);

  final PermissionRepository repository;

  @override
  Future<Either<Failure, bool>> call(CheckUserPermissionParams params) async {
    return await repository.checkUserPermission(
      params.userId,
      params.resource,
      params.action,
    );
  }
}

class CheckUserPermissionParams extends Equatable {
  const CheckUserPermissionParams({
    required this.userId,
    required this.resource,
    required this.action,
  });

  final String userId;
  final String resource;
  final String action;

  @override
  List<Object?> get props => [userId, resource, action];
}
