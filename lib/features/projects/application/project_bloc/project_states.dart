import 'package:equatable/equatable.dart';
import '../../domain/entities/project_api_models.dart';

/// States for Project BLoC
abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the bloc is created
class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

/// Loading state when fetching projects
class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

/// State when projects are successfully loaded
class ProjectsLoaded extends ProjectState {
  const ProjectsLoaded({required this.projectsResponse});

  final ProjectsResponse projectsResponse;

  @override
  List<Object?> get props => [projectsResponse];
}

/// State when project details are successfully loaded
class ProjectDetailsLoaded extends ProjectState {
  const ProjectDetailsLoaded({required this.project});

  final Project project;

  @override
  List<Object?> get props => [project];
}

/// State when a project operation (create, update, delete) is successful
class ProjectOperationSuccess extends ProjectState {
  const ProjectOperationSuccess({required this.message, this.project, this.operationType});

  final String message;
  final Project? project;
  final String? operationType;

  @override
  List<Object?> get props => [message, project, operationType];
}

/// State when project statistics are successfully loaded
class ProjectStatisticsLoaded extends ProjectState {
  const ProjectStatisticsLoaded({required this.statistics});

  final Map<String, dynamic> statistics;

  @override
  List<Object?> get props => [statistics];
}

/// Error state when any operation fails
class ProjectError extends ProjectState {
  const ProjectError({required this.message, this.errorCode});

  final String message;
  final String? errorCode;

  @override
  List<Object?> get props => [message, errorCode];
}
