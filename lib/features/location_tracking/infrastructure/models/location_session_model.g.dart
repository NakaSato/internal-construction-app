// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationSessionModelImpl _$$LocationSessionModelImplFromJson(
  Map<String, dynamic> json,
) => _$LocationSessionModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
  locations:
      (json['locations'] as List<dynamic>?)
          ?.map((e) => LocationDataModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isActive: json['isActive'] as bool? ?? false,
  description: json['description'] as String?,
);

Map<String, dynamic> _$$LocationSessionModelImplToJson(
  _$LocationSessionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'locations': instance.locations,
  'isActive': instance.isActive,
  'description': instance.description,
};
