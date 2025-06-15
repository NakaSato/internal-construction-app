import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';
import 'task_remote_datasource.dart';

/// Implementation of [TaskRemoteDataSource] using Dio HTTP client
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio client;
  final String baseUrl;

  TaskRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await client.get('$baseUrl/tasks');
      
      if (response.statusCode == 200) {
        final List<dynamic> taskJson = response.data['data'] as List;
        return taskJson
            .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch tasks',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'An error occurred while fetching tasks',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<TaskModel> getTaskById(String id) async {
    try {
      final response = await client.get('$baseUrl/tasks/$id');
      
      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch task',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'An error occurred while fetching the task',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    try {
      final response = await client.get('$baseUrl/projects/$projectId/tasks');
      
      if (response.statusCode == 200) {
        final List<dynamic> taskJson = response.data['data'] as List;
        return taskJson
            .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch project tasks',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'An error occurred while fetching project tasks',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<List<TaskModel>> getTasksByAssignee(String assigneeId) async {
    try {
      final response = await client.get('$baseUrl/users/$assigneeId/tasks');
      
      if (response.statusCode == 200) {
        final List<dynamic> taskJson = response.data['data'] as List;
        return taskJson
            .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch assignee tasks',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'An error occurred while fetching assignee tasks',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await client.post(
        '$baseUrl/tasks',
        data: task.toJson(),
      );
      
      if (response.statusCode == 201) {
        return TaskModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create task',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'An error occurred while creating the task',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await client.put(
        '$baseUrl/tasks/${task.id}',
        data: task.toJson(),
      );
      
      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update task',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'An error occurred while updating the task',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<bool> deleteTask(String id) async {
    try {
      final response = await client.delete('$baseUrl/tasks/$id');
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete task',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'An error occurred while deleting the task',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }
}
