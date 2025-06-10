import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/role.dart';
import 'permission_model.dart';

part 'role_model.freezed.dart';
part 'role_model.g.dart';

/// Data model for Role entity
@freezed
class RoleModel with _$RoleModel {
  const factory RoleModel({
    required String id,
    required String name,
    required List<PermissionModel> permissions,
    String? description,
    @Default(true) bool isActive,
  }) = _RoleModel;

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);

  /// Create model from domain entity
  factory RoleModel.fromEntity(Role entity) {
    return RoleModel(
      id: entity.id,
      name: entity.name,
      permissions: entity.permissions
          .map((permission) => PermissionModel.fromEntity(permission))
          .toList(),
      description: entity.description,
      isActive: entity.isActive,
    );
  }
}

/// Extension to convert between model and entity
extension RoleModelX on RoleModel {
  /// Convert model to domain entity
  Role toEntity() {
    return Role(
      id: id,
      name: name,
      permissions: permissions
          .map((permission) => permission.toEntity())
          .toList(),
      description: description,
      isActive: isActive,
    );
  }
}

/// Extension to convert from entity to model
extension RoleX on Role {
  /// Convert domain entity to model
  RoleModel toModel() {
    return RoleModel.fromEntity(this);
  }
}
