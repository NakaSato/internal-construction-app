import '../entities/role.dart';
import '../entities/permission.dart';

/// Repository interface for authorization operations
abstract class AuthorizationRepository {
  /// Get role by name
  Future<Role?> getRoleByName(String roleName);

  /// Get all available roles
  Future<List<Role>> getAllRoles();

  /// Get permissions for a specific role
  Future<List<Permission>> getPermissionsForRole(String roleId);

  /// Check if a role has a specific permission
  Future<bool> hasRolePermission(
    String roleName,
    String resource,
    String action,
  );

  /// Get all permissions
  Future<List<Permission>> getAllPermissions();

  /// Cache role data locally
  Future<void> cacheRoleData(Role role);

  /// Get cached role data
  Future<Role?> getCachedRole(String roleName);

  /// Clear role cache
  Future<void> clearRoleCache();
}
