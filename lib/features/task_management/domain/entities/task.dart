import 'package:equatable/equatable.dart';

/// Status values for a task
enum TaskStatus {
  todo,
  inProgress,
  review,
  completed,
  cancelled,
}

/// Priority levels for a task
enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

/// Task entity representing a work item in the system
class Task extends Equatable {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.projectId,
    this.assigneeId,
    this.assigneeName,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.completionPercentage = 0,
    this.attachments = const [],
    this.tags = const [],
  });
  
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final String projectId;
  final String? assigneeId;
  final String? assigneeName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final int completionPercentage;
  final List<String> attachments;
  final List<String> tags;
  
  /// Create a copy of this task with specific properties changed
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    String? projectId,
    String? assigneeId,
    String? assigneeName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    int? completionPercentage,
    List<String>? attachments,
    List<String>? tags,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      projectId: projectId ?? this.projectId,
      assigneeId: assigneeId ?? this.assigneeId,
      assigneeName: assigneeName ?? this.assigneeName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      attachments: attachments ?? this.attachments,
      tags: tags ?? this.tags,
    );
  }
  
  @override
  List<Object?> get props => [
    id, 
    title, 
    description, 
    status, 
    priority, 
    dueDate, 
    projectId,
    assigneeId, 
    assigneeName, 
    createdAt, 
    updatedAt, 
    completedAt,
    completionPercentage,
    attachments,
    tags,
  ];
}
