import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../domain/entities/project_api_models.dart';
import '../domain/repositories/project_repository.dart';
import '../../../core/services/realtime_service.dart';
import '../../../core/services/signalr_service.dart';
import '../../../core/services/realtime_api_streams.dart';
import '../../../core/di/injection.dart';

/// Events for Project BLoC
abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjectsRequested extends ProjectEvent {
  const LoadProjectsRequested({this.query, this.userRole});

  final ProjectsQuery? query;
  final String? userRole;

  @override
  List<Object?> get props => [query, userRole];
}

class SearchProjectsRequested extends ProjectEvent {
  const SearchProjectsRequested({required this.searchTerm, this.filters, this.userRole});

  final String searchTerm;
  final ProjectsQuery? filters;
  final String? userRole;

  @override
  List<Object?> get props => [searchTerm, filters, userRole];
}

class LoadProjectDetailsRequested extends ProjectEvent {
  const LoadProjectDetailsRequested({required this.projectId, this.userRole});

  final String projectId;
  final String? userRole;

  @override
  List<Object?> get props => [projectId, userRole];
}

class CreateProjectRequested extends ProjectEvent {
  const CreateProjectRequested({required this.projectData, this.userRole});

  final Map<String, dynamic> projectData;
  final String? userRole;

  @override
  List<Object?> get props => [projectData, userRole];
}

class UpdateProjectRequested extends ProjectEvent {
  const UpdateProjectRequested({required this.projectId, required this.projectData, this.userRole});

  final String projectId;
  final Map<String, dynamic> projectData;
  final String? userRole;

  @override
  List<Object?> get props => [projectId, projectData, userRole];
}

class DeleteProjectRequested extends ProjectEvent {
  const DeleteProjectRequested({required this.projectId, this.userRole});

  final String projectId;
  final String? userRole;

  @override
  List<Object?> get props => [projectId, userRole];
}

class LoadProjectStatisticsRequested extends ProjectEvent {
  const LoadProjectStatisticsRequested({this.userRole, this.startDate, this.endDate});

  final String? userRole;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<Object?> get props => [userRole, startDate, endDate];
}

class LoadProjectsByManagerRequested extends ProjectEvent {
  const LoadProjectsByManagerRequested({required this.managerId, this.userRole});

  final String managerId;
  final String? userRole;

  @override
  List<Object?> get props => [managerId, userRole];
}

class RealTimeProjectUpdateReceived extends ProjectEvent {
  const RealTimeProjectUpdateReceived({required this.project});

  final Project project;

  @override
  List<Object?> get props => [project];
}

class RealTimeProjectCreatedReceived extends ProjectEvent {
  const RealTimeProjectCreatedReceived({required this.project});

  final Project project;

  @override
  List<Object?> get props => [project];
}

class RealTimeProjectDeletedReceived extends ProjectEvent {
  const RealTimeProjectDeletedReceived({required this.projectId});

  final String projectId;

  @override
  List<Object?> get props => [projectId];
}

class InitializeRealTimeConnection extends ProjectEvent {
  const InitializeRealTimeConnection();
}

class RefreshProjectsWithCacheClear extends ProjectEvent {
  const RefreshProjectsWithCacheClear({this.query, this.userRole});

  final ProjectsQuery? query;
  final String? userRole;

  @override
  List<Object?> get props => [query, userRole];
}

class StartLiveProjectUpdates extends ProjectEvent {
  const StartLiveProjectUpdates({
    this.query,
    this.updateInterval = const Duration(seconds: 30),
    this.includeDeltas = false,
  });

  final ProjectsQuery? query;
  final Duration updateInterval;
  final bool includeDeltas;

  @override
  List<Object?> get props => [query, updateInterval, includeDeltas];
}

class StopLiveProjectUpdates extends ProjectEvent {
  const StopLiveProjectUpdates();
}

class LiveProjectUpdateReceived extends ProjectEvent {
  const LiveProjectUpdateReceived({required this.projectsResponse});

