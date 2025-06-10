import 'package:equatable/equatable.dart';

import '../domain/entities/permission.dart';
import '../domain/entities/role.dart';
import '../../authentication/domain/entities/user.dart';

/// Authorization states
abstract class AuthorizationState extends Equatable {
  const AuthorizationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthorizationInitial extends AuthorizationState {
  const AuthorizationInitial();
}

/// Loading state
class AuthorizationLoading extends AuthorizationState {
  const AuthorizationLoading();
}

/// State when authorization data is loaded
class AuthorizationLoaded extends AuthorizationState {
  const AuthorizationLoaded({
    required this.user,
    required this.role,
    required this.permissions,
  });

  final User user;
  final Role role;
  final List<Permission> permissions;

  @override
  List<Object?> get props => [user, role, permissions];

  /// Check if user has specific permission
  bool hasPermission(String resource, String action) {
    return role.hasPermission(resource, action);
  }

  /// Check if user has resource access
  bool hasResourceAccess(String resource) {
    return role.hasResourceAccess(resource);
  }

  /// Get permissions for specific resource
  List<Permission> getResourcePermissions(String resource) {
    return role.getResourcePermissions(resource);
  }

  /// Check if user is admin
  bool get isAdmin => hasPermission('system', 'admin');

  /// Check if user is manager
  bool get isManager => hasPermission('system', 'manage');

  /// Check if user has elevated access
  bool get hasElevatedAccess => isAdmin || isManager;
}

/// State when permission check is completed
class AuthorizationPermissionChecked extends AuthorizationState {
  const AuthorizationPermissionChecked({
    required this.resource,
    required this.action,
    required this.hasPermission,
  });

  final String resource;
  final String action;
  final bool hasPermission;

  @override
  List<Object?> get props => [resource, action, hasPermission];
}

/// State when all roles are loaded (admin functionality)
class AuthorizationRolesLoaded extends AuthorizationState {
  const AuthorizationRolesLoaded({required this.roles});

  final List<Role> roles;

  @override
  List<Object?> get props => [roles];
}

/// State when all permissions are loaded (admin functionality)
class AuthorizationPermissionsLoaded extends AuthorizationState {
  const AuthorizationPermissionsLoaded({required this.permissions});

  final List<Permission> permissions;

  @override
  List<Object?> get props => [permissions];
}

/// State when authorization operation fails
class AuthorizationFailure extends AuthorizationState {
  const AuthorizationFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// State when user has no role or inactive role
class AuthorizationUnauthorized extends AuthorizationState {
  const AuthorizationUnauthorized({required this.reason});

  final String reason;

  @override
  List<Object?> get props => [reason];
}
