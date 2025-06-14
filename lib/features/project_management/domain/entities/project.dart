import 'package:equatable/equatable.dart';
import '../../../authentication/domain/entities/user.dart';

/// Project entity representing a project in the system
class Project extends Equatable {
  const Project({
    required this.projectId,
    required this.projectName,
    required this.address,
    required this.clientInfo,
    required this.status,
    required this.startDate,
    required this.estimatedEndDate,
    this.actualEndDate,
    this.projectManager,
    this.taskCount = 0,
    this.completedTaskCount = 0,
    this.imageUrl,
    // Legacy fields for backward compatibility
    this.description = '',
    this.priority = ProjectPriority.medium,
    this.assignedUserId,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
    this.dueDate,
  });

  final String projectId;
  final String projectName;
  final String address;
  final String clientInfo;
  final String status;
  final DateTime startDate;
  final DateTime estimatedEndDate;
  final DateTime? actualEndDate;
  final User? projectManager;
  final int taskCount;
  final int completedTaskCount;
  final String? imageUrl;

  // Legacy fields for backward compatibility
  final String description;
  final ProjectPriority priority;
  final String? assignedUserId;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;

  /// Legacy getters for backward compatibility
  String get id => projectId;
  String get name => projectName;

  /// Calculate completion percentage based on tasks
  int get completionPercentage {
    if (taskCount == 0) return 0;
    return ((completedTaskCount / taskCount) * 100).round();
  }

  /// Parse status string to ProjectStatus enum
  ProjectStatus get projectStatus {
    switch (status.toLowerCase()) {
      case 'planning':
        return ProjectStatus.planning;
      case 'in progress':
      case 'inprogress':
        return ProjectStatus.inProgress;
      case 'on hold':
      case 'onhold':
        return ProjectStatus.onHold;
      case 'completed':
        return ProjectStatus.completed;
      case 'cancelled':
        return ProjectStatus.cancelled;
      default:
        return ProjectStatus.inProgress;
    }
  }

  @override
  List<Object?> get props => [
    projectId,
    projectName,
    address,
    clientInfo,
    status,
    startDate,
    estimatedEndDate,
    actualEndDate,
    projectManager,
    taskCount,
    completedTaskCount,
    imageUrl,
    description,
    priority,
    assignedUserId,
    tags,
    createdAt,
    updatedAt,
    dueDate,
  ];

  Project copyWith({
    String? projectId,
    String? projectName,
    String? address,
    String? clientInfo,
    String? status,
    DateTime? startDate,
    DateTime? estimatedEndDate,
    DateTime? actualEndDate,
    User? projectManager,
    int? taskCount,
    int? completedTaskCount,
    String? imageUrl,
    String? description,
    ProjectPriority? priority,
    String? assignedUserId,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
  }) {
    return Project(
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      address: address ?? this.address,
      clientInfo: clientInfo ?? this.clientInfo,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      estimatedEndDate: estimatedEndDate ?? this.estimatedEndDate,
      actualEndDate: actualEndDate ?? this.actualEndDate,
      projectManager: projectManager ?? this.projectManager,
      taskCount: taskCount ?? this.taskCount,
      completedTaskCount: completedTaskCount ?? this.completedTaskCount,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  bool get isOverdue {
    final now = DateTime.now();
    return now.isAfter(estimatedEndDate) &&
        actualEndDate == null &&
        projectStatus != ProjectStatus.completed;
  }

  bool get isCompleted => projectStatus == ProjectStatus.completed;
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
