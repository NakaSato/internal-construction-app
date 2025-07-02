import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../domain/entities/project_api_models.dart';
import '../domain/repositories/project_repository.dart';

/// Events for Enhanced Project BLoC
abstract class EnhancedProjectEvent extends Equatable {
  const EnhancedProjectEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjectsRequested extends EnhancedProjectEvent {
  const LoadProjectsRequested({this.query, this.userRole});

  final ProjectsQuery? query;
  final String? userRole;

  @override
  List<Object?> get props => [query, userRole];
}

class SearchProjectsRequested extends EnhancedProjectEvent {
  const SearchProjectsRequested({
    required this.searchTerm,
    this.filters,
    this.userRole,
  });

  final String searchTerm;
  final ProjectsQuery? filters;
  final String? userRole;

  @override
  List<Object?> get props => [searchTerm, filters, userRole];
}

class LoadProjectDetailsRequested extends EnhancedProjectEvent {
  const LoadProjectDetailsRequested({required this.projectId, this.userRole});

  final String projectId;
  final String? userRole;

  @override
  List<Object?> get props => [projectId, userRole];
}

class CreateProjectRequested extends EnhancedProjectEvent {
  const CreateProjectRequested({required this.projectData, this.userRole});

  final Map<String, dynamic> projectData;
  final String? userRole;

  @override
  List<Object?> get props => [projectData, userRole];
}

class UpdateProjectRequested extends EnhancedProjectEvent {
  const UpdateProjectRequested({
    required this.projectId,
    required this.projectData,
    this.userRole,
  });

  final String projectId;
  final Map<String, dynamic> projectData;
  final String? userRole;

  @override
  List<Object?> get props => [projectId, projectData, userRole];
}

class DeleteProjectRequested extends EnhancedProjectEvent {
  const DeleteProjectRequested({required this.projectId, this.userRole});

  final String projectId;
  final String? userRole;

  @override
  List<Object?> get props => [projectId, userRole];
}

class LoadProjectStatisticsRequested extends EnhancedProjectEvent {
  const LoadProjectStatisticsRequested({
    this.userRole,
    this.startDate,
    this.endDate,
  });

  final String? userRole;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [userRole, startDate, endDate];
}

class LoadProjectsByManagerRequested extends EnhancedProjectEvent {
  const LoadProjectsByManagerRequested({
    required this.managerId,
    this.userRole,
  });

  final String managerId;
  final String? userRole;

  @override
  List<Object?> get props => [managerId, userRole];
}

/// States for Enhanced Project BLoC
abstract class EnhancedProjectState extends Equatable {
  const EnhancedProjectState();

  @override
  List<Object?> get props => [];
}

class EnhancedProjectInitial extends EnhancedProjectState {
  const EnhancedProjectInitial();
}

class EnhancedProjectLoading extends EnhancedProjectState {
  const EnhancedProjectLoading();
}

class EnhancedProjectsLoaded extends EnhancedProjectState {
  const EnhancedProjectsLoaded({required this.projectsResponse});

  final ProjectsResponse projectsResponse;

  @override
  List<Object?> get props => [projectsResponse];
}

class EnhancedProjectDetailsLoaded extends EnhancedProjectState {
  const EnhancedProjectDetailsLoaded({required this.project});

  final EnhancedProject project;

  @override
  List<Object?> get props => [project];
}

class EnhancedProjectOperationSuccess extends EnhancedProjectState {
  const EnhancedProjectOperationSuccess({required this.message, this.project});

  final String message;
  final EnhancedProject? project;

  @override
  List<Object?> get props => [message, project];
}

class EnhancedProjectStatisticsLoaded extends EnhancedProjectState {
  const EnhancedProjectStatisticsLoaded({required this.statistics});

  final Map<String, dynamic> statistics;

  @override
  List<Object?> get props => [statistics];
}

class EnhancedProjectError extends EnhancedProjectState {
  const EnhancedProjectError({required this.message, this.details});

  final String message;
  final String? details;

