import '../services/authorization_service.dart';
import '../../../authentication/domain/entities/user.dart';

/// Guard for protecting routes and features based on user permissions
class AuthorizationGuard {
  const AuthorizationGuard(this._authorizationService);

  final AuthorizationService _authorizationService;

  /// Check if user can access a route/feature
  Future<bool> canAccess(
    User user,
    String resource, [
    String action = 'view',
  ]) async {
    if (!user.isActive) return false;
    return await _authorizationService.hasPermission(user, resource, action);
  }

  /// Check if user can access multiple routes/features
  Future<Map<String, bool>> canAccessMultiple(
    User user,
    Map<String, String> resourceActions,
  ) async {
    final results = <String, bool>{};

    for (final entry in resourceActions.entries) {
      final resource = entry.key;
      final action = entry.value;
      results[resource] = await canAccess(user, resource, action);
    }

    return results;
  }

  /// Check if user can perform any of the specified actions on resources
  Future<bool> canAccessAny(
    User user,
    List<ResourceAction> resourceActions,
  ) async {
    if (!user.isActive) return false;

    for (final resourceAction in resourceActions) {
      final canAccess = await _authorizationService.hasPermission(
        user,
        resourceAction.resource,
        resourceAction.action,
      );
      if (canAccess) return true;
    }

    return false;
  }

  /// Check if user can perform all specified actions on resources
  Future<bool> canAccessAll(
    User user,
    List<ResourceAction> resourceActions,
  ) async {
    if (!user.isActive) return false;

    for (final resourceAction in resourceActions) {
      final canAccess = await _authorizationService.hasPermission(
        user,
        resourceAction.resource,
        resourceAction.action,
      );
      if (!canAccess) return false;
    }

    return true;
  }

  /// Check if user has admin-level access
  Future<bool> isAdmin(User user) async {
    return await canAccess(user, 'system', 'admin');
  }

  /// Check if user has manager-level access
  Future<bool> isManager(User user) async {
    return await canAccess(user, 'system', 'manage');
  }

  /// Get allowed actions for a resource
  Future<List<String>> getAllowedActions(User user, String resource) async {
    final permissions = await _authorizationService.getUserResourcePermissions(
      user,
      resource,
    );
    return permissions.map((p) => p.action).toList();
  }

  /// Filter resources by user access
  Future<List<String>> filterAccessibleResources(
    User user,
    List<String> resources, [
    String action = 'view',
  ]) async {
    final accessibleResources = <String>[];

    for (final resource in resources) {
      if (await canAccess(user, resource, action)) {
        accessibleResources.add(resource);
      }
    }

    return accessibleResources;
  }

  /// Check if user has elevated permissions (admin or manager)
  Future<bool> hasElevatedAccess(User user) async {
    return await isAdmin(user) || await isManager(user);
  }
}

/// Helper class for resource-action pairs
class ResourceAction {
  const ResourceAction({required this.resource, required this.action});

  final String resource;
  final String action;

  @override
  String toString() => '$resource:$action';
}
