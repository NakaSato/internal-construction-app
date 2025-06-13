import 'package:equatable/equatable.dart';

/// Project entity representing a project in the system
class Project extends Equatable {
  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.priority = ProjectPriority.medium,
    this.completionPercentage = 0,
    this.assignedUserId,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String description;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final ProjectPriority priority;
  final int completionPercentage;
  final String? assignedUserId;
  final List<String> tags;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    status,
    createdAt,
    updatedAt,
    dueDate,
    priority,
    completionPercentage,
    assignedUserId,
    tags,
  ];

  Project copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    ProjectPriority? priority,
    int? completionPercentage,
    String? assignedUserId,
    List<String>? tags,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      tags: tags ?? this.tags,
    );
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) &&
        status != ProjectStatus.completed;
  }

  bool get isCompleted => status == ProjectStatus.completed;
}

/// Project status enumeration
enum ProjectStatus {
  planning,
  inProgress,
  onHold,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Project priority enumeration
enum ProjectPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case ProjectPriority.low:
        return 'Low';
      case ProjectPriority.medium:
        return 'Medium';
      case ProjectPriority.high:
        return 'High';
      case ProjectPriority.urgent:
        return 'Urgent';
    }
  }
}
