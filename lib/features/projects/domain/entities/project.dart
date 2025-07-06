import 'package:equatable/equatable.dart';
import '../../../authentication/domain/entities/user.dart';

/// Task entity for project tasks
class ProjectTask extends Equatable {
  const ProjectTask({
    required this.id,
    required this.title,
    required this.status,
    required this.dueDate,
  });

  final String id;
  final String title;
  final String status;
  final DateTime dueDate;

  @override
  List<Object?> get props => [id, title, status, dueDate];
}

/// Recent report entity for project reports
class RecentReport extends Equatable {
  const RecentReport({
    required this.id,
    required this.reportDate,
    required this.userName,
    required this.hoursWorked,
  });

  final String id;
  final DateTime reportDate;
  final String userName;
  final double hoursWorked;

  @override
  List<Object?> get props => [id, reportDate, userName, hoursWorked];
}

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
    // Enhanced fields matching API response
    this.description = '',
    this.location,
    this.budget,
    this.actualCost,
    this.totalTasks,
    this.completedTasks,
    this.progressPercentage,
    this.tasks = const [],
    this.recentReports = const [],
    // Additional API fields
    this.createdAt,
    this.updatedAt,
    // Legacy fields for backward compatibility
    this.priority = ProjectPriority.medium,
    this.assignedUserId,
    this.tags = const [],
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

  // Enhanced fields matching API response
  final String description;
  final String? location;
  final double? budget;
  final double? actualCost;
  final int? totalTasks;
  final int? completedTasks;
  final double? progressPercentage;
  final List<ProjectTask> tasks;
  final List<RecentReport> recentReports;

  // Additional API fields
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Legacy fields for backward compatibility
  final ProjectPriority priority;
  final String? assignedUserId;
  final List<String> tags;
  final DateTime? dueDate;

  /// Legacy getters for backward compatibility
  String get id => projectId;
  String get name => projectName;

  /// Calculate completion percentage based on tasks
  int get completionPercentage {
    // Use API progress percentage if available
    if (progressPercentage != null) {
      return progressPercentage!.round();
    }

    // Use totalTasks and completedTasks if available
    if (totalTasks != null && totalTasks! > 0) {
      final completed = completedTasks ?? 0;
      return ((completed / totalTasks!) * 100).round();
    }

    // Fallback to legacy task count
    if (taskCount == 0) return 0;
    return ((completedTaskCount / taskCount) * 100).round();
  }

  /// Get budget utilization percentage
  double get budgetUtilization {
    if (budget == null || budget! == 0) return 0.0;
    final cost = actualCost ?? 0.0;
    return (cost / budget!) * 100;
  }

  /// Check if project is over budget
  bool get isOverBudget {
    if (budget == null || actualCost == null) return false;
    return actualCost! > budget!;
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
    location,
    budget,
    actualCost,
    totalTasks,
    completedTasks,
    progressPercentage,
    tasks,
    recentReports,
    createdAt,
    updatedAt,
    priority,
    assignedUserId,
    tags,
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
    String? location,
    double? budget,
    double? actualCost,
    int? totalTasks,
    int? completedTasks,
    double? progressPercentage,
    List<ProjectTask>? tasks,
    List<RecentReport>? recentReports,
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
      location: location ?? this.location,
      budget: budget ?? this.budget,
      actualCost: actualCost ?? this.actualCost,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      tasks: tasks ?? this.tasks,
      recentReports: recentReports ?? this.recentReports,
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
