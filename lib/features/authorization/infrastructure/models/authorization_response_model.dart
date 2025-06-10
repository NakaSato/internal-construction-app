import 'package:freezed_annotation/freezed_annotation.dart';

import 'role_model.dart';
import 'permission_model.dart';

part 'authorization_response_model.freezed.dart';
part 'authorization_response_model.g.dart';

/// Response model for role API calls
@freezed
class RoleApiResponse with _$RoleApiResponse {
  const factory RoleApiResponse({
    required bool success,
    required String message,
    RoleModel? data,
    @Default([]) List<String> errors,
  }) = _RoleApiResponse;

  factory RoleApiResponse.fromJson(Map<String, dynamic> json) =>
      _$RoleApiResponseFromJson(json);
}

/// Response model for roles list API calls
@freezed
class RolesListApiResponse with _$RolesListApiResponse {
  const factory RolesListApiResponse({
    required bool success,
    required String message,
    @Default([]) List<RoleModel> data,
    @Default([]) List<String> errors,
  }) = _RolesListApiResponse;

  factory RolesListApiResponse.fromJson(Map<String, dynamic> json) =>
      _$RolesListApiResponseFromJson(json);
}

/// Response model for permission API calls
@freezed
class PermissionApiResponse with _$PermissionApiResponse {
  const factory PermissionApiResponse({
    required bool success,
    required String message,
    PermissionModel? data,
    @Default([]) List<String> errors,
  }) = _PermissionApiResponse;

  factory PermissionApiResponse.fromJson(Map<String, dynamic> json) =>
      _$PermissionApiResponseFromJson(json);
}

/// Response model for permissions list API calls
@freezed
class PermissionsListApiResponse with _$PermissionsListApiResponse {
  const factory PermissionsListApiResponse({
    required bool success,
    required String message,
    @Default([]) List<PermissionModel> data,
    @Default([]) List<String> errors,
  }) = _PermissionsListApiResponse;

  factory PermissionsListApiResponse.fromJson(Map<String, dynamic> json) =>
      _$PermissionsListApiResponseFromJson(json);
}

/// Response model for permission check API calls
@freezed
class PermissionCheckResponse with _$PermissionCheckResponse {
  const factory PermissionCheckResponse({
    required bool success,
    required String message,
    @Default(false) bool hasPermission,
    @Default([]) List<String> errors,
  }) = _PermissionCheckResponse;

  factory PermissionCheckResponse.fromJson(Map<String, dynamic> json) =>
      _$PermissionCheckResponseFromJson(json);
}
