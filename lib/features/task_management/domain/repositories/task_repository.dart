import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task.dart';

/// Repository interface for task management
abstract class TaskRepository {
  /// Get all tasks
  Future<Either<Failure, List<Task>>> getTasks();
  
  /// Get a specific task by ID
  Future<Either<Failure, Task>> getTask(String id);
  
  /// Get tasks for a specific project
  Future<Either<Failure, List<Task>>> getTasksByProject(String projectId);
  
  /// Get tasks assigned to a specific user
  Future<Either<Failure, List<Task>>> getTasksByAssignee(String assigneeId);
  
  /// Create a new task
  Future<Either<Failure, Task>> createTask(Task task);
  
  /// Update an existing task
  Future<Either<Failure, Task>> updateTask(Task task);
  
  /// Delete a task
  Future<Either<Failure, bool>> deleteTask(String id);
  
  /// Update task status
  Future<Either<Failure, Task>> updateTaskStatus(String id, TaskStatus status);
  
  /// Update task completion percentage
  Future<Either<Failure, Task>> updateTaskCompletion(String id, int percentage);
}
