import 'package:equatable/equatable.dart';

import 'permission.dart';

/// Role entity representing a user role with associated permissions
class Role extends Equatable {
  const Role({
    required this.id,
    required this.name,
    required this.permissions,
    this.description,
    this.isActive = true,
  });

  final String id;
  final String name;
  final List<Permission> permissions;
  final String? description;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, permissions, description, isActive];

  /// Check if this role has a specific permission
  bool hasPermission(String resource, String action) {
    return permissions.any(
      (permission) =>
          permission.resource == resource && permission.action == action,
    );
  }

  /// Check if this role has any permission for a resource
  bool hasResourceAccess(String resource) {
    return permissions.any((permission) => permission.resource == resource);
  }

  /// Get all permissions for a specific resource
  List<Permission> getResourcePermissions(String resource) {
    return permissions
        .where((permission) => permission.resource == resource)
        .toList();
  }

  /// Create a copy of this role with optional parameter overrides
  Role copyWith({
    String? id,
    String? name,
    List<Permission>? permissions,
    String? description,
    bool? isActive,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'permissions': permissions.map((p) => p.toJson()).toList(),
      'description': description,
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as String,
      name: json['name'] as String,
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((p) => Permission.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  @override
  String toString() => 'Role(name: $name, permissions: ${permissions.length})';
}
