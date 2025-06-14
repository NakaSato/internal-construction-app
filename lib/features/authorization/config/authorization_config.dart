import '../domain/entities/permission.dart';
import '../domain/entities/role.dart';

/// Configuration for authorization system with predefined roles and permissions
class AuthorizationConfig {
  // Permission constants
  static const String userRead = 'user:read';
  static const String userWrite = 'user:write';
  static const String userDelete = 'user:delete';

  static const String workCalendarRead = 'work_calendar:read';
  static const String workCalendarWrite = 'work_calendar:write';
  static const String workCalendarDelete = 'work_calendar:delete';
  static const String workCalendarManage = 'work_calendar:manage';

  static const String calendarCreate = 'calendar:create';
  static const String calendarManage = 'calendar:manage';

  static const String systemAdmin = 'system:admin';
  static const String systemConfig = 'system:config';
  static const String userManagement = 'user:management';
  static const String roleManagement = 'role:management';

  static const String reportView = 'report:view';
  static const String reportGenerate = 'report:generate';
  static const String reportExport = 'report:export';

  // Role constants
  static const String adminRole = 'admin';
  static const String managerRole = 'manager';
  static const String employeeRole = 'employee';
  static const String guestRole = 'guest';

  /// Get all predefined permissions
  static List<Permission> getDefaultPermissions() {
    return [
      // User permissions
      const Permission(
        id: 'perm_user_read',
        name: userRead,
        resource: 'user',
        action: 'read',
        description: 'View user information',
      ),
      const Permission(
        id: 'perm_user_write',
        name: userWrite,
        resource: 'user',
        action: 'write',
        description: 'Create and update user information',
      ),
      const Permission(
        id: 'perm_user_delete',
        name: userDelete,
        resource: 'user',
        action: 'delete',
        description: 'Delete user accounts',
      ),

      // Work Calendar permissions
      const Permission(
        id: 'perm_calendar_read',
        name: workCalendarRead,
        resource: 'work_calendar',
        action: 'read',
        description: 'View work calendar and events',
      ),
      const Permission(
        id: 'perm_calendar_write',
        name: workCalendarWrite,
        resource: 'work_calendar',
        action: 'write',
        description: 'Create and update calendar events',
      ),
      const Permission(
        id: 'perm_calendar_delete',
        name: workCalendarDelete,
        resource: 'work_calendar',
        action: 'delete',
        description: 'Delete calendar events',
      ),
      const Permission(
        id: 'perm_calendar_manage',
        name: workCalendarManage,
        resource: 'work_calendar',
        action: 'manage',
        description: 'Manage calendar settings and configurations',
      ),

      // System permissions
      const Permission(
        id: 'perm_system_admin',
        name: systemAdmin,
        resource: 'system',
        action: 'admin',
        description: 'Full system administration access',
      ),
      const Permission(
        id: 'perm_system_config',
        name: systemConfig,
        resource: 'system',
        action: 'config',
        description: 'Configure system settings',
      ),
      const Permission(
        id: 'perm_user_management',
        name: userManagement,
        resource: 'user',
        action: 'management',
        description: 'Manage user accounts and profiles',
      ),
      const Permission(
        id: 'perm_role_management',
        name: roleManagement,
        resource: 'role',
        action: 'management',
        description: 'Manage roles and permissions',
      ),

      // Report permissions
      const Permission(
        id: 'perm_report_view',
        name: reportView,
        resource: 'report',
        action: 'view',
        description: 'View reports and analytics',
      ),
      const Permission(
        id: 'perm_report_generate',
        name: reportGenerate,
        resource: 'report',
        action: 'generate',
        description: 'Generate new reports',
      ),
      const Permission(
        id: 'perm_report_export',
        name: reportExport,
        resource: 'report',
        action: 'export',
        description: 'Export reports to external formats',
      ),
    ];
  }

  /// Get all predefined roles with their permissions
  static List<Role> getDefaultRoles() {
    final permissions = getDefaultPermissions();
    final permissionMap = {
      for (var permission in permissions) permission.name: permission,
    };

    return [
      // Admin role - full access
      Role(
        id: 'role_admin',
        name: adminRole,
        description: 'Full system access and administration',
        permissions: permissions, // All permissions
      ),

      // Manager role - management and team access
      Role(
        id: 'role_manager',
        name: managerRole,
        description: 'Team management and operational access',
        permissions: [
          permissionMap[userRead]!,
          permissionMap[userWrite]!,
          permissionMap[workCalendarRead]!,
          permissionMap[workCalendarWrite]!,
          permissionMap[workCalendarDelete]!,
          permissionMap[workCalendarManage]!,
          permissionMap[userManagement]!,
          permissionMap[reportView]!,
          permissionMap[reportGenerate]!,
          permissionMap[reportExport]!,
        ],
      ),

      // Employee role - standard user access
      Role(
        id: 'role_employee',
        name: employeeRole,
        description: 'Standard employee access',
        permissions: [
          permissionMap[userRead]!,
          permissionMap[workCalendarRead]!,
          permissionMap[workCalendarWrite]!,
          permissionMap[reportView]!,
        ],
      ),

      // Guest role - limited read-only access
      Role(
        id: 'role_guest',
        name: guestRole,
        description: 'Limited read-only access',
        permissions: [permissionMap[workCalendarRead]!],
      ),
    ];
  }

  /// Get role by name
  static Role? getRoleByName(String roleName) {
    try {
      return getDefaultRoles().firstWhere((role) => role.name == roleName);
    } catch (e) {
      return null;
    }
  }

  /// Get permission by name
  static Permission? getPermissionByName(String permissionName) {
    try {
      return getDefaultPermissions().firstWhere(
        (permission) => permission.name == permissionName,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if a role name is valid
  static bool isValidRole(String roleName) {
    return [adminRole, managerRole, employeeRole, guestRole].contains(roleName);
  }

  /// Get role hierarchy (higher index = higher authority)
  static List<String> getRoleHierarchy() {
    return [guestRole, employeeRole, managerRole, adminRole];
  }

  /// Check if role1 has higher authority than role2
  static bool hasHigherAuthority(String role1, String role2) {
    final hierarchy = getRoleHierarchy();
    final role1Index = hierarchy.indexOf(role1);
    final role2Index = hierarchy.indexOf(role2);

    if (role1Index == -1 || role2Index == -1) return false;
    return role1Index > role2Index;
  }
}
