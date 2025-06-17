import 'package:dartz/dartz.dart';
import '../../../error/failures.dart';
import '../../domain/entities/permission.dart';
import '../../domain/repositories/permission_repository.dart';

/// Mock implementation of permission repository for development and testing
class MockPermissionRepository implements PermissionRepository {
  MockPermissionRepository() {
    _initializeMockData();
  }

  // Mock data storage
  final Map<String, UserPermissionContext> _userPermissions = {};
  final Map<String, Permission> _permissions = {};
  final Map<String, Role> _roles = {};
  final Map<String, UserPermissionContext> _cachedPermissions = {};

  void _initializeMockData() {
    // Initialize mock permissions
    _permissions.addAll({
      'projects_view': const Permission(
        id: 'projects_view',
        name: 'View Projects',
        resource: 'projects',
        action: 'view',
        description: 'Can view project lists and details',
      ),
      'projects_create': const Permission(
        id: 'projects_create',
        name: 'Create Projects',
        resource: 'projects',
        action: 'create',
        description: 'Can create new projects',
      ),
      'projects_update': const Permission(
        id: 'projects_update',
        name: 'Update Projects',
        resource: 'projects',
        action: 'update',
        description: 'Can edit existing projects',
      ),
      'projects_delete': const Permission(
        id: 'projects_delete',
        name: 'Delete Projects',
        resource: 'projects',
        action: 'delete',
        description: 'Can delete projects',
      ),
      'projects_manage': const Permission(
        id: 'projects_manage',
        name: 'Manage Projects',
        resource: 'projects',
        action: 'manage',
        description: 'Full project management access',
      ),
      'daily_reports_view': const Permission(
        id: 'daily_reports_view',
        name: 'View Daily Reports',
        resource: 'daily_reports',
        action: 'view',
        description: 'Can view daily reports',
      ),
      'daily_reports_create': const Permission(
        id: 'daily_reports_create',
        name: 'Create Daily Reports',
        resource: 'daily_reports',
        action: 'create',
        description: 'Can create daily reports',
      ),
      'daily_reports_update': const Permission(
        id: 'daily_reports_update',
        name: 'Update Daily Reports',
        resource: 'daily_reports',
        action: 'update',
        description: 'Can edit daily reports',
      ),
      'daily_reports_delete': const Permission(
        id: 'daily_reports_delete',
        name: 'Delete Daily Reports',
        resource: 'daily_reports',
        action: 'delete',
        description: 'Can delete daily reports',
      ),
      'work_calendar_view': const Permission(
        id: 'work_calendar_view',
        name: 'View Work Calendar',
        resource: 'work_calendar',
        action: 'view',
        description: 'Can view work calendar',
      ),
      'work_calendar_create': const Permission(
        id: 'work_calendar_create',
        name: 'Create Work Events',
        resource: 'work_calendar',
        action: 'create',
        description: 'Can create work calendar events',
      ),
      'work_calendar_update': const Permission(
        id: 'work_calendar_update',
        name: 'Update Work Events',
        resource: 'work_calendar',
        action: 'update',
        description: 'Can edit work calendar events',
      ),
      'work_calendar_delete': const Permission(
        id: 'work_calendar_delete',
        name: 'Delete Work Events',
        resource: 'work_calendar',
        action: 'delete',
        description: 'Can delete work calendar events',
      ),
      'users_view': const Permission(
        id: 'users_view',
        name: 'View Users',
        resource: 'users',
        action: 'view',
        description: 'Can view user information',
      ),
      'users_manage': const Permission(
        id: 'users_manage',
        name: 'Manage Users',
        resource: 'users',
        action: 'manage',
        description: 'Full user management access',
      ),
      'work_requests_view': const Permission(
        id: 'work_requests_view',
        name: 'View Work Requests',
        resource: 'work_requests',
        action: 'view',
        description: 'Can view work requests',
      ),
      'work_requests_create': const Permission(
        id: 'work_requests_create',
        name: 'Create Work Requests',
        resource: 'work_requests',
        action: 'create',
        description: 'Can create work requests',
      ),
      'work_requests_approve': const Permission(
        id: 'work_requests_approve',
        name: 'Approve Work Requests',
        resource: 'work_requests',
        action: 'approve',
        description: 'Can approve work requests',
      ),
      'work_requests_reject': const Permission(
        id: 'work_requests_reject',
        name: 'Reject Work Requests',
        resource: 'work_requests',
        action: 'reject',
        description: 'Can reject work requests',
      ),
    });

    // Initialize mock roles
    _roles.addAll({
      'admin': Role(
        id: 'admin',
        name: 'Administrator',
        description: 'Full system access',
        permissions: _permissions.values.toList(),
      ),
      'manager': Role(
        id: 'manager',
        name: 'Project Manager',
        description: 'Project management access',
        permissions: [
          _permissions['projects_view']!,
          _permissions['projects_create']!,
          _permissions['projects_update']!,
          _permissions['projects_manage']!,
          _permissions['daily_reports_view']!,
          _permissions['daily_reports_create']!,
          _permissions['daily_reports_update']!,
          _permissions['work_calendar_view']!,
          _permissions['work_calendar_create']!,
          _permissions['work_calendar_update']!,
          _permissions['work_requests_view']!,
          _permissions['work_requests_approve']!,
          _permissions['work_requests_reject']!,
          _permissions['users_view']!,
        ],
      ),
      'user': Role(
        id: 'user',
        name: 'Field User',
        description: 'Basic field operations access',
        permissions: [
          _permissions['projects_view']!,
          _permissions['daily_reports_view']!,
          _permissions['daily_reports_create']!,
          _permissions['work_calendar_view']!,
          _permissions['work_requests_view']!,
          _permissions['work_requests_create']!,
        ],
      ),
    });

    // Initialize user permissions based on existing user roles
    _userPermissions.addAll({
      'admin_user_id': UserPermissionContext(
        userId: 'admin_user_id',
        roles: [_roles['admin']!],
        directPermissions: [],
      ),
      'manager_user_id': UserPermissionContext(
        userId: 'manager_user_id',
        roles: [_roles['manager']!],
        directPermissions: [],
      ),
      'field_user_id': UserPermissionContext(
        userId: 'field_user_id',
        roles: [_roles['user']!],
        directPermissions: [],
      ),
    });
  }

