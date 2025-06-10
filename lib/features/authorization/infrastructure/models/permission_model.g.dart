// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PermissionModelImpl _$$PermissionModelImplFromJson(
  Map<String, dynamic> json,
) => _$PermissionModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  resource: json['resource'] as String,
  action: json['action'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$$PermissionModelImplToJson(
  _$PermissionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'resource': instance.resource,
  'action': instance.action,
  'description': instance.description,
};
