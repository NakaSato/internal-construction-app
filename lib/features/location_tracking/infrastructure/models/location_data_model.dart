import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/location_data.dart';

part 'location_data_model.freezed.dart';
part 'location_data_model.g.dart';

/// Data model for LocationData entity
@freezed
class LocationDataModel with _$LocationDataModel {
  const factory LocationDataModel({
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
  }) = _LocationDataModel;

  factory LocationDataModel.fromJson(Map<String, dynamic> json) =>
      _$LocationDataModelFromJson(json);

  /// Create model from domain entity
  factory LocationDataModel.fromEntity(LocationData entity) {
    return LocationDataModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      timestamp: entity.timestamp,
      accuracy: entity.accuracy,
      altitude: entity.altitude,
      speed: entity.speed,
      heading: entity.heading,
      address: entity.address,
    );
  }
}

/// Extension to convert between model and entity
extension LocationDataModelX on LocationDataModel {
  /// Convert model to domain entity
  LocationData toEntity() {
    return LocationData(
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      address: address,
    );
  }
}

/// Extension to convert from entity to model (for backward compatibility)
extension LocationDataX on LocationData {
  /// Convert domain entity to model
  LocationDataModel toModel() {
    return LocationDataModel.fromEntity(this);
  }
}
