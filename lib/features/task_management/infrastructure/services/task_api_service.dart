import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/api_response.dart';
import 'package:equatable/equatable.dart';

/// Data transfer object for task information
class TaskDto extends Equatable {
  const TaskDto({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.projectId,
    required this.assigneeId,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.completedAt,
    this.estimatedHours,
    this.actualHours,
    this.tags,
    this.dependencies,
  });

  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String projectId;
  final String assigneeId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final double? estimatedHours;
  final double? actualHours;
  final List<String>? tags;
  final List<String>? dependencies;

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      projectId: json['project_id'] as String,
      assigneeId: json['assignee_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      estimatedHours: (json['estimated_hours'] as num?)?.toDouble(),
      actualHours: (json['actual_hours'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      dependencies: (json['dependencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'project_id': projectId,
      'assignee_id': assigneeId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      if (estimatedHours != null) 'estimated_hours': estimatedHours,
      if (actualHours != null) 'actual_hours': actualHours,
      if (tags != null) 'tags': tags,
      if (dependencies != null) 'dependencies': dependencies,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    status,
    priority,
    projectId,
    assigneeId,
    createdAt,
    updatedAt,
    dueDate,
    completedAt,
    estimatedHours,
    actualHours,
    tags,
    dependencies,
  ];
}

/// Request model for creating a new task
class CreateTaskRequest extends Equatable {
  const CreateTaskRequest({
    required this.title,
    required this.description,
    required this.priority,
    required this.projectId,
    required this.assigneeId,
    this.dueDate,
    this.estimatedHours,
    this.tags,
    this.dependencies,
  });

  final String title;
  final String description;
  final String priority;
  final String projectId;
  final String assigneeId;
  final DateTime? dueDate;
  final double? estimatedHours;
  final List<String>? tags;
  final List<String>? dependencies;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
      'project_id': projectId,
      'assignee_id': assigneeId,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
      if (estimatedHours != null) 'estimated_hours': estimatedHours,
      if (tags != null) 'tags': tags,
      if (dependencies != null) 'dependencies': dependencies,
    };
  }

  @override
  List<Object?> get props => [
    title,
    description,
    priority,
    projectId,
    assigneeId,
    dueDate,
    estimatedHours,
    tags,
    dependencies,
  ];
}

/// Request model for updating a task
class UpdateTaskRequest extends Equatable {
  const UpdateTaskRequest({
    this.title,
    this.description,
    this.status,
    this.priority,
    this.assigneeId,
    this.dueDate,
    this.estimatedHours,
    this.actualHours,
    this.tags,
    this.dependencies,
  });

  final String? title;
  final String? description;
  final String? status;
  final String? priority;
  final String? assigneeId;
  final DateTime? dueDate;
  final double? estimatedHours;
  final double? actualHours;
  final List<String>? tags;
  final List<String>? dependencies;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (status != null) json['status'] = status;
    if (priority != null) json['priority'] = priority;
    if (assigneeId != null) json['assignee_id'] = assigneeId;
    if (dueDate != null) json['due_date'] = dueDate!.toIso8601String();
    if (estimatedHours != null) json['estimated_hours'] = estimatedHours;
    if (actualHours != null) json['actual_hours'] = actualHours;
    if (tags != null) json['tags'] = tags;
    if (dependencies != null) json['dependencies'] = dependencies;
    return json;
  }

  @override
  List<Object?> get props => [
    title,
    description,
    status,
    priority,
    assigneeId,
    dueDate,
    estimatedHours,
    actualHours,
    tags,
    dependencies,
  ];
}

/// API service class for task-related operations
class TaskApiService {
  const TaskApiService(this._apiClient);

  final ApiClient _apiClient;

  /// Get all tasks with optional filtering
  Future<ApiResponse<List<TaskDto>>> getTasks({
    String? projectId,
    String? assigneeId,
    String? status,
    String? priority,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (projectId != null) queryParams['project_id'] = projectId;
      if (assigneeId != null) queryParams['assignee_id'] = assigneeId;
      if (status != null) queryParams['status'] = status;
      if (priority != null) queryParams['priority'] = priority;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(
        ApiConfig.tasksPath,
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => (json as List<dynamic>)
            .map((item) => TaskDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return _handleError<List<TaskDto>>(e);
    }
  }

  /// Get a specific task by ID
  Future<ApiResponse<TaskDto>> getTask(String taskId) async {
    try {
      final response = await _apiClient.get('${ApiConfig.tasksPath}/$taskId');

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => TaskDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError<TaskDto>(e);
    }
  }

  /// Create a new task
  Future<ApiResponse<TaskDto>> createTask(CreateTaskRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiConfig.tasksPath,
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => TaskDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError<TaskDto>(e);
    }
  }

  /// Update an existing task
  Future<ApiResponse<TaskDto>> updateTask(
    String taskId,
    UpdateTaskRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiConfig.tasksPath}/$taskId',
        data: request.toJson(),
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => TaskDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError<TaskDto>(e);
    }
  }

  /// Delete a task
  Future<ApiResponse<void>> deleteTask(String taskId) async {
    try {
      await _apiClient.delete('${ApiConfig.tasksPath}/$taskId');
      return const ApiResponse(success: true, data: null);
    } catch (e) {
      return _handleError<void>(e);
    }
  }

  /// Complete a task
  Future<ApiResponse<TaskDto>> completeTask(String taskId) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.tasksPath}/$taskId/complete',
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => TaskDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError<TaskDto>(e);
    }
  }

  /// Get tasks by project
  Future<ApiResponse<List<TaskDto>>> getTasksByProject(String projectId) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.projectsPath}/$projectId/tasks',
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => (json as List<dynamic>)
            .map((item) => TaskDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return _handleError<List<TaskDto>>(e);
    }
  }

  /// Get tasks assigned to a user
  Future<ApiResponse<List<TaskDto>>> getTasksByAssignee(
    String assigneeId,
  ) async {
    try {
      final response = await _apiClient.get(
        '${ApiConfig.usersPath}/$assigneeId/tasks',
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => (json as List<dynamic>)
            .map((item) => TaskDto.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return _handleError<List<TaskDto>>(e);
    }
  }

  /// Update task status
  Future<ApiResponse<TaskDto>> updateTaskStatus(
    String taskId,
    String status,
  ) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConfig.tasksPath}/$taskId/status',
        data: {'status': status},
      );

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => TaskDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError<TaskDto>(e);
    }
  }

  /// Generic error handler
  ApiResponse<T> _handleError<T>(dynamic error) {
    String message = 'An unexpected error occurred';

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message =
              'Connection timeout. Please check your internet connection.';
          break;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;

          if (statusCode == 401) {
            message = 'Authentication required. Please log in again.';
          } else if (statusCode == 403) {
            message =
                'Access denied. You don\'t have permission to perform this action.';
          } else if (statusCode == 404) {
            message = 'Task not found.';
          } else if (statusCode == 422) {
            message = 'Invalid task data provided.';
          } else if (responseData is Map &&
              responseData.containsKey('message')) {
            message = responseData['message'].toString();
          } else {
            message = 'Server error (${statusCode ?? 'unknown'})';
          }
          break;
        case DioExceptionType.cancel:
          message = 'Request was cancelled';
          break;
        case DioExceptionType.connectionError:
          message = 'Network error. Please check your internet connection.';
          break;
        case DioExceptionType.unknown:
          message = error.message ?? 'Unknown network error occurred';
          break;
        case DioExceptionType.badCertificate:
          message = 'Security certificate error';
          break;
      }
    }

    return ApiResponse<T>(success: false, message: message, data: null);
  }
}
