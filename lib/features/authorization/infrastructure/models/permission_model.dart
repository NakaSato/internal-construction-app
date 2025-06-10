import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/permission.dart';

part 'permission_model.freezed.dart';
part 'permission_model.g.dart';

/// Data model for Permission entity
@freezed
class PermissionModel with _$PermissionModel {
  const factory PermissionModel({
    required String id,
    required String name,
    required String resource,
    required String action,
    String? description,
  }) = _PermissionModel;

  factory PermissionModel.fromJson(Map<String, dynamic> json) =>
      _$PermissionModelFromJson(json);

  /// Create model from domain entity
  factory PermissionModel.fromEntity(Permission entity) {
    return PermissionModel(
      id: entity.id,
      name: entity.name,
      resource: entity.resource,
      action: entity.action,
      description: entity.description,
    );
  }
}

/// Extension to convert between model and entity
extension PermissionModelX on PermissionModel {
  /// Convert model to domain entity
  Permission toEntity() {
    return Permission(
      id: id,
      name: name,
      resource: resource,
      action: action,
      description: description,
    );
  }
}

/// Extension to convert from entity to model
extension PermissionX on Permission {
  /// Convert domain entity to model
  PermissionModel toModel() {
    return PermissionModel.fromEntity(this);
  }
}