  @override
  Future<Either<Failure, UserPermissionContext>> getUserPermissions(String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
      
      final permissions = _userPermissions[userId];
      if (permissions == null) {
        return Left(NotFoundFailure('User permissions not found for user: $userId'));
      }
      
      return Right(permissions);
    } catch (e) {
      return Left(UnknownFailure('Error getting user permissions: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Permission>>> getAllPermissions() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return Right(_permissions.values.toList());
    } catch (e) {
      return Left(UnknownFailure('Error getting all permissions: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Role>>> getAllRoles() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      return Right(_roles.values.toList());
    } catch (e) {
      return Left(UnknownFailure('Error getting all roles: $e'));
    }
  }

  @override
  Future<Either<Failure, Role>> getRoleById(String roleId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final role = _roles[roleId];
      if (role == null) {
        return Left(NotFoundFailure('Role not found: $roleId'));
      }
      
      return Right(role);
    } catch (e) {
      return Left(UnknownFailure('Error getting role: $e'));
    }
  }

  @override
  Future<Either<Failure, Permission>> getPermissionById(String permissionId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final permission = _permissions[permissionId];
      if (permission == null) {
        return Left(NotFoundFailure('Permission not found: $permissionId'));
      }
      
      return Right(permission);
    } catch (e) {
      return Left(UnknownFailure('Error getting permission: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkUserPermission(
    String userId,
    String resource,
    String action,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final userPermissions = _userPermissions[userId];
      if (userPermissions == null) {
        return Left(NotFoundFailure('User permissions not found for user: $userId'));
      }
      
      final hasPermission = userPermissions.hasPermission(resource, action);
      return Right(hasPermission);
    } catch (e) {
      return Left(UnknownFailure('Error checking user permission: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Permission>>> getPermissionsForResource(String resource) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      
      final permissions = _permissions.values
          .where((permission) => permission.resource == resource)
          .toList();
      
      return Right(permissions);
    } catch (e) {
      return Left(UnknownFailure('Error getting permissions for resource: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserRoles(String userId, List<String> roleIds) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final roles = roleIds
          .map((roleId) => _roles[roleId])
          .where((role) => role != null)
          .cast<Role>()
          .toList();
      
      if (roles.length != roleIds.length) {
        return Left(ValidationFailure('Some roles not found'));
      }
      
      final existingPermissions = _userPermissions[userId];
      if (existingPermissions == null) {
        return Left(NotFoundFailure('User not found: $userId'));
      }
      
      _userPermissions[userId] = existingPermissions.copyWith(roles: roles);
      
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error updating user roles: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addDirectPermissionToUser(
    String userId,
    String permissionId,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final permission = _permissions[permissionId];
      if (permission == null) {
        return Left(NotFoundFailure('Permission not found: $permissionId'));
      }
      
      final existingPermissions = _userPermissions[userId];
      if (existingPermissions == null) {
        return Left(NotFoundFailure('User not found: $userId'));
      }
      
      final directPermissions = List<Permission>.from(existingPermissions.directPermissions);
      if (!directPermissions.contains(permission)) {
        directPermissions.add(permission);
        _userPermissions[userId] = existingPermissions.copyWith(directPermissions: directPermissions);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error adding direct permission: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeDirectPermissionFromUser(
    String userId,
    String permissionId,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final existingPermissions = _userPermissions[userId];
      if (existingPermissions == null) {
        return Left(NotFoundFailure('User not found: $userId'));
      }
      
      final directPermissions = existingPermissions.directPermissions
          .where((permission) => permission.id != permissionId)
          .toList();
      
      _userPermissions[userId] = existingPermissions.copyWith(directPermissions: directPermissions);
      
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error removing direct permission: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheUserPermissions(UserPermissionContext context) async {
    try {
      _cachedPermissions[context.userId] = context;
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error caching user permissions: $e'));
    }
  }

  @override
  Future<Either<Failure, UserPermissionContext?>> getCachedUserPermissions(String userId) async {
    try {
      return Right(_cachedPermissions[userId]);
    } catch (e) {
      return Left(UnknownFailure('Error getting cached user permissions: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCachedPermissions(String userId) async {
    try {
      _cachedPermissions.remove(userId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Error clearing cached permissions: $e'));
    }
  }
}
