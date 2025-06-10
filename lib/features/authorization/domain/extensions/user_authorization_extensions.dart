import '../../../authentication/domain/entities/user.dart';
import '../services/authorization_service.dart';
import '../guards/authorization_guard.dart';

/// Extensions for User entity to add authorization convenience methods
extension AuthorizationUserExtensions on User {
  /// Check if user has specific permission
  /// Note: This requires AuthorizationService to be passed in
  Future<bool> hasPermission(
    AuthorizationService authorizationService,
    String resource,
    String action,
  ) async {
    return await authorizationService.hasPermission(this, resource, action);
  }

  /// Check if user has resource access
  /// Note: This requires AuthorizationService to be passed in
  Future<bool> hasResourceAccess(
    AuthorizationService authorizationService,
    String resource,
  ) async {
    return await authorizationService.hasResourceAccess(this, resource);
  }

  /// Check if user can access using guard
  /// Note: This requires AuthorizationGuard to be passed in
  Future<bool> canAccess(
    AuthorizationGuard guard,
    String resource, [
    String action = 'view',
  ]) async {
    return await guard.canAccess(this, resource, action);
  }

  /// Check if user is admin
  /// Note: This requires AuthorizationService to be passed in
  Future<bool> isAdmin(AuthorizationService authorizationService) async {
    return await authorizationService.hasPermission(this, 'system', 'admin');
  }

  /// Check if user is manager
  /// Note: This requires AuthorizationService to be passed in
  Future<bool> isManager(AuthorizationService authorizationService) async {
    return await authorizationService.hasPermission(this, 'system', 'manage');
  }

  /// Check if user has elevated access (admin or manager)
  /// Note: This requires AuthorizationService to be passed in
  Future<bool> hasElevatedAccess(
    AuthorizationService authorizationService,
  ) async {
    final isAdminUser = await isAdmin(authorizationService);
    final isManagerUser = await isManager(authorizationService);
    return isAdminUser || isManagerUser;
  }

  /// Get user permissions
  /// Note: This requires AuthorizationService to be passed in
  Future<List<String>> getPermissionNames(
    AuthorizationService authorizationService,
  ) async {
    final permissions = await authorizationService.getUserPermissions(this);
    return permissions.map((p) => p.name).toList();
  }

  /// Check if user has any of the specified roles
  bool hasAnyRole(List<String> roleNames) {
    return roleNames.contains(roleName);
  }

  /// Check if user has specific role
  bool hasRole(String role) {
    return roleName == role;
  }

  /// Check if user is technician (based on existing role structure)
  bool get isTechnician => roleName.toLowerCase() == 'technician';

  /// Check if user is supervisor (if this role exists)
  bool get isSupervisor => roleName.toLowerCase() == 'supervisor';

  /// Check if user is customer (if this role exists)
  bool get isCustomer => roleName.toLowerCase() == 'customer';

  /// Get role display name
  String get roleDisplayName {
    return roleName
        .split(' ')
        .map((word) {
          return word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}

/// Static utility methods for common authorization checks
class AuthorizationUtils {
  /// Common resource names
  static const String scheduleResource = 'schedule';
  static const String workOrderResource = 'work-order';
  static const String customerResource = 'customer';
  static const String reportResource = 'report';
  static const String settingsResource = 'settings';
  static const String userResource = 'user';
  static const String systemResource = 'system';

  /// Common action names
  static const String viewAction = 'view';
  static const String createAction = 'create';
  static const String editAction = 'edit';
  static const String deleteAction = 'delete';
  static const String manageAction = 'manage';
  static const String adminAction = 'admin';
  static const String exportAction = 'export';
  static const String importAction = 'import';

  /// Check if role name is valid
  static bool isValidRole(String roleName) {
    const validRoles = [
      'technician',
      'supervisor',
      'manager',
      'admin',
      'customer',
    ];
    return validRoles.contains(roleName.toLowerCase());
  }

  /// Get role hierarchy level (higher number = more privileges)
  static int getRoleLevel(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return 4;
      case 'manager':
        return 3;
      case 'supervisor':
        return 2;
      case 'technician':
        return 1;
      case 'customer':
        return 0;
      default:
        return -1;
    }
  }

  /// Check if user has higher or equal role level than required
  static bool hasMinimumRoleLevel(String userRole, String requiredRole) {
    return getRoleLevel(userRole) >= getRoleLevel(requiredRole);
  }
}
