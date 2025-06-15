import '../entities/permission.dart';
import '../entities/role.dart';
import '../repositories/authorization_repository.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../config/authorization_config.dart';

/// Service for authorization logic and permission checking
class AuthorizationService {
  const AuthorizationService(this._authorizationRepository);

  final AuthorizationRepository _authorizationRepository;

  /// Check if a user has a specific permission
  Future<bool> hasPermission(User user, String resource, String action) async {
    try {
      Role? role;
      
      // For the "User" role, use the default employee role from config
      if (user.roleName.toLowerCase() == 'user') {
        role = AuthorizationConfig.getRoleByName(AuthorizationConfig.employeeRole);
      } else {
        role = await _authorizationRepository.getRoleByName(user.roleName);
      }
      
      if (role == null || !role.isActive) return false;
      return role.hasPermission(resource, action);
    } catch (e) {
      return false;
    }
  }

  /// Check if a user has any permission for a resource
  Future<bool> hasResourceAccess(User user, String resource) async {
    try {
      Role? role;
      
      // For the "User" role, use the default employee role from config
      if (user.roleName.toLowerCase() == 'user') {
        role = AuthorizationConfig.getRoleByName(AuthorizationConfig.employeeRole);
      } else {
        role = await _authorizationRepository.getRoleByName(user.roleName);
      }
      
      if (role == null || !role.isActive) return false;
      return role.hasResourceAccess(resource);
    } catch (e) {
      return false;
    }
  }

  /// Get user's role with permissions
  Future<Role?> getUserRole(User user) async {
    try {
      // For the "User" role, use the default employee role from config
      if (user.roleName.toLowerCase() == 'user') {
        // Map "User" role to the employee role in our system
        return AuthorizationConfig.getRoleByName(AuthorizationConfig.employeeRole);
      }
      return await _authorizationRepository.getRoleByName(user.roleName);
    } catch (e) {
      return null;
    }
  }

  /// Get all permissions for a user
  Future<List<Permission>> getUserPermissions(User user) async {
    try {
      // For the "User" role, use the default employee role from config
      if (user.roleName.toLowerCase() == 'user') {
        final role = AuthorizationConfig.getRoleByName(AuthorizationConfig.employeeRole);
        return role?.permissions ?? [];
      }
      final role = await _authorizationRepository.getRoleByName(user.roleName);
      return role?.permissions ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Get permissions for a specific resource that user has access to
  Future<List<Permission>> getUserResourcePermissions(
    User user,
    String resource,
  ) async {
    try {
      Role? role;
      
      // For the "User" role, use the default employee role from config
      if (user.roleName.toLowerCase() == 'user') {
        role = AuthorizationConfig.getRoleByName(AuthorizationConfig.employeeRole);
      } else {
        role = await _authorizationRepository.getRoleByName(user.roleName);
      }
      
      if (role == null || !role.isActive) return [];
      return role.getResourcePermissions(resource);
    } catch (e) {
      return [];
    }
  }

  /// Check if user can perform multiple actions on a resource
  Future<bool> hasMultiplePermissions(
    User user,
    String resource,
    List<String> actions,
  ) async {
    try {
      Role? role;
      
      // For the "User" role, use the default employee role from config
      if (user.roleName.toLowerCase() == 'user') {
        role = AuthorizationConfig.getRoleByName(AuthorizationConfig.employeeRole);
      } else {
        role = await _authorizationRepository.getRoleByName(user.roleName);
      }
      
      if (role == null || !role.isActive) return false;
      return actions.every((action) => role!.hasPermission(resource, action));
    } catch (e) {
      return false;
    }
  }

  /// Check if user has any of the specified permissions
  Future<bool> hasAnyPermission(
    User user,
    String resource,
    List<String> actions,
  ) async {
    try {
      Role? role;
      
      // For the "User" role, use the default employee role from config
      if (user.roleName.toLowerCase() == 'user') {
        role = AuthorizationConfig.getRoleByName(AuthorizationConfig.employeeRole);
      } else {
        role = await _authorizationRepository.getRoleByName(user.roleName);
      }
      
      if (role == null || !role.isActive) return false;
      return actions.any((action) => role!.hasPermission(resource, action));
    } catch (e) {
      return false;
    }
  }

  /// Check if user role is active
  Future<bool> isUserRoleActive(User user) async {
    try {
      // For the "User" role, use the default employee role from config
      if (user.roleName.toLowerCase() == 'user') {
        final role = AuthorizationConfig.getRoleByName(AuthorizationConfig.employeeRole);
        return role?.isActive ?? false;
      }
      
      final role = await _authorizationRepository.getRoleByName(user.roleName);
      return role?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get all available roles (for admin purposes)
  Future<List<Role>> getAllRoles() async {
    try {
      return await _authorizationRepository.getAllRoles();
    } catch (e) {
      return [];
    }
  }

  /// Get all available permissions (for admin purposes)
  Future<List<Permission>> getAllPermissions() async {
    try {
      return await _authorizationRepository.getAllPermissions();
    } catch (e) {
      return [];
    }
  }
}
