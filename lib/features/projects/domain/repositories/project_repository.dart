import 'package:dartz/dartz.dart';

import '../entities/project.dart';
import '../entities/project_detail.dart';
import '../../../../core/errors/failures.dart';

abstract class ProjectRepository {
  // ...existing code...

  Future<Either<Failure, ProjectDetail>> getProjectDetail(String projectId);
}
