import 'package:equatable/equatable.dart';

import '../domain/entities/project.dart';

/// Base class for all project events
abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all projects
class ProjectLoadRequested extends ProjectEvent {
  const ProjectLoadRequested();
}

/// Event to load projects by status
class ProjectLoadByStatusRequested extends ProjectEvent {
  const ProjectLoadByStatusRequested(this.status);

  final ProjectStatus status;

  @override
  List<Object?> get props => [status];
}

/// Event to search projects
class ProjectSearchRequested extends ProjectEvent {
  const ProjectSearchRequested(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Event to create a new project
class ProjectCreateRequested extends ProjectEvent {
  const ProjectCreateRequested(this.project);

  final Project project;

  @override
  List<Object?> get props => [project];
}

/// Event to update a project
class ProjectUpdateRequested extends ProjectEvent {
  const ProjectUpdateRequested(this.project);

  final Project project;

  @override
  List<Object?> get props => [project];
}

/// Event to delete a project
class ProjectDeleteRequested extends ProjectEvent {
  const ProjectDeleteRequested(this.projectId);

  final String projectId;

  @override
  List<Object?> get props => [projectId];
}

/// Event to refresh projects
class ProjectRefreshRequested extends ProjectEvent {
  const ProjectRefreshRequested();
}
