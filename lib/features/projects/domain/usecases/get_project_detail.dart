import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/project_detail.dart';
import '../repositories/project_repository.dart';

class GetProjectDetail
    implements UseCase<ProjectDetail, GetProjectDetailParams> {
  const GetProjectDetail(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Either<Failure, ProjectDetail>> call(
    GetProjectDetailParams params,
  ) async {
    return await _repository.getProjectDetail(params.projectId);
  }
}

class GetProjectDetailParams extends Equatable {
  const GetProjectDetailParams({required this.projectId});

  final String projectId;

  @override
  List<Object?> get props => [projectId];
}
