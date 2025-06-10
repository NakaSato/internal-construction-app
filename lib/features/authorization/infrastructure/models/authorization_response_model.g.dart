// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authorization_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoleApiResponseImpl _$$RoleApiResponseImplFromJson(
  Map<String, dynamic> json,
) => _$RoleApiResponseImpl(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : RoleModel.fromJson(json['data'] as Map<String, dynamic>),
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$RoleApiResponseImplToJson(
  _$RoleApiResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
};

_$RolesListApiResponseImpl _$$RolesListApiResponseImplFromJson(
  Map<String, dynamic> json,
) => _$RolesListApiResponseImpl(
  success: json['success'] as bool,
  message: json['message'] as String,
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => RoleModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$RolesListApiResponseImplToJson(
  _$RolesListApiResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
};

_$PermissionApiResponseImpl _$$PermissionApiResponseImplFromJson(
  Map<String, dynamic> json,
) => _$PermissionApiResponseImpl(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : PermissionModel.fromJson(json['data'] as Map<String, dynamic>),
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$PermissionApiResponseImplToJson(
  _$PermissionApiResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
};

_$PermissionsListApiResponseImpl _$$PermissionsListApiResponseImplFromJson(
  Map<String, dynamic> json,
) => _$PermissionsListApiResponseImpl(
  success: json['success'] as bool,
  message: json['message'] as String,
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => PermissionModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$PermissionsListApiResponseImplToJson(
  _$PermissionsListApiResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
};

_$PermissionCheckResponseImpl _$$PermissionCheckResponseImplFromJson(
  Map<String, dynamic> json,
) => _$PermissionCheckResponseImpl(
  success: json['success'] as bool,
  message: json['message'] as String,
  hasPermission: json['hasPermission'] as bool? ?? false,
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$PermissionCheckResponseImplToJson(
  _$PermissionCheckResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'hasPermission': instance.hasPermission,
  'errors': instance.errors,
};
