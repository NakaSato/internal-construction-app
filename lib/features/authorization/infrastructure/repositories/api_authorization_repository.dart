import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/role.dart';
import '../../domain/entities/permission.dart';
import '../../domain/repositories/authorization_repository.dart';
import '../models/authorization_response_model.dart';
import '../models/role_model.dart';
import '../models/permission_model.dart';

/// API implementation of authorization repository
class ApiAuthorizationRepository implements AuthorizationRepository {
  const ApiAuthorizationRepository({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  }) : _dio = dio,
       _secureStorage = secureStorage;

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static const String _roleCachePrefix = 'cached_role_';
  static const String _permissionsCachePrefix = 'cached_permissions_';

  @override
  Future<Role?> getRoleByName(String roleName) async {
    try {
      // Try to get from cache first
      final cachedRole = await getCachedRole(roleName);
      if (cachedRole != null) return cachedRole;

      // Fetch from API - ensure lowercase role name for API consistency
      final normalizedRoleName = roleName.toLowerCase();
      final response = await _dio.get('/api/roles/$normalizedRoleName');

      if (response.statusCode == 200) {
        final roleResponse = RoleApiResponse.fromJson(response.data);

        if (roleResponse.success && roleResponse.data != null) {
          final role = roleResponse.data!.toEntity();
          await cacheRoleData(role);
          return role;
        }
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to fetch role: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch role: $e');
    }
  }

  @override
  Future<List<Role>> getAllRoles() async {
    try {
      final response = await _dio.get('/api/roles');

      if (response.statusCode == 200) {
        final rolesResponse = RolesListApiResponse.fromJson(response.data);

        if (rolesResponse.success) {
          return rolesResponse.data.map((model) => model.toEntity()).toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch roles: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch roles: $e');
    }
  }

  @override
  Future<List<Permission>> getPermissionsForRole(String roleId) async {
    try {
      final response = await _dio.get('/api/roles/$roleId/permissions');

      if (response.statusCode == 200) {
        final permissionsResponse = PermissionsListApiResponse.fromJson(
          response.data,
        );

        if (permissionsResponse.success) {
          return permissionsResponse.data
              .map((model) => model.toEntity())
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch role permissions: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch role permissions: $e');
    }
  }

  @override
  Future<bool> hasRolePermission(
    String roleName,
    String resource,
    String action,
  ) async {
    try {
      final response = await _dio.post(
        '/api/authorization/check',
        data: {'roleName': roleName, 'resource': resource, 'action': action},
      );

      if (response.statusCode == 200) {
        final checkResponse = PermissionCheckResponse.fromJson(response.data);
        return checkResponse.success && checkResponse.hasPermission;
      }

      return false;
    } on DioException catch (e) {
      // If API is not available, check locally
      final role = await getRoleByName(roleName);
      return role?.hasPermission(resource, action) ?? false;
    } catch (e) {
      // Fallback to local check
      final role = await getRoleByName(roleName);
      return role?.hasPermission(resource, action) ?? false;
    }
  }

  @override
  Future<List<Permission>> getAllPermissions() async {
    try {
      final response = await _dio.get('/api/permissions');

      if (response.statusCode == 200) {
        final permissionsResponse = PermissionsListApiResponse.fromJson(
          response.data,
        );

        if (permissionsResponse.success) {
          return permissionsResponse.data
              .map((model) => model.toEntity())
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw Exception('Failed to fetch permissions: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch permissions: $e');
    }
  }

  @override
  Future<void> cacheRoleData(Role role) async {
    try {
      final normalizedRoleName = role.name.toLowerCase();
      final cacheKey = '$_roleCachePrefix$normalizedRoleName';
      final roleJson = RoleModel.fromEntity(role).toJson();
      await _secureStorage.write(key: cacheKey, value: roleJson.toString());
    } catch (e) {
      // Cache failure shouldn't break the app
      // Silently handle cache errors
    }
  }

  @override
  Future<Role?> getCachedRole(String roleName) async {
    try {
      final normalizedRoleName = roleName.toLowerCase();
      final cacheKey = '$_roleCachePrefix$normalizedRoleName';
      final cachedData = await _secureStorage.read(key: cacheKey);

      if (cachedData != null) {
        final roleModel = RoleModel.fromJson(
          cachedData as Map<String, dynamic>,
        );
        return roleModel.toEntity();
      }

      return null;
    } catch (e) {
      // Cache read failure shouldn't break the app
      return null;
    }
  }

  @override
  Future<void> clearRoleCache() async {
    try {
      final allKeys = await _secureStorage.readAll();
      final roleCacheKeys = allKeys.keys
          .where((key) => key.startsWith(_roleCachePrefix))
          .toList();

      for (final key in roleCacheKeys) {
        await _secureStorage.delete(key: key);
      }
    } catch (e) {
      // Cache clear failure shouldn't break the app
      // Silently handle cache errors
    }
  }
}
