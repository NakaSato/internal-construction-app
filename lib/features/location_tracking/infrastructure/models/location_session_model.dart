import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/location_session.dart';
import 'location_data_model.dart';

part 'location_session_model.freezed.dart';
part 'location_session_model.g.dart';

/// Data model for LocationSession entity
@freezed
class LocationSessionModel with _$LocationSessionModel {
  const factory LocationSessionModel({
    required String id,
    required String name,
    required DateTime startTime,
    DateTime? endTime,
    @Default([]) List<LocationDataModel> locations,
    @Default(false) bool isActive,
    String? description,
  }) = _LocationSessionModel;

  factory LocationSessionModel.fromJson(Map<String, dynamic> json) =>
      _$LocationSessionModelFromJson(json);

  /// Create model from domain entity
  factory LocationSessionModel.fromEntity(LocationSession entity) {
    return LocationSessionModel(
      id: entity.id,
      name: entity.name,
      startTime: entity.startTime,
      endTime: entity.endTime,
      locations: entity.locations.map(LocationDataModel.fromEntity).toList(),
      isActive: entity.isActive,
      description: entity.description,
    );
  }
}

/// Extension to convert between model and entity
extension LocationSessionModelX on LocationSessionModel {
  /// Convert model to domain entity
  LocationSession toEntity() {
    return LocationSession(
      id: id,
      name: name,
      startTime: startTime,
      endTime: endTime,
      locations: locations.map((model) => model.toEntity()).toList(),
      isActive: isActive,
      description: description,
    );
  }
}

/// Extension to convert from entity to model
extension LocationSessionX on LocationSession {
  /// Convert domain entity to model
  LocationSessionModel toModel() {
    return LocationSessionModel.fromEntity(this);
  }
}