  @override
  List<Object?> get props => [message, details];
}

/// Enhanced Project BLoC that uses the enhanced project management API
@injectable
class EnhancedProjectBloc
    extends Bloc<EnhancedProjectEvent, EnhancedProjectState> {
  EnhancedProjectBloc({required EnhancedProjectRepository repository})
    : _repository = repository,
      super(const EnhancedProjectInitial()) {
    on<LoadProjectsRequested>(_onLoadProjectsRequested);
    on<SearchProjectsRequested>(_onSearchProjectsRequested);
    on<LoadProjectDetailsRequested>(_onLoadProjectDetailsRequested);
    on<CreateProjectRequested>(_onCreateProjectRequested);
    on<UpdateProjectRequested>(_onUpdateProjectRequested);
    on<DeleteProjectRequested>(_onDeleteProjectRequested);
    on<LoadProjectStatisticsRequested>(_onLoadProjectStatisticsRequested);
    on<LoadProjectsByManagerRequested>(_onLoadProjectsByManagerRequested);
  }

  final EnhancedProjectRepository _repository;

  Future<void> _onLoadProjectsRequested(
    LoadProjectsRequested event,
    Emitter<EnhancedProjectState> emit,
  ) async {
    emit(const EnhancedProjectLoading());

    try {
      final projectsResponse = await _repository.getAllProjects(
        event.query ?? const ProjectsQuery(),
      );

      emit(EnhancedProjectsLoaded(projectsResponse: projectsResponse));
    } catch (e) {
      emit(
        EnhancedProjectError(
          message: 'Failed to load projects',
          details: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSearchProjectsRequested(
    SearchProjectsRequested event,
    Emitter<EnhancedProjectState> emit,
  ) async {
    emit(const EnhancedProjectLoading());

    try {
      final projectsResponse = await _repository.searchProjects(
        event.searchTerm,
        event.filters ?? const ProjectsQuery(),
      );

      emit(EnhancedProjectsLoaded(projectsResponse: projectsResponse));
    } catch (e) {
      emit(
        EnhancedProjectError(
          message: 'Failed to search projects',
          details: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadProjectDetailsRequested(
    LoadProjectDetailsRequested event,
    Emitter<EnhancedProjectState> emit,
  ) async {
    emit(const EnhancedProjectLoading());

    try {
      final project = await _repository.getProjectById(event.projectId);

      emit(EnhancedProjectDetailsLoaded(project: project));
    } catch (e) {
      emit(
        EnhancedProjectError(
          message: 'Failed to load project details',
          details: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateProjectRequested(
    CreateProjectRequested event,
    Emitter<EnhancedProjectState> emit,
  ) async {
    emit(const EnhancedProjectLoading());

    try {
      final project = await _repository.createProject(event.projectData);

      emit(
        EnhancedProjectOperationSuccess(
          message: 'Project created successfully',
          project: project,
        ),
      );
    } catch (e) {
      emit(
        EnhancedProjectError(
          message: 'Failed to create project',
          details: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateProjectRequested(
    UpdateProjectRequested event,
    Emitter<EnhancedProjectState> emit,
  ) async {
    emit(const EnhancedProjectLoading());

    try {
      final project = await _repository.updateProject(
        event.projectId,
        event.projectData,
      );

      emit(
        EnhancedProjectOperationSuccess(
          message: 'Project updated successfully',
          project: project,
        ),
      );
    } catch (e) {
      emit(
        EnhancedProjectError(
          message: 'Failed to update project',
          details: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteProjectRequested(
    DeleteProjectRequested event,
    Emitter<EnhancedProjectState> emit,
  ) async {
    emit(const EnhancedProjectLoading());

    try {
      await _repository.deleteProject(event.projectId);

      emit(
        const EnhancedProjectOperationSuccess(
          message: 'Project deleted successfully',
        ),
      );
    } catch (e) {
      emit(
        EnhancedProjectError(
          message: 'Failed to delete project',
          details: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadProjectStatisticsRequested(
    LoadProjectStatisticsRequested event,
    Emitter<EnhancedProjectState> emit,
  ) async {
    emit(const EnhancedProjectLoading());

    try {
      final statistics = await _repository.getProjectStatistics();

      emit(EnhancedProjectStatisticsLoaded(statistics: statistics));
    } catch (e) {
      emit(
        EnhancedProjectError(
          message: 'Failed to load project statistics',
          details: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadProjectsByManagerRequested(
    LoadProjectsByManagerRequested event,
    Emitter<EnhancedProjectState> emit,
  ) async {
    emit(const EnhancedProjectLoading());

    try {
      final projectsResponse = await _repository.getProjectsByManager(
        event.managerId,
        const ProjectsQuery(),
      );

      emit(EnhancedProjectsLoaded(projectsResponse: projectsResponse));
    } catch (e) {
      emit(
        EnhancedProjectError(
          message: 'Failed to load projects by manager',
          details: e.toString(),
        ),
      );
    }
  }
}
