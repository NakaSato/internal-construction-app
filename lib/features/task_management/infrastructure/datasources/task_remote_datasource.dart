import '../models/task_model.dart';

/// Interface for task remote data source
abstract class TaskRemoteDataSource {
  /// Get all tasks from the remote server
  Future<List<TaskModel>> getTasks();

  /// Get a specific task by ID
  Future<TaskModel> getTaskById(String id);

  /// Get all tasks for a specific project
  Future<List<TaskModel>> getTasksByProject(String projectId);

  /// Get all tasks assigned to a specific user
  Future<List<TaskModel>> getTasksByAssignee(String assigneeId);

  /// Create a new task on the remote server
  Future<TaskModel> createTask(TaskModel task);

  /// Update an existing task
  Future<TaskModel> updateTask(TaskModel task);

  /// Delete a task by ID
  Future<bool> deleteTask(String id);
}
