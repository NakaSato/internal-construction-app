import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../common/models/usecase/usecase.dart';
import '../entities/wbs_task.dart';
import '../entities/wbs_structure.dart';
import '../repositories/wbs_repository.dart';

/// Use case to get project WBS structure
@injectable
class GetProjectWbs implements UseCase<WbsStructure, GetProjectWbsParams> {
  const GetProjectWbs(this._repository);

  final WbsRepository _repository;

  @override
  Future<Either<Failure, WbsStructure>> call(GetProjectWbsParams params) async {
    return await _repository.getProjectWbs(
      projectId: params.projectId,
      level: params.level,
      status: params.status,
      assignedTo: params.assignedTo,
      includeChildren: params.includeChildren,
      includeEvidence: params.includeEvidence,
    );
  }
}

class GetProjectWbsParams {
  const GetProjectWbsParams({
    required this.projectId,
    this.level,
    this.status,
    this.assignedTo,
    this.includeChildren = true,
    this.includeEvidence = false,
  });

  final String projectId;
  final int? level;
  final WbsTaskStatus? status;
  final String? assignedTo;
  final bool includeChildren;
  final bool includeEvidence;
}

/// Use case to get WBS task details
@injectable
class GetWbsTask implements UseCase<WbsTask, GetWbsTaskParams> {
  const GetWbsTask(this._repository);

  final WbsRepository _repository;

  @override
  Future<Either<Failure, WbsTask>> call(GetWbsTaskParams params) async {
    return await _repository.getWbsTask(params.taskId);
  }
}

class GetWbsTaskParams {
  const GetWbsTaskParams({required this.taskId});

  final String taskId;
}

/// Use case to create a new WBS task
@injectable
class CreateWbsTask implements UseCase<WbsTask, CreateWbsTaskParams> {
  const CreateWbsTask(this._repository);

  final WbsRepository _repository;

  @override
  Future<Either<Failure, WbsTask>> call(CreateWbsTaskParams params) async {
    return await _repository.createWbsTask(projectId: params.projectId, task: params.task);
  }
}

class CreateWbsTaskParams {
  const CreateWbsTaskParams({required this.projectId, required this.task});

  final String projectId;
  final WbsTask task;
}

/// Use case to update a WBS task
@injectable
class UpdateWbsTask implements UseCase<WbsTask, UpdateWbsTaskParams> {
  const UpdateWbsTask(this._repository);

  final WbsRepository _repository;

  @override
  Future<Either<Failure, WbsTask>> call(UpdateWbsTaskParams params) async {
    return await _repository.updateWbsTask(taskId: params.taskId, task: params.task);
  }
}

class UpdateWbsTaskParams {
  const UpdateWbsTaskParams({required this.taskId, required this.task});

  final String taskId;
  final WbsTask task;
}

/// Use case to update task status
@injectable
class UpdateTaskStatus implements UseCase<WbsTask, UpdateTaskStatusParams> {
  const UpdateTaskStatus(this._repository);

  final WbsRepository _repository;

  @override
  Future<Either<Failure, WbsTask>> call(UpdateTaskStatusParams params) async {
    return await _repository.updateTaskStatus(
      taskId: params.taskId,
      status: params.status,
      completionNotes: params.completionNotes,
      completedBy: params.completedBy,
    );
  }
}

class UpdateTaskStatusParams {
  const UpdateTaskStatusParams({required this.taskId, required this.status, this.completionNotes, this.completedBy});

  final String taskId;
  final WbsTaskStatus status;
  final String? completionNotes;
  final String? completedBy;
}

/// Use case to delete a WBS task
@injectable
class DeleteWbsTask implements UseCase<void, DeleteWbsTaskParams> {
  const DeleteWbsTask(this._repository);

  final WbsRepository _repository;

  @override
  Future<Either<Failure, void>> call(DeleteWbsTaskParams params) async {
    return await _repository.deleteWbsTask(params.taskId);
  }
}

class DeleteWbsTaskParams {
  const DeleteWbsTaskParams({required this.taskId});

  final String taskId;
}
