import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task.dart' as task_entity;

/// Repository interface for task management
abstract class TaskRepository {
  /// Get all tasks
  Future<Either<Failure, List<task_entity.Task>>> getTasks();

  /// Get a specific task by ID
  Future<Either<Failure, task_entity.Task>> getTask(String id);

  /// Get tasks for a specific project
  Future<Either<Failure, List<task_entity.Task>>> getTasksByProject(
    String projectId,
  );

  /// Get tasks assigned to a specific user
  Future<Either<Failure, List<task_entity.Task>>> getTasksByAssignee(
    String assigneeId,
  );

  /// Create a new task
  Future<Either<Failure, task_entity.Task>> createTask(task_entity.Task task);

  /// Update an existing task
  Future<Either<Failure, task_entity.Task>> updateTask(task_entity.Task task);

  /// Delete a task
  Future<Either<Failure, bool>> deleteTask(String id);

  /// Update task status
  Future<Either<Failure, task_entity.Task>> updateTaskStatus(
    String id,
    task_entity.TaskStatus status,
  );

  /// Update task completion percentage
  Future<Either<Failure, task_entity.Task>> updateTaskCompletion(
    String id,
    int percentage,
  );
}
