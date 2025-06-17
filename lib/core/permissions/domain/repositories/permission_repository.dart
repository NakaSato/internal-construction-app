import 'package:dartz/dartz.dart';
import '../../../error/failures.dart';
import '../entities/permission.dart';

/// Repository interface for permission management
abstract class PermissionRepository {
  /// Get user's permission context by user ID
  Future<Either<Failure, UserPermissionContext>> getUserPermissions(String userId);
  
  /// Get all available permissions in the system
  Future<Either<Failure, List<Permission>>> getAllPermissions();
  
  /// Get all available roles in the system
  Future<Either<Failure, List<Role>>> getAllRoles();
  
  /// Get role by ID
  Future<Either<Failure, Role>> getRoleById(String roleId);
  
  /// Get permission by ID
  Future<Either<Failure, Permission>> getPermissionById(String permissionId);
  
  /// Check if user has specific permission
  Future<Either<Failure, bool>> checkUserPermission(
    String userId,
    String resource,
    String action,
  );
  
  /// Get permissions for a specific resource
  Future<Either<Failure, List<Permission>>> getPermissionsForResource(String resource);
  
  /// Update user's roles
  Future<Either<Failure, void>> updateUserRoles(String userId, List<String> roleIds);
  
  /// Add direct permission to user
  Future<Either<Failure, void>> addDirectPermissionToUser(
    String userId,
    String permissionId,
  );
  
  /// Remove direct permission from user
  Future<Either<Failure, void>> removeDirectPermissionFromUser(
    String userId,
    String permissionId,
  );
  
  /// Cache user permissions locally
  Future<Either<Failure, void>> cacheUserPermissions(UserPermissionContext context);
  
  /// Get cached user permissions
  Future<Either<Failure, UserPermissionContext?>> getCachedUserPermissions(String userId);
  
  /// Clear cached permissions
  Future<Either<Failure, void>> clearCachedPermissions(String userId);
}
