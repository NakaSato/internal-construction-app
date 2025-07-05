import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../common/models/errors/failures.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../../domain/repositories/task_repository.dart';
import '../../infrastructure/repositories/task_repository_impl.dart';

/// API-based task repository that extends the existing implementation
/// Provides a clean interface for real-time wrapper integration
@Injectable()
class ApiTaskRepository implements TaskRepository {
  ApiTaskRepository(this._baseRepository);

  final TaskRepositoryImpl _baseRepository;

  @override
  Future<Either<Failure, List<task_entity.Task>>> getTasks() async {
    return await _baseRepository.getTasks();
  }

  @override
  Future<Either<Failure, task_entity.Task>> getTask(String id) async {
    return await _baseRepository.getTask(id);
  }

  @override
  Future<Either<Failure, task_entity.Task>> createTask(task_entity.Task task) async {
    return await _baseRepository.createTask(task);
  }

  @override
  Future<Either<Failure, task_entity.Task>> updateTask(task_entity.Task task) async {
    return await _baseRepository.updateTask(task);
  }

  @override
  Future<Either<Failure, bool>> deleteTask(String id) async {
    return await _baseRepository.deleteTask(id);
  }

  @override
  Future<Either<Failure, List<task_entity.Task>>> getTasksByProject(String projectId) async {
    return await _baseRepository.getTasksByProject(projectId);
  }

  @override
  Future<Either<Failure, List<task_entity.Task>>> getTasksByAssignee(String assigneeId) async {
    return await _baseRepository.getTasksByAssignee(assigneeId);
  }

  @override
  Future<Either<Failure, task_entity.Task>> updateTaskCompletion(String id, int percentage) async {
    return await _baseRepository.updateTaskCompletion(id, percentage);
  }

  @override
  Future<Either<Failure, task_entity.Task>> updateTaskStatus(String taskId, task_entity.TaskStatus status) async {
    return await _baseRepository.updateTaskStatus(taskId, status);
  }
}