  final ProjectsResponse projectsResponse;

  @override
  List<Object?> get props => [projectsResponse];
}

// Real-time update events
class ProjectRealtimeUpdateReceived extends ProjectEvent {
  const ProjectRealtimeUpdateReceived({required this.update});

  final RealtimeProjectUpdate update;

  @override
  List<Object?> get props => [update];
}

class StartProjectRealtimeUpdates extends ProjectEvent {
  const StartProjectRealtimeUpdates({this.projectId});

  final String? projectId;

  @override
  List<Object?> get props => [projectId];
}

class StopProjectRealtimeUpdates extends ProjectEvent {
  const StopProjectRealtimeUpdates();
}

/// States for Project BLoC
abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {
  const ProjectInitial();
}

class ProjectLoading extends ProjectState {
  const ProjectLoading();
}

class ProjectsLoaded extends ProjectState {
  const ProjectsLoaded({required this.projectsResponse});

  final ProjectsResponse projectsResponse;

  @override
  List<Object?> get props => [projectsResponse];
}

class ProjectDetailsLoaded extends ProjectState {
  const ProjectDetailsLoaded({required this.project});

  final Project project;

  @override
  List<Object?> get props => [project];
}

class ProjectOperationSuccess extends ProjectState {
  const ProjectOperationSuccess({required this.message, this.project});

  final String message;
  final Project? project;

  @override
  List<Object?> get props => [message, project];
}

class ProjectStatisticsLoaded extends ProjectState {
  const ProjectStatisticsLoaded({required this.statistics});

  final Map<String, dynamic> statistics;

  @override
  List<Object?> get props => [statistics];
}

class ProjectError extends ProjectState {
  const ProjectError({required this.message, this.details});

  final String message;
  final String? details;

  @override
  List<Object?> get props => [message, details];
}

