import 'package:equatable/equatable.dart';

import '../../authentication/domain/entities/user.dart';

/// Authorization events
abstract class AuthorizationEvent extends Equatable {
  const AuthorizationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user role and permissions
class AuthorizationLoadRequested extends AuthorizationEvent {
  const AuthorizationLoadRequested({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

/// Event to check specific permission
class AuthorizationPermissionCheckRequested extends AuthorizationEvent {
  const AuthorizationPermissionCheckRequested({
    required this.user,
    required this.resource,
    required this.action,
  });

  final User user;
  final String resource;
  final String action;

  @override
  List<Object?> get props => [user, resource, action];
}

/// Event to refresh authorization data
class AuthorizationRefreshRequested extends AuthorizationEvent {
  const AuthorizationRefreshRequested({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

/// Event to clear authorization data
class AuthorizationClearRequested extends AuthorizationEvent {
  const AuthorizationClearRequested();
}

/// Event to load all roles (admin functionality)
class AuthorizationRolesLoadRequested extends AuthorizationEvent {
  const AuthorizationRolesLoadRequested();
}

/// Event to load all permissions (admin functionality)
class AuthorizationPermissionsLoadRequested extends AuthorizationEvent {
  const AuthorizationPermissionsLoadRequested();
}
