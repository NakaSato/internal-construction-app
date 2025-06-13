import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../domain/entities/project.dart';
import '../domain/repositories/project_repository.dart';
import 'project_event.dart';
import 'project_state.dart';

@injectable
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc(@Named('mock') this._projectRepository)
    : super(const ProjectInitial()) {
    on<ProjectLoadRequested>(_onProjectLoadRequested);
    on<ProjectLoadByStatusRequested>(_onProjectLoadByStatusRequested);
    on<ProjectSearchRequested>(_onProjectSearchRequested);
    on<ProjectCreateRequested>(_onProjectCreateRequested);
    on<ProjectUpdateRequested>(_onProjectUpdateRequested);
    on<ProjectDeleteRequested>(_onProjectDeleteRequested);
    on<ProjectRefreshRequested>(_onProjectRefreshRequested);
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
}
