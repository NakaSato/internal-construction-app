import 'package:equatable/equatable.dart';

/// Status of a construction task
enum TaskStatus {
  notStarted,
  inProgress,
  completed,
  delayed,
  onHold,
  cancelled,
}

/// Priority level of a construction task
enum TaskPriority { low, medium, high, critical }

/// Construction task entity for solar project management
class ConstructionTask extends Equatable {
  const ConstructionTask({
    required this.id,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.projectId,
    this.description,
    this.status = TaskStatus.notStarted,
    this.progress = 0.0,
    this.priority = TaskPriority.medium,
    this.assignedTeam,
    this.estimatedHours,
    this.actualHours,
    this.materials = const [],
    this.dependencies = const [],
    this.notes,
    this.completedBy,
    this.completedAt,
  });

  /// Unique task identifier
  final String id;

  /// Task title/name
  final String title;

  /// Task start date
  final DateTime startDate;

  /// Task end date (estimated or actual)
  final DateTime endDate;

  /// Project this task belongs to
  final String projectId;

  /// Detailed task description
  final String? description;

  /// Current status of the task
  final TaskStatus status;

  /// Progress percentage (0.0 to 1.0)
  final double progress;

  /// Task priority level
  final TaskPriority priority;

  /// Assigned team or individual
  final String? assignedTeam;

  /// Estimated hours to complete
  final double? estimatedHours;

  /// Actual hours spent
  final double? actualHours;

  /// Required materials/equipment
  final List<String> materials;

  /// Task dependencies (other task IDs)
  final List<String> dependencies;

  /// Additional notes
  final String? notes;

  /// Who completed the task
  final String? completedBy;

  /// When the task was completed
  final DateTime? completedAt;

  /// Task duration in days
  int get durationInDays => endDate.difference(startDate).inDays + 1;

  /// Whether task is currently active
  bool get isActive {
    final now = DateTime.now();
    return status == TaskStatus.inProgress &&
        now.isAfter(startDate) &&
        now.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Whether task is overdue
  bool get isOverdue {
    final now = DateTime.now();
    return status != TaskStatus.completed &&
        status != TaskStatus.cancelled &&
        now.isAfter(endDate);
  }

  /// Whether task is upcoming (starts in future)
  bool get isUpcoming {
    final now = DateTime.now();
    return status == TaskStatus.notStarted && now.isBefore(startDate);
  }

  /// Get estimated completion date based on current progress
  DateTime? get estimatedCompletionDate {
    if (status == TaskStatus.completed) return completedAt;
    if (progress <= 0) return endDate;

    final elapsed = DateTime.now().difference(startDate).inDays;
    final totalEstimated = (elapsed / progress).round();
    return startDate.add(Duration(days: totalEstimated));
  }

  /// Get color based on status
  String get statusColor {
    switch (status) {
      case TaskStatus.notStarted:
        return '#9E9E9E'; // Grey
      case TaskStatus.inProgress:
        return isOverdue
            ? '#F44336'
            : '#2196F3'; // Red if overdue, Blue otherwise
      case TaskStatus.completed:
        return '#4CAF50'; // Green
      case TaskStatus.delayed:
        return '#FF9800'; // Orange
      case TaskStatus.onHold:
        return '#9C27B0'; // Purple
      case TaskStatus.cancelled:
        return '#424242'; // Dark Grey
    }
  }

  /// Get priority color
  String get priorityColor {
    switch (priority) {
      case TaskPriority.low:
        return '#8BC34A'; // Light Green
      case TaskPriority.medium:
        return '#FF9800'; // Orange
      case TaskPriority.high:
        return '#FF5722'; // Deep Orange
      case TaskPriority.critical:
        return '#F44336'; // Red
    }
  }

  /// Copy with method for immutable updates
  ConstructionTask copyWith({
    String? id,
    String? title,
    DateTime? startDate,
    DateTime? endDate,
    String? projectId,
    String? description,
    TaskStatus? status,
    double? progress,
    TaskPriority? priority,
    String? assignedTeam,
    double? estimatedHours,
    double? actualHours,
    List<String>? materials,
    List<String>? dependencies,
    String? notes,
    String? completedBy,
    DateTime? completedAt,
  }) {
    return ConstructionTask(
      id: id ?? this.id,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      projectId: projectId ?? this.projectId,
      description: description ?? this.description,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      priority: priority ?? this.priority,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      materials: materials ?? this.materials,
      dependencies: dependencies ?? this.dependencies,
      notes: notes ?? this.notes,
      completedBy: completedBy ?? this.completedBy,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    startDate,
    endDate,
    projectId,
    description,
    status,
    progress,
    priority,
    assignedTeam,
    estimatedHours,
    actualHours,
    materials,
    dependencies,
    notes,
    completedBy,
    completedAt,
  ];

  @override
  String toString() =>
      'ConstructionTask(id: $id, title: $title, status: $status, progress: $progress)';
}

/// Extension for TaskStatus
extension TaskStatusX on TaskStatus {
  /// Display name for the task status
  String get displayName {
    switch (this) {
      case TaskStatus.notStarted:
        return 'Not Started';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.completed:
        return 'Completed';
      case TaskStatus.delayed:
        return 'Delayed';
      case TaskStatus.onHold:
        return 'On Hold';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Whether the status represents an active state
  bool get isActive => this == TaskStatus.inProgress;

  /// Whether the status represents a completed state
  bool get isCompleted => this == TaskStatus.completed;

  /// Whether the status represents a problematic state
  bool get isProblematic =>
      this == TaskStatus.delayed || this == TaskStatus.onHold;
}

/// Extension for TaskPriority
extension TaskPriorityX on TaskPriority {
  /// Display name for the task priority
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.critical:
        return 'Critical';
    }
  }

  /// Numeric value for sorting
  int get value {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
      case TaskPriority.critical:
        return 4;
    }
  }
}
