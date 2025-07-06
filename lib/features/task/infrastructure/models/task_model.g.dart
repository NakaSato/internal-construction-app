// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  status: TaskModel._statusFromJson(json['status'] as String),
  priority: TaskModel._priorityFromJson(json['priority'] as String),
  dueDate: TaskModel._requiredDateTimeFromJson(json['due_date'] as String),
  projectId: json['project_id'] as String,
  assigneeId: json['assignee_id'] as String?,
  assigneeName: json['assignee_name'] as String?,
  createdAt: TaskModel._dateTimeFromJson(json['created_at'] as String?),
  updatedAt: TaskModel._dateTimeFromJson(json['updated_at'] as String?),
  completedAt: TaskModel._dateTimeFromJson(json['completed_at'] as String?),
  completionPercentage: (json['completion_percentage'] as num?)?.toInt() ?? 0,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'status': TaskModel._statusToJson(instance.status),
  'priority': TaskModel._priorityToJson(instance.priority),
  'due_date': TaskModel._dateTimeToJson(instance.dueDate),
  'project_id': instance.projectId,
  'assignee_id': instance.assigneeId,
  'assignee_name': instance.assigneeName,
  'created_at': TaskModel._dateTimeToJson(instance.createdAt),
  'updated_at': TaskModel._dateTimeToJson(instance.updatedAt),
  'completed_at': TaskModel._dateTimeToJson(instance.completedAt),
  'completion_percentage': instance.completionPercentage,
  'attachments': instance.attachments,
  'tags': instance.tags,
};