/// Project BLoC that uses the project management API
@LazySingleton()
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc({required ProjectRepository repository, required SignalRService signalRService})
    : _repository = repository,
      _signalRService = signalRService,
      super(const ProjectInitial()) {
    on<LoadProjectsRequested>(_onLoadProjectsRequested);
    on<SearchProjectsRequested>(_onSearchProjectsRequested);
    on<LoadProjectDetailsRequested>(_onLoadProjectDetailsRequested);
    on<CreateProjectRequested>(_onCreateProjectRequested);
    on<UpdateProjectRequested>(_onUpdateProjectRequested);
    on<DeleteProjectRequested>(_onDeleteProjectRequested);
    on<LoadProjectStatisticsRequested>(_onLoadProjectStatisticsRequested);
    on<LoadProjectsByManagerRequested>(_onLoadProjectsByManagerRequested);
    on<RealTimeProjectUpdateReceived>(_onRealTimeProjectUpdateReceived);
    on<RealTimeProjectCreatedReceived>(_onRealTimeProjectCreatedReceived);
    on<RealTimeProjectDeletedReceived>(_onRealTimeProjectDeletedReceived);
    on<InitializeRealTimeConnection>(_onInitializeRealTimeConnection);
    on<RefreshProjectsWithCacheClear>(_onRefreshProjectsWithCacheClear);
    on<StartLiveProjectUpdates>(_onStartLiveProjectUpdates);
    on<StopLiveProjectUpdates>(_onStopLiveProjectUpdates);
    on<LiveProjectUpdateReceived>(_onLiveProjectUpdateReceived);
    on<ProjectRealtimeUpdateReceived>(_onProjectRealtimeUpdateReceived);
    on<StartProjectRealtimeUpdates>(_onStartProjectRealtimeUpdates);
    on<StopProjectRealtimeUpdates>(_onStopProjectRealtimeUpdates);

    // Listen to real-time events
    _realtimeSubscription = _signalRService.eventStream.listen(_handleRealtimeEvent);
  }

  final ProjectRepository _repository;
  final SignalRService _signalRService;
  StreamSubscription<RealtimeEvent>? _realtimeSubscription;
  StreamSubscription<ProjectsResponse>? _liveUpdateSubscription;

  Future<void> _onLoadProjectsRequested(LoadProjectsRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      final projectsResponse = await _repository.getAllProjects(event.query ?? const ProjectsQuery());

      emit(ProjectsLoaded(projectsResponse: projectsResponse));
    } catch (e) {
      emit(ProjectError(message: 'Failed to load projects', details: e.toString()));
    }
  }

  Future<void> _onSearchProjectsRequested(SearchProjectsRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      final projectsResponse = await _repository.searchProjects(
        event.searchTerm,
        event.filters ?? const ProjectsQuery(),
      );

      emit(ProjectsLoaded(projectsResponse: projectsResponse));
    } catch (e) {
      emit(ProjectError(message: 'Failed to search projects', details: e.toString()));
    }
  }

  Future<void> _onLoadProjectDetailsRequested(LoadProjectDetailsRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      if (kDebugMode) {
        debugPrint('🔍 [PROJECT_BLOC] Loading project details for ID: ${event.projectId}');
      }

      final project = await _repository.getProjectById(event.projectId);

      if (kDebugMode) {
        debugPrint('✅ [PROJECT_BLOC] Successfully loaded project: ${project.projectName}');
      }

      emit(ProjectDetailsLoaded(project: project));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [PROJECT_BLOC] Failed to load project details for ID: ${event.projectId}');
        debugPrint('❌ [PROJECT_BLOC] Error: $e');
      }

      String errorMessage = 'Failed to load project details';

      // Provide more specific error messages based on error type
      if (e is ArgumentError) {
        errorMessage = 'Invalid project ID: ${e.message}';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Project not found';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('timeout') || e.toString().contains('network')) {
        errorMessage = 'Network connection failed';
      }

      emit(ProjectError(message: errorMessage, details: e.toString()));
    }
  }

  Future<void> _onCreateProjectRequested(CreateProjectRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      final project = await _repository.createProject(event.projectData);

      emit(ProjectOperationSuccess(message: 'Project created successfully', project: project));
    } catch (e) {
      emit(ProjectError(message: 'Failed to create project', details: e.toString()));
    }
  }

  Future<void> _onUpdateProjectRequested(UpdateProjectRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      final project = await _repository.updateProject(event.projectId, event.projectData);

      emit(ProjectOperationSuccess(message: 'Project updated successfully', project: project));
    } catch (e) {
      emit(ProjectError(message: 'Failed to update project', details: e.toString()));
    }
  }

  Future<void> _onDeleteProjectRequested(DeleteProjectRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      await _repository.deleteProject(event.projectId);

      emit(const ProjectOperationSuccess(message: 'Project deleted successfully'));
    } catch (e) {
      emit(ProjectError(message: 'Failed to delete project', details: e.toString()));
    }
  }

  Future<void> _onLoadProjectStatisticsRequested(
    LoadProjectStatisticsRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());

    try {
      final statistics = await _repository.getProjectStatistics();

      emit(ProjectStatisticsLoaded(statistics: statistics));
    } catch (e) {
      emit(ProjectError(message: 'Failed to load project statistics', details: e.toString()));
    }
  }

  Future<void> _onLoadProjectsByManagerRequested(
    LoadProjectsByManagerRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());

    try {
      final projectsResponse = await _repository.getProjectsByManager(event.managerId, const ProjectsQuery());

      emit(ProjectsLoaded(projectsResponse: projectsResponse));
    } catch (e) {
      emit(ProjectError(message: 'Failed to load projects by manager', details: e.toString()));
    }
  }

  /// Handle real-time event stream
  void _handleRealtimeEvent(RealtimeEvent event) {
    switch (event.type) {
      case RealtimeEventType.projectUpdated:
        final projectData = event.data['project'] as Map<String, dynamic>?;
        if (projectData != null) {
          try {
            final project = Project.fromJson(projectData);
            add(RealTimeProjectUpdateReceived(project: project));
          } catch (e) {
            // Log error but don't break the app
            print('Error parsing real-time project update: $e');
          }
        }
        break;
      case RealtimeEventType.projectCreated:
        final projectData = event.data['project'] as Map<String, dynamic>?;
        if (projectData != null) {
          try {
            final project = Project.fromJson(projectData);
            add(RealTimeProjectCreatedReceived(project: project));
          } catch (e) {
            print('Error parsing real-time project creation: $e');
          }
        }
        break;
      case RealtimeEventType.projectDeleted:
        final projectId = event.data['projectId'] as String?;
        if (projectId != null) {
          add(RealTimeProjectDeletedReceived(projectId: projectId));
        }
        break;
      default:
        // Handle other event types if needed
        break;
    }
  }

  /// Initialize real-time connection
  Future<void> _onInitializeRealTimeConnection(InitializeRealTimeConnection event, Emitter<ProjectState> emit) async {
    try {
      await _signalRService.connect();
      // SignalR automatically handles event subscription based on user permissions
    } catch (e) {
      // Log error but don't break the app
      print('Failed to initialize real-time connection: $e');
    }
  }

  /// Handle real-time project update
  Future<void> _onRealTimeProjectUpdateReceived(RealTimeProjectUpdateReceived event, Emitter<ProjectState> emit) async {
    final currentState = state;

    // Update the state if we're currently showing projects
    if (currentState is ProjectsLoaded) {
      final updatedProjects = currentState.projectsResponse.items.map((project) {
        return project.projectId == event.project.projectId ? event.project : project;
      }).toList();

      final updatedResponse = ProjectsResponse(
        items: updatedProjects,
        totalCount: currentState.projectsResponse.totalCount,
        totalPages: currentState.projectsResponse.totalPages,
        pageNumber: currentState.projectsResponse.pageNumber,
        pageSize: currentState.projectsResponse.pageSize,
        hasNextPage: currentState.projectsResponse.hasNextPage,
        hasPreviousPage: currentState.projectsResponse.hasPreviousPage,
        metadata: currentState.projectsResponse.metadata,
      );

      emit(ProjectsLoaded(projectsResponse: updatedResponse));
    }

    // Update if showing project details
    if (currentState is ProjectDetailsLoaded && currentState.project.projectId == event.project.projectId) {
      emit(ProjectDetailsLoaded(project: event.project));
    }
  }

  /// Handle real-time project creation
  Future<void> _onRealTimeProjectCreatedReceived(
    RealTimeProjectCreatedReceived event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;

    // Add to the list if we're currently showing projects
    if (currentState is ProjectsLoaded) {
      final updatedProjects = [event.project, ...currentState.projectsResponse.items];

      final updatedResponse = ProjectsResponse(
        items: updatedProjects,
        totalCount: currentState.projectsResponse.totalCount + 1,
        totalPages: currentState.projectsResponse.totalPages,
        pageNumber: currentState.projectsResponse.pageNumber,
        pageSize: currentState.projectsResponse.pageSize,
        hasNextPage: currentState.projectsResponse.hasNextPage,
        hasPreviousPage: currentState.projectsResponse.hasPreviousPage,
        metadata: currentState.projectsResponse.metadata,
      );

      emit(ProjectsLoaded(projectsResponse: updatedResponse));
    }
  }

  /// Handle real-time project deletion
  Future<void> _onRealTimeProjectDeletedReceived(
    RealTimeProjectDeletedReceived event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;

    // Remove from the list if we're currently showing projects
    if (currentState is ProjectsLoaded) {
      final updatedProjects = currentState.projectsResponse.items
          .where((project) => project.projectId != event.projectId)
          .toList();

      final updatedResponse = ProjectsResponse(
        items: updatedProjects,
        totalCount: currentState.projectsResponse.totalCount - 1,
        totalPages: currentState.projectsResponse.totalPages,
        pageNumber: currentState.projectsResponse.pageNumber,
        pageSize: currentState.projectsResponse.pageSize,
        hasNextPage: currentState.projectsResponse.hasNextPage,
        hasPreviousPage: currentState.projectsResponse.hasPreviousPage,
        metadata: currentState.projectsResponse.metadata,
      );

      emit(ProjectsLoaded(projectsResponse: updatedResponse));
    }

    // Navigate back if we're showing deleted project details
    if (currentState is ProjectDetailsLoaded && currentState.project.projectId == event.projectId) {
      emit(
        const ProjectError(
          message: 'This project has been deleted',
          details: 'The project you were viewing has been deleted by another user.',
        ),
      );
    }
  }

  Future<void> _onRefreshProjectsWithCacheClear(RefreshProjectsWithCacheClear event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      // Clear the cache if needed
      await _repository.clearProjectCache();

      // Reload the projects
      final projectsResponse = await _repository.getAllProjects(event.query ?? const ProjectsQuery());

      emit(ProjectsLoaded(projectsResponse: projectsResponse));
    } catch (e) {
      emit(ProjectError(message: 'Failed to refresh projects', details: e.toString()));
    }
  }

  Future<void> _onStartLiveProjectUpdates(StartLiveProjectUpdates event, Emitter<ProjectState> emit) async {
    if (kDebugMode) {
      debugPrint('🔴 Starting live project updates via repository stream');
    }

    try {
      // Cancel any existing live update subscription
      await _liveUpdateSubscription?.cancel();

      // Start new live update stream from repository
      _liveUpdateSubscription = _repository
          .getLiveProjectUpdates(
            event.query ?? const ProjectsQuery(),
            updateInterval: event.updateInterval,
            includeDeltas: event.includeDeltas,
          )
          .listen(
            (projectsResponse) {
              if (!isClosed) {
                add(LiveProjectUpdateReceived(projectsResponse: projectsResponse));
              }
            },
            onError: (error) {
              if (!isClosed) {
                add(
                  LiveProjectUpdateReceived(
                    projectsResponse: ProjectsResponse(
                      items: [],
                      totalCount: 0,
                      totalPages: 0,
                      pageNumber: 1,
                      pageSize: 20,
                      hasNextPage: false,
                      hasPreviousPage: false,
                      metadata: {},
                    ),
                  ),
                );
              }
            },
          );

      if (kDebugMode) {
        debugPrint('✅ Live project updates started successfully');
      }
    } catch (e) {
      emit(ProjectError(message: 'Failed to start live project updates', details: e.toString()));
    }
  }

  Future<void> _onStopLiveProjectUpdates(StopLiveProjectUpdates event, Emitter<ProjectState> emit) async {
    if (kDebugMode) {
      debugPrint('🛑 Stopping live project updates');
    }

    try {
      // Cancel live update subscription
      await _liveUpdateSubscription?.cancel();
      _liveUpdateSubscription = null;

      if (kDebugMode) {
        debugPrint('✅ Live project updates stopped successfully');
      }
    } catch (e) {
      emit(ProjectError(message: 'Failed to stop live project updates', details: e.toString()));
    }
  }

  Future<void> _onLiveProjectUpdateReceived(LiveProjectUpdateReceived event, Emitter<ProjectState> emit) async {
    // Emit the updated project data without showing loading state
    // This maintains smooth real-time updates
    emit(ProjectsLoaded(projectsResponse: event.projectsResponse));
  }

  // Real-time API update handlers
  StreamSubscription<RealtimeProjectUpdate>? _realtimeApiSubscription;

  Future<void> _onStartProjectRealtimeUpdates(StartProjectRealtimeUpdates event, Emitter<ProjectState> emit) async {
    try {
      final realtimeStreams = getIt<RealtimeApiStreams>();
      await realtimeStreams.initialize();

      _realtimeApiSubscription = realtimeStreams.projectsStream.listen(
        (update) => add(ProjectRealtimeUpdateReceived(update: update)),
        onError: (error) {
          if (kDebugMode) {
            debugPrint('❌ Real-time project updates error: $error');
          }
        },
      );

      if (kDebugMode) {
        debugPrint('✅ Started real-time project updates');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to start real-time project updates: $e');
      }
    }
  }

  Future<void> _onStopProjectRealtimeUpdates(StopProjectRealtimeUpdates event, Emitter<ProjectState> emit) async {
    _realtimeApiSubscription?.cancel();
    _realtimeApiSubscription = null;

    if (kDebugMode) {
      debugPrint('🛑 Stopped real-time project updates');
    }
  }

  Future<void> _onProjectRealtimeUpdateReceived(ProjectRealtimeUpdateReceived event, Emitter<ProjectState> emit) async {
    final update = event.update;
    final currentState = state;

    if (kDebugMode) {
      debugPrint('📡 Received real-time project update: ${update.type} for ${update.projectId}');
    }

    switch (update.type) {
      case 'update':
        if (update.project != null) {
          // Update project list if currently loaded
          if (currentState is ProjectsLoaded) {
            final updatedProjects = currentState.projectsResponse.items.map((project) {
              return project.projectId == update.projectId ? update.project! : project;
            }).toList();

            final updatedResponse = ProjectsResponse(
              items: updatedProjects,
              totalCount: currentState.projectsResponse.totalCount,
              totalPages: currentState.projectsResponse.totalPages,
              pageNumber: currentState.projectsResponse.pageNumber,
              pageSize: currentState.projectsResponse.pageSize,
              hasNextPage: currentState.projectsResponse.hasNextPage,
              hasPreviousPage: currentState.projectsResponse.hasPreviousPage,
              metadata: currentState.projectsResponse.metadata,
            );

            emit(ProjectsLoaded(projectsResponse: updatedResponse));
          }

          // Update project details if currently showing this project
          if (currentState is ProjectDetailsLoaded && currentState.project.projectId == update.projectId) {
            emit(ProjectDetailsLoaded(project: update.project!));
          }
        }
        break;

      case 'create':
        if (update.project != null && currentState is ProjectsLoaded) {
          final updatedProjects = List<Project>.from(currentState.projectsResponse.items)..insert(0, update.project!);

          final updatedResponse = ProjectsResponse(
            items: updatedProjects,
            totalCount: currentState.projectsResponse.totalCount + 1,
            totalPages: currentState.projectsResponse.totalPages,
            pageNumber: currentState.projectsResponse.pageNumber,
            pageSize: currentState.projectsResponse.pageSize,
            hasNextPage: currentState.projectsResponse.hasNextPage,
            hasPreviousPage: currentState.projectsResponse.hasPreviousPage,
            metadata: currentState.projectsResponse.metadata,
          );

          emit(ProjectsLoaded(projectsResponse: updatedResponse));
        }
        break;

      case 'delete':
        if (currentState is ProjectsLoaded) {
          final updatedProjects = currentState.projectsResponse.items
              .where((project) => project.projectId != update.projectId)
              .toList();

          final updatedResponse = ProjectsResponse(
            items: updatedProjects,
            totalCount: currentState.projectsResponse.totalCount - 1,
            totalPages: currentState.projectsResponse.totalPages,
            pageNumber: currentState.projectsResponse.pageNumber,
            pageSize: currentState.projectsResponse.pageSize,
            hasNextPage: currentState.projectsResponse.hasNextPage,
            hasPreviousPage: currentState.projectsResponse.hasPreviousPage,
            metadata: currentState.projectsResponse.metadata,
          );

          emit(ProjectsLoaded(projectsResponse: updatedResponse));
        }

        // If currently viewing deleted project, navigate away
        if (currentState is ProjectDetailsLoaded && currentState.project.projectId == update.projectId) {
          emit(const ProjectError(message: 'Project was deleted'));
        }
        break;
    }
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();
    _realtimeApiSubscription?.cancel();
    _liveUpdateSubscription?.cancel();
    _signalRService.dispose();
    return super.close();
  }
}
