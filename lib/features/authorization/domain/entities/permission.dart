import 'package:equatable/equatable.dart';

/// Permission entity representing specific access rights
class Permission extends Equatable {
  const Permission({
    required this.id,
    required this.name,
    required this.resource,
    required this.action,
    this.description,
  });

  final String id;
  final String name;
  final String resource;
  final String action;
  final String? description;

  @override
  List<Object?> get props => [id, name, resource, action, description];

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'resource': resource,
      'action': action,
      'description': description,
    };
  }

  /// Create from JSON
  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'] as String,
      name: json['name'] as String,
      resource: json['resource'] as String,
      action: json['action'] as String,
      description: json['description'] as String?,
    );
  }

  @override
  String toString() =>
      'Permission(name: $name, resource: $resource, action: $action)';
}
