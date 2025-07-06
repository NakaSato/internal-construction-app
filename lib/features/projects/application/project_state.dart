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

/// State when projects are successfully loaded with pagination
class ProjectLoadedWithPagination extends ProjectState {
  const ProjectLoadedWithPagination({
    required this.projects,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.hasReachedMax = false,
  });

  final List<Project> projects;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool isLoadingMore;
  final bool isRefreshing;
  final bool hasReachedMax;

  @override
  List<Object?> get props => [
    projects,
    currentPage,
    totalPages,
    totalCount,
    isLoadingMore,
    isRefreshing,
    hasReachedMax,
  ];

  ProjectLoadedWithPagination copyWith({
    List<Project>? projects,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? hasReachedMax,
  }) {
    return ProjectLoadedWithPagination(
      projects: projects ?? this.projects,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
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
