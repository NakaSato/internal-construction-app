import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/authorization_bloc.dart';
import '../../application/authorization_event.dart';
import '../../application/authorization_state.dart';
import '../../../authentication/domain/entities/user.dart';

/// Widget that conditionally shows content based on user permissions
class PermissionBuilder extends StatelessWidget {
  const PermissionBuilder({
    super.key,
    required this.user,
    required this.resource,
    required this.action,
    required this.builder,
    this.fallback,
    this.loading,
  });

  final User user;
  final String resource;
  final String action;
  final Widget Function(BuildContext context, bool hasPermission) builder;
  final Widget? fallback;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthorizationBloc, AuthorizationState>(
      builder: (context, state) {
        if (state is AuthorizationLoading) {
          return loading ?? const CircularProgressIndicator();
        }

        if (state is AuthorizationLoaded) {
          final hasPermission = state.hasPermission(resource, action);
          return builder(context, hasPermission);
        }

        if (state is AuthorizationPermissionChecked &&
            state.resource == resource &&
            state.action == action) {
          return builder(context, state.hasPermission);
        }

        // If no authorization data, check permission explicitly
        context.read<AuthorizationBloc>().add(
          AuthorizationPermissionCheckRequested(
            user: user,
            resource: resource,
            action: action,
          ),
        );

        return loading ?? const CircularProgressIndicator();
      },
    );
  }
}

/// Widget that shows content only if user has required permission
class PermissionGate extends StatelessWidget {
  const PermissionGate({
    super.key,
    required this.user,
    required this.resource,
    required this.action,
    required this.child,
    this.fallback,
    this.loading,
  });

  final User user;
  final String resource;
  final String action;
  final Widget child;
  final Widget? fallback;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return PermissionBuilder(
      user: user,
      resource: resource,
      action: action,
      loading: loading,
      builder: (context, hasPermission) {
        if (hasPermission) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Widget that shows different content based on user role
class RoleBasedWidget extends StatelessWidget {
  const RoleBasedWidget({
    super.key,
    required this.user,
    this.adminWidget,
    this.managerWidget,
    this.userWidget,
    this.fallbackWidget,
    this.loading,
  });

  final User user;
  final Widget? adminWidget;
  final Widget? managerWidget;
  final Widget? userWidget;
  final Widget? fallbackWidget;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthorizationBloc, AuthorizationState>(
      builder: (context, state) {
        if (state is AuthorizationLoading) {
          return loading ?? const CircularProgressIndicator();
        }

        if (state is AuthorizationLoaded) {
          if (state.isAdmin && adminWidget != null) {
            return adminWidget!;
          }
          if (state.isManager && managerWidget != null) {
            return managerWidget!;
          }
          if (userWidget != null) {
            return userWidget!;
          }
          return fallbackWidget ?? const SizedBox.shrink();
        }

        // Load authorization data if not available
        context.read<AuthorizationBloc>().add(
          AuthorizationLoadRequested(user: user),
        );

        return loading ?? const CircularProgressIndicator();
      },
    );
  }
}

/// Widget that shows admin-only content
class AdminOnlyWidget extends StatelessWidget {
  const AdminOnlyWidget({
    super.key,
    required this.user,
    required this.child,
    this.fallback,
    this.loading,
  });

  final User user;
  final Widget child;
  final Widget? fallback;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return PermissionGate(
      user: user,
      resource: 'system',
      action: 'admin',
      loading: loading,
      fallback: fallback,
      child: child,
    );
  }
}

/// Widget that shows manager-level content
class ManagerOnlyWidget extends StatelessWidget {
  const ManagerOnlyWidget({
    super.key,
    required this.user,
    required this.child,
    this.fallback,
    this.loading,
  });

  final User user;
  final Widget child;
  final Widget? fallback;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return PermissionGate(
      user: user,
      resource: 'system',
      action: 'manage',
      loading: loading,
      fallback: fallback,
      child: child,
    );
  }
}

/// Widget that shows elevated access content (admin or manager)
class ElevatedAccessWidget extends StatelessWidget {
  const ElevatedAccessWidget({
    super.key,
    required this.user,
    required this.child,
    this.fallback,
    this.loading,
  });

  final User user;
  final Widget child;
  final Widget? fallback;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthorizationBloc, AuthorizationState>(
      builder: (context, state) {
        if (state is AuthorizationLoading) {
          return loading ?? const CircularProgressIndicator();
        }

        if (state is AuthorizationLoaded) {
          if (state.hasElevatedAccess) {
            return child;
          }
          return fallback ?? const SizedBox.shrink();
        }

        // Load authorization data if not available
        context.read<AuthorizationBloc>().add(
          AuthorizationLoadRequested(user: user),
        );

        return loading ?? const CircularProgressIndicator();
      },
    );
  }
}

/// Widget that conditionally enables/disables based on permissions
class ConditionalWidget extends StatelessWidget {
  const ConditionalWidget({
    super.key,
    required this.user,
    required this.resource,
    required this.action,
    required this.enabledChild,
    required this.disabledChild,
    this.loading,
  });

  final User user;
  final String resource;
  final String action;
  final Widget enabledChild;
  final Widget disabledChild;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    return PermissionBuilder(
      user: user,
      resource: resource,
      action: action,
      loading: loading,
      builder: (context, hasPermission) {
        return hasPermission ? enabledChild : disabledChild;
      },
    );
  }
}
