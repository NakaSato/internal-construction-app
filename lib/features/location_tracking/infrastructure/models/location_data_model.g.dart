// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationDataModelImpl _$$LocationDataModelImplFromJson(
  Map<String, dynamic> json,
) => _$LocationDataModelImpl(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  altitude: (json['altitude'] as num?)?.toDouble(),
  speed: (json['speed'] as num?)?.toDouble(),
  heading: (json['heading'] as num?)?.toDouble(),
  address: json['address'] as String?,
);

Map<String, dynamic> _$$LocationDataModelImplToJson(
  _$LocationDataModelImpl instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'timestamp': instance.timestamp.toIso8601String(),
  'accuracy': instance.accuracy,
  'altitude': instance.altitude,
  'speed': instance.speed,
  'heading': instance.heading,
  'address': instance.address,
};
