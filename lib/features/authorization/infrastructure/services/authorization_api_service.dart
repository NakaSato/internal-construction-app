import 'package:dio/dio.dart';

import '../models/authorization_response_model.dart';

abstract class AuthorizationApiService {
  Future<RolesListApiResponse> getRoles();
  Future<PermissionsListApiResponse> getPermissions();
  Future<RoleApiResponse> getUserRole(String userId);
  Future<PermissionCheckResponse> checkPermission(
    String userId,
    String permission,
  );
  Future<PermissionCheckResponse> checkResourcePermission(
    String userId,
    String resource,
    String action,
  );
  Future<RoleApiResponse> assignRole(String userId, String roleId);
  Future<RoleApiResponse> revokeRole(String userId, String roleId);
}

class DioAuthorizationApiService implements AuthorizationApiService {
  final Dio _dio;

  const DioAuthorizationApiService(this._dio);

  @override
  Future<RolesListApiResponse> getRoles() async {
    try {
      final response = await _dio.get('/auth/roles');
      return RolesListApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<PermissionsListApiResponse> getPermissions() async {
    try {
      final response = await _dio.get('/auth/permissions');
      return PermissionsListApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<RoleApiResponse> getUserRole(String userId) async {
    try {
      final response = await _dio.get('/auth/users/$userId/role');
      return RoleApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<PermissionCheckResponse> checkPermission(
    String userId,
    String permission,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/check-permission',
        data: {'userId': userId, 'permission': permission},
      );
      return PermissionCheckResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<PermissionCheckResponse> checkResourcePermission(
    String userId,
    String resource,
    String action,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/check-resource-permission',
        data: {'userId': userId, 'resource': resource, 'action': action},
      );
      return PermissionCheckResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<RoleApiResponse> assignRole(String userId, String roleId) async {
    try {
      final response = await _dio.post(
        '/auth/users/$userId/assign-role',
        data: {'roleId': roleId},
      );
      return RoleApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<RoleApiResponse> revokeRole(String userId, String roleId) async {
    try {
      final response = await _dio.post(
        '/auth/users/$userId/revoke-role',
        data: {'roleId': roleId},
      );
      return RoleApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Request timeout. Please check your connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message =
            e.response?.data?['message'] ?? 'Unknown error occurred';
        switch (statusCode) {
          case 401:
            return Exception('Unauthorized access');
          case 403:
            return Exception('Access forbidden');
          case 404:
            return Exception('Resource not found');
          case 422:
            return Exception('Validation error: $message');
          case 500:
            return Exception('Internal server error');
          default:
            return Exception('HTTP $statusCode: $message');
        }
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      case DioExceptionType.connectionError:
        return Exception(
          'Connection error. Please check your internet connection.',
        );
      default:
        return Exception('An unexpected error occurred: ${e.message}');
    }
  }
}
