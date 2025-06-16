import 'package:dartz/dartz.dart';
import '../../domain/entities/project_detail.dart';
import '../../domain/repositories/project_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/project_remote_datasource.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  const ProjectRepositoryImpl(this._remoteDataSource);
  
  final ProjectRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, ProjectDetail>> getProjectDetail(String projectId) async {
    try {
      final projectDetail = await _remoteDataSource.getProjectDetail(projectId);
      return Right(projectDetail);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
  }
}
