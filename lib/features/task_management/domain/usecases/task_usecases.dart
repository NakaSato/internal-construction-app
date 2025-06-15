import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart' as task_entity;
import '../repositories/task_repository.dart';

/// UseCase for getting all tasks
class GetTasks implements UseCase<List<task_entity.Task>, NoParams> {
  final TaskRepository repository;

  GetTasks(this.repository);

  @override
  Future<Either<Failure, List<task_entity.Task>>> call(NoParams params) async {
    return await repository.getTasks();
  }
}

/// UseCase for getting a specific task by ID
class GetTaskById implements UseCase<task_entity.Task, TaskParams> {
  final TaskRepository repository;

  GetTaskById(this.repository);

  @override
  Future<Either<Failure, task_entity.Task>> call(TaskParams params) async {
    return await repository.getTask(params.taskId);
  }
}

/// UseCase for getting tasks by project ID
class GetTasksByProject
    implements UseCase<List<task_entity.Task>, ProjectTasksParams> {
  final TaskRepository repository;

  GetTasksByProject(this.repository);

  @override
  Future<Either<Failure, List<task_entity.Task>>> call(
    ProjectTasksParams params,
  ) async {
    return await repository.getTasksByProject(params.projectId);
  }
}

/// UseCase for creating a new task
class CreateTask implements UseCase<task_entity.Task, CreateTaskParams> {
  final TaskRepository repository;

  CreateTask(this.repository);

  @override
  Future<Either<Failure, task_entity.Task>> call(
    CreateTaskParams params,
  ) async {
    return await repository.createTask(params.task);
  }
}

/// UseCase for updating a task
class UpdateTask implements UseCase<task_entity.Task, UpdateTaskParams> {
  final TaskRepository repository;

  UpdateTask(this.repository);

  @override
  Future<Either<Failure, task_entity.Task>> call(
    UpdateTaskParams params,
  ) async {
    return await repository.updateTask(params.task);
  }
}

/// Parameters for task ID operations
class TaskParams extends Equatable {
  final String taskId;

  const TaskParams({required this.taskId});

  @override
  List<Object> get props => [taskId];
}

/// Parameters for project tasks operations
class ProjectTasksParams extends Equatable {
  final String projectId;

  const ProjectTasksParams({required this.projectId});

  @override
  List<Object> get props => [projectId];
}

/// Parameters for create task operation
class CreateTaskParams extends Equatable {
  final task_entity.Task task;

  const CreateTaskParams({required this.task});

  @override
  List<Object> get props => [task];
}

/// Parameters for update task operation
class UpdateTaskParams extends Equatable {
  final task_entity.Task task;

  const UpdateTaskParams({required this.task});

  @override
  List<Object> get props => [task];
}
