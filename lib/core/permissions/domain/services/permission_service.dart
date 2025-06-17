import 'package:dartz/dartz.dart';
import '../../../error/failures.dart';
import '../entities/permission.dart';
import '../usecases/check_user_permission.dart';
import '../usecases/get_user_permissions.dart';
import '../usecases/check_multiple_permissions.dart';

/// Service class for convenient permission checking
class PermissionService {
  PermissionService({
    required this.checkUserPermissionUseCase,
    required this.getUserPermissionsUseCase,
    required this.checkMultiplePermissionsUseCase,
  });

  final CheckUserPermissionUseCase checkUserPermissionUseCase;
  final GetUserPermissionsUseCase getUserPermissionsUseCase;
  final CheckMultiplePermissionsUseCase checkMultiplePermissionsUseCase;

  /// Check if user has permission for a specific resource and action
  Future<bool> hasPermission(String userId, String resource, String action) async {
    final result = await checkUserPermissionUseCase(
      CheckUserPermissionParams(
        userId: userId,
        resource: resource,
        action: action,
      ),
    );
    return result.fold((_) => false, (hasPermission) => hasPermission);
  }

  /// Check if user can view a resource
  Future<bool> canView(String userId, String resource) async {
    return hasPermission(userId, resource, 'view');
  }

  /// Check if user can create a resource
  Future<bool> canCreate(String userId, String resource) async {
    return hasPermission(userId, resource, 'create');
  }

  /// Check if user can update a resource
  Future<bool> canUpdate(String userId, String resource) async {
    return hasPermission(userId, resource, 'update');
  }

  /// Check if user can delete a resource
  Future<bool> canDelete(String userId, String resource) async {
    return hasPermission(userId, resource, 'delete');
  }

  /// Check if user can manage (full access) a resource
  Future<bool> canManage(String userId, String resource) async {
    return hasPermission(userId, resource, 'manage');
  }

  /// Get user's complete permission context
  Future<Either<Failure, UserPermissionContext>> getUserPermissions(
    String userId, {
    bool useCache = true,
    bool cacheResult = true,
  }) async {
    return await getUserPermissionsUseCase(
      GetUserPermissionsParams(
        userId: userId,
        useCache: useCache,
        cacheResult: cacheResult,
      ),
    );
  }

  /// Check multiple permissions at once
  Future<Map<String, bool>> checkMultiplePermissions(
    String userId,
    List<PermissionCheck> checks,
  ) async {
    final result = await checkMultiplePermissionsUseCase(
      CheckMultiplePermissionsParams(
        userId: userId,
        permissionChecks: checks,
      ),
    );
    return result.fold((_) => {}, (permissions) => permissions);
  }

  /// Check if user has any of the specified permissions
  Future<bool> hasAnyPermission(String userId, List<PermissionCheck> checks) async {
    final results = await checkMultiplePermissions(userId, checks);
    return results.values.any((hasPermission) => hasPermission);
  }

  /// Check if user has all of the specified permissions
  Future<bool> hasAllPermissions(String userId, List<PermissionCheck> checks) async {
    final results = await checkMultiplePermissions(userId, checks);
    return checks.every((check) {
      final key = '${check.resource}:${check.action}';
      return results[key] == true;
    });
  }

  /// Project-specific permission checks
  Future<bool> canViewProjects(String userId) => canView(userId, 'projects');
  Future<bool> canCreateProjects(String userId) => canCreate(userId, 'projects');
  Future<bool> canUpdateProjects(String userId) => canUpdate(userId, 'projects');
  Future<bool> canDeleteProjects(String userId) => canDelete(userId, 'projects');
  Future<bool> canManageProjects(String userId) => canManage(userId, 'projects');

  /// Daily reports permission checks
  Future<bool> canViewDailyReports(String userId) => canView(userId, 'daily_reports');
  Future<bool> canCreateDailyReports(String userId) => canCreate(userId, 'daily_reports');
  Future<bool> canUpdateDailyReports(String userId) => canUpdate(userId, 'daily_reports');
  Future<bool> canDeleteDailyReports(String userId) => canDelete(userId, 'daily_reports');

  /// Work calendar permission checks
  Future<bool> canViewWorkCalendar(String userId) => canView(userId, 'work_calendar');
  Future<bool> canCreateWorkEvents(String userId) => canCreate(userId, 'work_calendar');
  Future<bool> canUpdateWorkEvents(String userId) => canUpdate(userId, 'work_calendar');
  Future<bool> canDeleteWorkEvents(String userId) => canDelete(userId, 'work_calendar');

  /// User management permission checks
  Future<bool> canViewUsers(String userId) => canView(userId, 'users');
  Future<bool> canCreateUsers(String userId) => canCreate(userId, 'users');
  Future<bool> canUpdateUsers(String userId) => canUpdate(userId, 'users');
  Future<bool> canDeleteUsers(String userId) => canDelete(userId, 'users');
  Future<bool> canManageUsers(String userId) => canManage(userId, 'users');

  /// Task management permission checks
  Future<bool> canViewTasks(String userId) => canView(userId, 'tasks');
  Future<bool> canCreateTasks(String userId) => canCreate(userId, 'tasks');
  Future<bool> canUpdateTasks(String userId) => canUpdate(userId, 'tasks');
  Future<bool> canDeleteTasks(String userId) => canDelete(userId, 'tasks');

  /// Work request approval permission checks
  Future<bool> canViewWorkRequests(String userId) => canView(userId, 'work_requests');
  Future<bool> canCreateWorkRequests(String userId) => canCreate(userId, 'work_requests');
  Future<bool> canApproveWorkRequests(String userId) => hasPermission(userId, 'work_requests', 'approve');
  Future<bool> canRejectWorkRequests(String userId) => hasPermission(userId, 'work_requests', 'reject');
}
