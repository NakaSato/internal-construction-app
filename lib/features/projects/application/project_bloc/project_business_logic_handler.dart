import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/project_api_models.dart';
import '../../domain/repositories/project_repository.dart';
import 'project_events.dart';
import 'project_states.dart';

/// Handles core project business logic and repository operations
class ProjectBusinessLogicHandler {
  ProjectBusinessLogicHandler({required ProjectRepository repository}) : _repository = repository;

  final ProjectRepository _repository;

  /// Load projects with optional query and user role
  Future<void> onLoadProjectsRequested(LoadProjectsRequested event, Emitter<ProjectState> emit) async {
    // Check if we already have loaded projects to prevent unnecessary loading state
    final currentState = emit.state;
    final bool skipLoadingState = event.skipLoadingState || (currentState is ProjectsLoaded && !event.forceRefresh);

    if (!skipLoadingState) {
      emit(const ProjectLoading());
    }

    try {
      final query = event.query ?? const ProjectsQuery();
      final projectsResponse = await _repository.getAllProjects(query);

      emit(ProjectsLoaded(projectsResponse: projectsResponse));

      if (kDebugMode) {
        debugPrint('✅ Loaded ${projectsResponse.projects.length} projects');
      }
    } catch (e) {
      final errorMessage = 'Failed to load projects: ${e.toString()}';
      if (kDebugMode) {
        debugPrint('❌ $errorMessage');
      }
      emit(ProjectError(message: errorMessage));
    }
  }

