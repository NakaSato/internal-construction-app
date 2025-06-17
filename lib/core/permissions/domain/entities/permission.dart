import 'package:equatable/equatable.dart';

/// Represents a permission in the system
class Permission extends Equatable {
  const Permission({
    required this.id,
    required this.name,
    required this.resource,
    required this.action,
    required this.description,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String resource;
  final String action;
  final String description;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, resource, action, description, isActive];

  Permission copyWith({
    String? id,
    String? name,
    String? resource,
    String? action,
    String? description,
    bool? isActive,
  }) {
    return Permission(
      id: id ?? this.id,
      name: name ?? this.name,
      resource: resource ?? this.resource,
      action: action ?? this.action,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Permission(id: $id, name: $name, resource: $resource, action: $action)';
  }
}

/// Represents a role in the system
class Role extends Equatable {
  const Role({
    required this.id,
    required this.name,
    required this.permissions,
    required this.description,
    this.isActive = true,
  });

  final String id;
  final String name;
  final List<Permission> permissions;
  final String description;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, permissions, description, isActive];

  /// Check if this role has a specific permission
  bool hasPermission(String resource, String action) {
    return permissions.any(
      (permission) =>
          permission.resource == resource &&
          permission.action == action &&
          permission.isActive,
    );
  }

  /// Get all permissions for a specific resource
  List<Permission> getPermissionsForResource(String resource) {
    return permissions
        .where(
          (permission) =>
              permission.resource == resource && permission.isActive,
        )
        .toList();
  }

  Role copyWith({
    String? id,
    String? name,
    List<Permission>? permissions,
    String? description,
    bool? isActive,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Role(id: $id, name: $name, permissionsCount: ${permissions.length})';
  }
}

/// Represents a user's permission context
class UserPermissionContext extends Equatable {
  const UserPermissionContext({
    required this.userId,
    required this.roles,
    required this.directPermissions,
    this.isActive = true,
  });

  final String userId;
  final List<Role> roles;
  final List<Permission> directPermissions;
  final bool isActive;

  @override
  List<Object?> get props => [userId, roles, directPermissions, isActive];

  /// Get all permissions (from roles and direct permissions)
  List<Permission> get allPermissions {
    final Set<Permission> permissionSet = {};
    
    // Add permissions from roles
    for (final role in roles) {
      if (role.isActive) {
        permissionSet.addAll(role.permissions.where((p) => p.isActive));
      }
    }
    
    // Add direct permissions
    permissionSet.addAll(directPermissions.where((p) => p.isActive));
    
    return permissionSet.toList();
  }

  /// Check if user has a specific permission
  bool hasPermission(String resource, String action) {
    if (!isActive) return false;
    
    // Check direct permissions
    final hasDirectPermission = directPermissions.any(
      (permission) =>
          permission.resource == resource &&
          permission.action == action &&
          permission.isActive,
    );
    
    if (hasDirectPermission) return true;
    
    // Check role permissions
    return roles.any(
      (role) => role.isActive && role.hasPermission(resource, action),
    );
  }

  /// Check if user has any of the specified permissions
  bool hasAnyPermission(List<PermissionCheck> checks) {
    return checks.any((check) => hasPermission(check.resource, check.action));
  }

  /// Check if user has all of the specified permissions
  bool hasAllPermissions(List<PermissionCheck> checks) {
    return checks.every((check) => hasPermission(check.resource, check.action));
  }

  /// Get all permissions for a specific resource
  List<Permission> getPermissionsForResource(String resource) {
    return allPermissions
        .where((permission) => permission.resource == resource)
        .toList();
  }

  UserPermissionContext copyWith({
    String? userId,
    List<Role>? roles,
    List<Permission>? directPermissions,
    bool? isActive,
  }) {
    return UserPermissionContext(
      userId: userId ?? this.userId,
      roles: roles ?? this.roles,
      directPermissions: directPermissions ?? this.directPermissions,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'UserPermissionContext(userId: $userId, rolesCount: ${roles.length}, directPermissionsCount: ${directPermissions.length})';
  }
}

/// Helper class for permission checks
class PermissionCheck extends Equatable {
  const PermissionCheck({
    required this.resource,
    required this.action,
  });

  final String resource;
  final String action;

  @override
  List<Object?> get props => [resource, action];

  @override
  String toString() {
    return 'PermissionCheck(resource: $resource, action: $action)';
  }
}
