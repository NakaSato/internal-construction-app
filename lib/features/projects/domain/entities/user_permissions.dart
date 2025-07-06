/// User role enumeration for role-based access control
enum UserRole { admin, manager, user }

/// Extension on UserRole for string conversion and permission checking
extension UserRoleExtension on UserRole {
  static UserRole fromString(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
      case 'administrator':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'user':
      case 'viewer':
      default:
        return UserRole.user;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.manager:
        return 'Manager';
      case UserRole.user:
        return 'User';
    }
  }

  /// Check if this role can create projects
  bool get canCreate {
    switch (this) {
      case UserRole.admin:
      case UserRole.manager:
        return true;
      case UserRole.user:
        return false;
    }
  }

  /// Check if this role can edit projects
  bool get canEdit {
    switch (this) {
      case UserRole.admin:
      case UserRole.manager:
        return true;
      case UserRole.user:
        return false;
    }
  }

  /// Check if this role can delete projects
  bool get canDelete {
    switch (this) {
      case UserRole.admin:
        return true;
      case UserRole.manager:
      case UserRole.user:
        return false;
    }
  }

  /// Check if this role can view all projects
  bool get canViewAll {
    return true; // All roles can view projects in this system
  }
}

/// Utility class for checking user permissions
class PermissionHelper {
  PermissionHelper._();

  /// Check if user has permission to create projects
  static bool canCreateProjects(String roleName) {
    return UserRoleExtension.fromString(roleName).canCreate;
  }

  /// Check if user has permission to edit projects
  static bool canEditProjects(String roleName) {
    return UserRoleExtension.fromString(roleName).canEdit;
  }

  /// Check if user has permission to delete projects
  static bool canDeleteProjects(String roleName) {
    return UserRoleExtension.fromString(roleName).canDelete;
  }

  /// Check if user has permission to view projects
  static bool canViewProjects(String roleName) {
    return UserRoleExtension.fromString(roleName).canViewAll;
  }

  /// Get user role from string
  static UserRole getUserRole(String roleName) {
    return UserRoleExtension.fromString(roleName);
  }
}
