import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/task.dart' as task_entity;
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

/// Implementation of [TaskRepository]
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<task_entity.Task>>> getTasks() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTasks = await remoteDataSource.getTasks();
        return Right(remoteTasks.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, task_entity.Task>> getTask(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final task = await remoteDataSource.getTaskById(id);
        return Right(task.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<task_entity.Task>>> getTasksByProject(
    String projectId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final tasks = await remoteDataSource.getTasksByProject(projectId);
        return Right(tasks.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<task_entity.Task>>> getTasksByAssignee(
    String assigneeId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final tasks = await remoteDataSource.getTasksByAssignee(assigneeId);
        return Right(tasks.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, task_entity.Task>> createTask(
    task_entity.Task task,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final taskModel = TaskModel.fromEntity(task);
        final createdTask = await remoteDataSource.createTask(taskModel);
        return Right(createdTask.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, task_entity.Task>> updateTask(
    task_entity.Task task,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final taskModel = TaskModel.fromEntity(task);
        final updatedTask = await remoteDataSource.updateTask(taskModel);
        return Right(updatedTask.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTask(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final deleted = await remoteDataSource.deleteTask(id);
        return Right(deleted);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, task_entity.Task>> updateTaskStatus(
    String id,
    task_entity.TaskStatus status,
  ) async {
    try {
      final taskResult = await getTask(id);
      return taskResult.fold((failure) => Left(failure), (task) {
        final updatedTask = task.copyWith(status: status);
        return updateTask(updatedTask);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, task_entity.Task>> updateTaskCompletion(
    String id,
    int percentage,
  ) async {
    try {
      final taskResult = await getTask(id);
      return taskResult.fold((failure) => Left(failure), (task) {
        final updatedTask = task.copyWith(completionPercentage: percentage);
        return updateTask(updatedTask);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