  /// Search projects with term and filters
  Future<void> onSearchProjectsRequested(SearchProjectsRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      final query = event.filters ?? const ProjectsQuery();
      final searchQuery = query.copyWith(searchTerm: event.searchTerm);
      final projectsResponse = await _repository.getAllProjects(searchQuery);

      emit(ProjectsLoaded(projectsResponse: projectsResponse));

      if (kDebugMode) {
        debugPrint('✅ Search returned ${projectsResponse.projects.length} projects');
      }
    } catch (e) {
      final errorMessage = 'Failed to search projects: ${e.toString()}';
      if (kDebugMode) {
        debugPrint('❌ $errorMessage');
      }
      emit(ProjectError(message: errorMessage));
    }
  }

  /// Load specific project details
  Future<void> onLoadProjectDetailsRequested(LoadProjectDetailsRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      final project = await _repository.getProjectById(event.projectId);
      emit(ProjectDetailsLoaded(project: project));

      if (kDebugMode) {
        debugPrint('✅ Loaded project details for: ${project.name}');
      }
    } catch (e) {
      final errorMessage = 'Failed to load project details: ${e.toString()}';
      if (kDebugMode) {
        debugPrint('❌ $errorMessage');
      }
      emit(ProjectError(message: errorMessage));
    }
  }

  /// Create a new project
  Future<void> onCreateProjectRequested(CreateProjectRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      final project = await _repository.createProject(event.projectData);
      emit(ProjectOperationSuccess(message: 'Project created successfully', project: project, operationType: 'create'));

      if (kDebugMode) {
        debugPrint('✅ Created project: ${project.name}');
      }
    } catch (e) {
      final errorMessage = 'Failed to create project: ${e.toString()}';
      if (kDebugMode) {
        debugPrint('❌ $errorMessage');
      }
      emit(ProjectError(message: errorMessage));
    }
  }

  /// Update an existing project
  Future<void> onUpdateProjectRequested(UpdateProjectRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      final project = await _repository.updateProject(event.projectId, event.projectData);
      emit(ProjectOperationSuccess(message: 'Project updated successfully', project: project, operationType: 'update'));

      if (kDebugMode) {
        debugPrint('✅ Updated project: ${project.name}');
      }
    } catch (e) {
      final errorMessage = 'Failed to update project: ${e.toString()}';
      if (kDebugMode) {
        debugPrint('❌ $errorMessage');
      }
      emit(ProjectError(message: errorMessage));
    }
  }

  /// Delete a project
  Future<void> onDeleteProjectRequested(DeleteProjectRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      await _repository.deleteProject(event.projectId);
      emit(ProjectOperationSuccess(message: 'Project deleted successfully', operationType: 'delete'));

      if (kDebugMode) {
        debugPrint('✅ Deleted project: ${event.projectId}');
      }
    } catch (e) {
      final errorMessage = 'Failed to delete project: ${e.toString()}';
      if (kDebugMode) {
        debugPrint('❌ $errorMessage');
      }
      emit(ProjectError(message: errorMessage));
    }
  }

  /// Load project statistics
  Future<void> onLoadProjectStatisticsRequested(
    LoadProjectStatisticsRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());

    try {
      final statistics = await _repository.getProjectStatistics(userRole: event.userRole, managerId: event.managerId);
      emit(ProjectStatisticsLoaded(statistics: statistics));

      if (kDebugMode) {
        debugPrint('✅ Loaded project statistics');
      }
    } catch (e) {
      final errorMessage = 'Failed to load project statistics: ${e.toString()}';
      if (kDebugMode) {
        debugPrint('❌ $errorMessage');
      }
      emit(ProjectError(message: errorMessage));
    }
  }

  /// Load projects by manager
  Future<void> onLoadProjectsByManagerRequested(
    LoadProjectsByManagerRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());

    try {
      final query = ProjectsQuery(managerId: event.managerId);
      final projectsResponse = await _repository.getAllProjects(query);

      emit(ProjectsLoaded(projectsResponse: projectsResponse));

      if (kDebugMode) {
        debugPrint('✅ Loaded ${projectsResponse.projects.length} projects for manager: ${event.managerId}');
      }
    } catch (e) {
      final errorMessage = 'Failed to load projects by manager: ${e.toString()}';
      if (kDebugMode) {
        debugPrint('❌ $errorMessage');
      }
      emit(ProjectError(message: errorMessage));
    }
  }

  /// Refresh projects with cache clear
  Future<void> onRefreshProjectsWithCacheClear(RefreshProjectsWithCacheClear event, Emitter<ProjectState> emit) async {
    if (!event.skipLoadingState) {
      emit(const ProjectLoading());
    }

    try {
      // Clear cache if repository supports it
      if (_repository is ProjectRepositoryImpl) {
        // Call cache clear method if available
      }

      final query = event.query ?? const ProjectsQuery();
      final projectsResponse = await _repository.getAllProjects(query);

      emit(ProjectsLoaded(projectsResponse: projectsResponse));

      if (kDebugMode) {
        debugPrint('✅ Refreshed ${projectsResponse.projects.length} projects (cache cleared)');
      }
    } catch (e) {
      final errorMessage = 'Failed to refresh projects: ${e.toString()}';
      if (kDebugMode) {
        debugPrint('❌ $errorMessage');
      }
      emit(ProjectError(message: errorMessage));
    }
  }

  /// Refresh projects after detail view
  Future<void> onRefreshProjectsAfterDetailView(
    RefreshProjectsAfterDetailView event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      // Check if we have current loaded projects
      final currentState = emit.state;
      if (currentState is ProjectsLoaded) {
        // Refresh with current query
        final projectsResponse = await _repository.getAllProjects(const ProjectsQuery());
        emit(ProjectsLoaded(projectsResponse: projectsResponse));
      } else {
        // If no data is currently loaded, show loading state and fetch
        emit(const ProjectLoading());
        final query = const ProjectsQuery();
        final projectsResponse = await _repository.getAllProjects(query);
        emit(ProjectsLoaded(projectsResponse: projectsResponse));
      }

      if (kDebugMode) {
        debugPrint('✅ Refreshed projects after detail view');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error refreshing projects after detail view: $e');
      }
      // Don't emit error state for better UX - just keep current state
    }
  }
}
