import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/guards/authorization_guard.dart';
import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';
import '../../../authentication/domain/entities/user.dart';

/// Middleware for route-level authorization
class AuthorizationMiddleware {
  const AuthorizationMiddleware({required this.authorizationGuard});

  final AuthorizationGuard authorizationGuard;

  /// Route guard for navigation protection
  Future<bool> canNavigate(
    BuildContext context, {
    required String route,
    String? requiredPermission,
    String? requiredRole,
    String? resource,
    String? action,
  }) async {
    try {
      // Get current user from authentication bloc
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        return false;
      }

      final user = authState.user;

      // Check resource and action if specified
      if (resource != null && action != null) {
        return await authorizationGuard.canAccess(user, resource, action);
      }

      // Check specific permission (convert to resource:action format)
      if (requiredPermission != null) {
        final parts = requiredPermission.split(':');
        if (parts.length == 2) {
          return await authorizationGuard.canAccess(user, parts[0], parts[1]);
        }
      }

      // Check role-based access
      if (requiredRole != null) {
        return user.roleName == requiredRole ||
            await _checkRoleHierarchy(user, requiredRole);
      }

      // Default to true if no restrictions specified
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Authorization middleware error for route $route: $e');
      }
      return false;
    }
  }

  /// Check if user's role has sufficient authority for required role
  Future<bool> _checkRoleHierarchy(User user, String requiredRole) async {
    const hierarchy = ['guest', 'employee', 'manager', 'admin'];
    final userRoleIndex = hierarchy.indexOf(user.roleName);
    final requiredRoleIndex = hierarchy.indexOf(requiredRole);

    if (userRoleIndex == -1 || requiredRoleIndex == -1) return false;
    return userRoleIndex >= requiredRoleIndex;
  }

  /// Widget wrapper for conditional route content
  Widget protectedRoute({
    required BuildContext context,
    required Widget child,
    required String route,
    String? requiredPermission,
    String? requiredRole,
    String? resource,
    String? action,
    Widget? fallback,
  }) {
    return FutureBuilder<bool>(
      future: canNavigate(
        context,
        route: route,
        requiredPermission: requiredPermission,
        requiredRole: requiredRole,
        resource: resource,
        action: action,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final hasAccess = snapshot.data ?? false;
        if (hasAccess) {
          return child;
        }

        return fallback ??
            const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Access Denied',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You do not have permission to access this page.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
      },
    );
  }
}

/// Route protection configuration
class RouteProtection {
  const RouteProtection({
    this.requiredPermission,
    this.requiredRole,
    this.resource,
    this.action,
    this.fallbackRoute,
  });

  final String? requiredPermission;
  final String? requiredRole;
  final String? resource;
  final String? action;
  final String? fallbackRoute;
}

/// Route configuration with authorization
class AuthorizedRoute {
  const AuthorizedRoute({
    required this.path,
    required this.builder,
    this.protection,
    this.name,
  });

  final String path;
  final String? name;
  final Widget Function(BuildContext context) builder;
  final RouteProtection? protection;
}

/// Authorization-aware navigation utilities
class AuthorizedNavigation {
  static final Map<String, RouteProtection> _routeProtections = {};

  /// Register route protection
  static void registerProtection(String route, RouteProtection protection) {
    _routeProtections[route] = protection;
  }

  /// Get protection for route
  static RouteProtection? getProtection(String route) {
    return _routeProtections[route];
  }

  /// Navigate with authorization check
  static Future<bool> navigateToProtected(
    BuildContext context,
    String route, {
    AuthorizationMiddleware? middleware,
    Object? arguments,
  }) async {
    final protection = getProtection(route);
    if (protection == null || middleware == null) {
      Navigator.of(context).pushNamed(route, arguments: arguments);
      return true;
    }

    final canNavigate = await middleware.canNavigate(
      context,
      route: route,
      requiredPermission: protection.requiredPermission,
      requiredRole: protection.requiredRole,
      resource: protection.resource,
      action: protection.action,
    );

    if (canNavigate) {
      Navigator.of(context).pushNamed(route, arguments: arguments);
      return true;
    } else {
      // Navigate to fallback route or show error
      if (protection.fallbackRoute != null) {
        Navigator.of(context).pushReplacementNamed(protection.fallbackRoute!);
      } else {
        _showAccessDeniedDialog(context);
      }
      return false;
    }
  }

  static void _showAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Access Denied'),
        content: const Text('You do not have permission to access this page.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
