import 'package:equatable/equatable.dart';

import '../domain/entities/project.dart';

/// Base class for all project states
abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no projects are loaded
class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

/// State when projects are being loaded
class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

/// State when projects are successfully loaded
class ProjectLoaded extends ProjectState {
  const ProjectLoaded({required this.projects, this.isRefreshing = false});

  final List<Project> projects;
  final bool isRefreshing;

  @override
  List<Object?> get props => [projects, isRefreshing];

  ProjectLoaded copyWith({List<Project>? projects, bool? isRefreshing}) {
    return ProjectLoaded(
      projects: projects ?? this.projects,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// State when project operation fails
class ProjectError extends ProjectState {
  const ProjectError({required this.message, this.projects = const []});

  final String message;
  final List<Project> projects;

  @override
  List<Object?> get props => [message, projects];
}

/// State when a project operation is successful
class ProjectOperationSuccess extends ProjectState {
  const ProjectOperationSuccess({
    required this.message,
    required this.projects,
  });

  final String message;
  final List<Project> projects;

  @override
  List<Object?> get props => [message, projects];
}
