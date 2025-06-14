import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../domain/entities/project.dart';
import '../domain/repositories/project_repository.dart';
import '../infrastructure/repositories/api_project_repository.dart';
import 'project_event.dart';
import 'project_state.dart';

@injectable
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc(@Named('api') this._projectRepository)
    : super(const ProjectInitial()) {
    on<ProjectLoadRequested>(_onProjectLoadRequested);
    on<ProjectLoadByStatusRequested>(_onProjectLoadByStatusRequested);
    on<ProjectSearchRequested>(_onProjectSearchRequested);
    on<ProjectCreateRequested>(_onProjectCreateRequested);
    on<ProjectUpdateRequested>(_onProjectUpdateRequested);
    on<ProjectDeleteRequested>(_onProjectDeleteRequested);
    on<ProjectRefreshRequested>(_onProjectRefreshRequested);
    on<ProjectLoadWithPaginationRequested>(
      _onProjectLoadWithPaginationRequested,
    );
    on<ProjectLoadMoreRequested>(_onProjectLoadMoreRequested);
  }

  final ProjectRepository _projectRepository;

  Future<void> _onProjectLoadRequested(
    ProjectLoadRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());

    try {
      final projects = await _projectRepository.getAllProjects();
      emit(ProjectLoaded(projects: projects));
    } catch (e) {
      emit(ProjectError(message: e.toString()));
    }
  }

  Future<void> _onProjectLoadByStatusRequested(
    ProjectLoadByStatusRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());

    try {
      final projects = await _projectRepository.getProjectsByStatus(
        event.status,
      );
      emit(ProjectLoaded(projects: projects));
    } catch (e) {
      emit(ProjectError(message: e.toString()));
    }
  }

  Future<void> _onProjectSearchRequested(
    ProjectSearchRequested event,
    Emitter<ProjectState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      add(const ProjectLoadRequested());
      return;
    }

    emit(const ProjectLoading());

    try {
      final projects = await _projectRepository.searchProjects(event.query);
      emit(ProjectLoaded(projects: projects));
    } catch (e) {
      emit(ProjectError(message: e.toString()));
    }
  }

  Future<void> _onProjectCreateRequested(
    ProjectCreateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _projectRepository.createProject(event.project);
      final projects = await _projectRepository.getAllProjects();
      emit(
        ProjectOperationSuccess(
          message: 'Project created successfully',
          projects: projects,
        ),
      );
    } catch (e) {
      final currentProjects = state is ProjectLoaded
          ? (state as ProjectLoaded).projects
          : <Project>[];
      emit(
        ProjectError(
          message: 'Failed to create project: ${e.toString()}',
          projects: currentProjects,
        ),
      );
    }
  }

  Future<void> _onProjectUpdateRequested(
    ProjectUpdateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _projectRepository.updateProject(event.project);
      final projects = await _projectRepository.getAllProjects();
      emit(
        ProjectOperationSuccess(
          message: 'Project updated successfully',
          projects: projects,
        ),
      );
    } catch (e) {
      final currentProjects = state is ProjectLoaded
          ? (state as ProjectLoaded).projects
          : <Project>[];
      emit(
        ProjectError(
          message: 'Failed to update project: ${e.toString()}',
          projects: currentProjects,
        ),
      );
    }
  }

  Future<void> _onProjectDeleteRequested(
    ProjectDeleteRequested event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      await _projectRepository.deleteProject(event.projectId);
      final projects = await _projectRepository.getAllProjects();
      emit(
        ProjectOperationSuccess(
          message: 'Project deleted successfully',
          projects: projects,
        ),
      );
    } catch (e) {
      final currentProjects = state is ProjectLoaded
          ? (state as ProjectLoaded).projects
          : <Project>[];
      emit(
        ProjectError(
          message: 'Failed to delete project: ${e.toString()}',
          projects: currentProjects,
        ),
      );
    }
  }

  Future<void> _onProjectRefreshRequested(
    ProjectRefreshRequested event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProjectLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    }

    try {
      final projects = await _projectRepository.getAllProjects();
      emit(ProjectLoaded(projects: projects, isRefreshing: false));
    } catch (e) {
      final currentProjects = currentState is ProjectLoaded
          ? currentState.projects
          : <Project>[];
      emit(ProjectError(message: e.toString(), projects: currentProjects));
    }
  }

  Future<void> _onProjectLoadWithPaginationRequested(
    ProjectLoadWithPaginationRequested event,
    Emitter<ProjectState> emit,
  ) async {
    // If refreshing, show loading state; otherwise maintain current state if exists
    if (event.refresh || state is! ProjectLoadedWithPagination) {
      emit(const ProjectLoading());
    } else if (state is ProjectLoadedWithPagination) {
      final currentState = state as ProjectLoadedWithPagination;
      emit(currentState.copyWith(isRefreshing: true));
    }

    try {
      // Check if repository supports pagination
      if (_projectRepository is ApiProjectRepository) {
        final apiRepository = _projectRepository as ApiProjectRepository;
        final projectData = await apiRepository.getProjectsWithPagination(
          pageNumber: event.pageNumber,
          pageSize: event.pageSize,
          managerId: event.managerId,
        );

        final projects = projectData.items
            .map((dto) => dto.toEntity())
            .toList();

        emit(
          ProjectLoadedWithPagination(
            projects: projects,
            currentPage: projectData.pageNumber,
            totalPages: projectData.totalPages,
            totalCount: projectData.totalCount,
            hasReachedMax: projectData.pageNumber >= projectData.totalPages,
            isRefreshing: false,
          ),
        );
      } else {
        // Fallback to regular loading for non-API repositories
        final projects = await _projectRepository.getAllProjects();
        emit(ProjectLoaded(projects: projects));
      }
    } catch (e) {
      final currentProjects = state is ProjectLoadedWithPagination
          ? (state as ProjectLoadedWithPagination).projects
          : <Project>[];
      emit(ProjectError(message: e.toString(), projects: currentProjects));
    }
  }

  Future<void> _onProjectLoadMoreRequested(
    ProjectLoadMoreRequested event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProjectLoadedWithPagination ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      if (_projectRepository is ApiProjectRepository) {
        final apiRepository = _projectRepository as ApiProjectRepository;
        final nextPage = currentState.currentPage + 1;

        final projectData = await apiRepository.getProjectsWithPagination(
          pageNumber: nextPage,
          pageSize: 10, // Default page size
        );

        final newProjects = projectData.items
            .map((dto) => dto.toEntity())
            .toList();
        final allProjects = [...currentState.projects, ...newProjects];

        emit(
          ProjectLoadedWithPagination(
            projects: allProjects,
            currentPage: projectData.pageNumber,
            totalPages: projectData.totalPages,
            totalCount: projectData.totalCount,
            hasReachedMax: projectData.pageNumber >= projectData.totalPages,
            isLoadingMore: false,
          ),
        );
      }
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
      // Could emit a separate error state or show snackbar
    }
  }
}
