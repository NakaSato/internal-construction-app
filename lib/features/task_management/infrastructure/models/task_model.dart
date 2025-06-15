import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

/// Data model for Task entities that can be serialized/deserialized from JSON
@JsonSerializable()
class TaskModel {
  final String id;
  final String title;
  final String description;
  
  @JsonKey(name: 'status', fromJson: _statusFromJson, toJson: _statusToJson)
  final TaskStatus status;
  
  @JsonKey(name: 'priority', fromJson: _priorityFromJson, toJson: _priorityToJson)
  final TaskPriority priority;
  
  @JsonKey(name: 'due_date', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime dueDate;
  
  @JsonKey(name: 'project_id')
  final String projectId;
  
  @JsonKey(name: 'assignee_id')
  final String? assigneeId;
  
  @JsonKey(name: 'assignee_name')
  final String? assigneeName;
  
  @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? createdAt;
  
  @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? updatedAt;
  
  @JsonKey(name: 'completed_at', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? completedAt;
  
  @JsonKey(name: 'completion_percentage')
  final int completionPercentage;
  
  final List<String> attachments;
  final List<String> tags;

  TaskModel({
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

  /// Factory constructor for creating a new TaskModel from json map
  factory TaskModel.fromJson(Map<String, dynamic> json) => 
      _$TaskModelFromJson(json);

  /// Function to convert TaskModel to json map
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  /// Convert from model to domain entity
  Task toEntity() {
    return Task(
      id: id,
      title: title,
      description: description,
      status: status,
      priority: priority,
      dueDate: dueDate,
      projectId: projectId,
      assigneeId: assigneeId,
      assigneeName: assigneeName,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
      completionPercentage: completionPercentage,
      attachments: attachments,
      tags: tags,
    );
  }

  /// Create a model from domain entity
  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      projectId: task.projectId,
      assigneeId: task.assigneeId,
      assigneeName: task.assigneeName,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
      completedAt: task.completedAt,
      completionPercentage: task.completionPercentage,
      attachments: task.attachments,
      tags: task.tags,
    );
  }
  
  // Conversion helpers for JSON serialization
  static TaskStatus _statusFromJson(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.toString().split('.').last == value.toLowerCase(),
      orElse: () => TaskStatus.todo,
    );
  }
  
  static String _statusToJson(TaskStatus status) {
    return status.toString().split('.').last;
  }
  
  static TaskPriority _priorityFromJson(String value) {
    return TaskPriority.values.firstWhere(
      (priority) => priority.toString().split('.').last == value.toLowerCase(),
      orElse: () => TaskPriority.medium,
    );
  }
  
  static String _priorityToJson(TaskPriority priority) {
    return priority.toString().split('.').last;
  }
  
  static DateTime? _dateTimeFromJson(String? value) {
    return value != null ? DateTime.parse(value) : null;
  }
  
  static String? _dateTimeToJson(DateTime? date) {
    return date?.toIso8601String();
  }
}
