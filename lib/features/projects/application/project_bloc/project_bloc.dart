import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/signalr_service.dart';
import '../../../../core/services/realtime_service.dart';
import '../../../../core/services/realtime_api_streams.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/project_api_models.dart';
import '../../domain/repositories/project_repository.dart';
import 'project_events.dart';
import 'project_states.dart';
import 'project_business_logic_handler.dart';

/// Refactored Project BLoC with separated concerns
///
/// This BLoC now delegates business logic to focused handler classes:
/// - ProjectBusinessLogicHandler: Core CRUD operations
/// - Real-time handling: Integrated but can be extracted later
///
/// Benefits:
/// - Cleaner separation of concerns
/// - Easier testing of individual components
/// - Better maintainability
/// - More focused responsibilities
@injectable
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc({required ProjectRepository repository, required SignalRService signalRService})
    : _repository = repository,
      _signalRService = signalRService,
      _businessLogicHandler = ProjectBusinessLogicHandler(repository: repository),
      super(const ProjectInitial()) {
    // Core business logic events
    on<LoadProjectsRequested>(_onLoadProjectsRequested);
    on<SearchProjectsRequested>(_onSearchProjectsRequested);
    on<LoadProjectDetailsRequested>(_onLoadProjectDetailsRequested);
    on<CreateProjectRequested>(_onCreateProjectRequested);
    on<UpdateProjectRequested>(_onUpdateProjectRequested);
    on<DeleteProjectRequested>(_onDeleteProjectRequested);
    on<LoadProjectStatisticsRequested>(_onLoadProjectStatisticsRequested);
    on<LoadProjectsByManagerRequested>(_onLoadProjectsByManagerRequested);
    on<RefreshProjectsWithCacheClear>(_onRefreshProjectsWithCacheClear);
    on<RefreshProjectsAfterDetailView>(_onRefreshProjectsAfterDetailView);

    // Real-time events
    on<RealTimeProjectUpdateReceived>(_onRealTimeProjectUpdateReceived);
    on<RealTimeProjectCreatedReceived>(_onRealTimeProjectCreatedReceived);
    on<RealTimeProjectDeletedReceived>(_onRealTimeProjectDeletedReceived);
    on<InitializeRealTimeConnection>(_onInitializeRealTimeConnection);
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
  final ProjectBusinessLogicHandler _businessLogicHandler;

  // Real-time subscriptions
  StreamSubscription<RealtimeEvent>? _realtimeSubscription;
  StreamSubscription<ProjectsResponse>? _liveUpdateSubscription;
  StreamSubscription<ProjectsResponse>? _realtimeApiSubscription;

  // ========== Business Logic Event Handlers ==========

  Future<void> _onLoadProjectsRequested(LoadProjectsRequested event, Emitter<ProjectState> emit) async {
    // Check if we already have loaded projects to prevent unnecessary loading state
    final bool skipLoadingState = event.skipLoadingState || (state is ProjectsLoaded && !event.forceRefresh);

    if (!skipLoadingState) {
      emit(const ProjectLoading());
    }

    try {
      final projectsResponse = await _repository.getAllProjects(event.query ?? const ProjectsQuery());
      emit(ProjectsLoaded(projectsResponse: projectsResponse));
    } catch (e) {
      emit(ProjectError(message: 'Failed to load projects', errorCode: e.toString()));
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
      emit(ProjectError(message: 'Failed to search projects', errorCode: e.toString()));
    }
  }

  Future<void> _onLoadProjectDetailsRequested(LoadProjectDetailsRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      if (kDebugMode) {
        debugPrint('🔍 [PROJECT_BLOC] Loading project details for ID: ${event.projectId}');
      }

      final project = await _repository.getProjectById(event.projectId);
      emit(ProjectDetailsLoaded(project: project));

      if (kDebugMode) {
        debugPrint('✅ [PROJECT_BLOC] Project details loaded successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [PROJECT_BLOC] Failed to load project details: $e');
      }
      emit(ProjectError(message: 'Failed to load project details', errorCode: e.toString()));
    }
  }

  Future<void> _onCreateProjectRequested(CreateProjectRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      final project = await _repository.createProject(event.projectData);
      emit(ProjectOperationSuccess(message: 'Project created successfully', project: project));
    } catch (e) {
      emit(ProjectError(message: 'Failed to create project', errorCode: e.toString()));
    }
  }

  Future<void> _onUpdateProjectRequested(UpdateProjectRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      final project = await _repository.updateProject(event.projectId, event.projectData);
      emit(ProjectOperationSuccess(message: 'Project updated successfully', project: project));
    } catch (e) {
      emit(ProjectError(message: 'Failed to update project', errorCode: e.toString()));
    }
  }

  Future<void> _onDeleteProjectRequested(DeleteProjectRequested event, Emitter<ProjectState> emit) async {
    emit(const ProjectLoading());

    try {
      await _repository.deleteProject(event.projectId);
      emit(ProjectOperationSuccess(message: 'Project deleted successfully', operationType: 'delete'));
    } catch (e) {
      emit(ProjectError(message: 'Failed to delete project', errorCode: e.toString()));
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
      emit(ProjectError(message: 'Failed to load project statistics', errorCode: e.toString()));
    }
  }

  Future<void> _onLoadProjectsByManagerRequested(
    LoadProjectsByManagerRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(const ProjectLoading());

    try {
      final query = ProjectsQuery(managerId: event.managerId);
      final projectsResponse = await _repository.getAllProjects(query);
      emit(ProjectsLoaded(projectsResponse: projectsResponse));
    } catch (e) {
      emit(ProjectError(message: 'Failed to load projects by manager', errorCode: e.toString()));
    }
  }

  Future<void> _onRefreshProjectsWithCacheClear(RefreshProjectsWithCacheClear event, Emitter<ProjectState> emit) async {
    if (!event.skipLoadingState) {
      emit(const ProjectLoading());
    }

    try {
      final query = event.query ?? const ProjectsQuery();
      final projectsResponse = await _repository.getAllProjects(query);
      emit(ProjectsLoaded(projectsResponse: projectsResponse));
    } catch (e) {
      emit(ProjectError(message: 'Failed to refresh projects', errorCode: e.toString()));
    }
  }

  Future<void> _onRefreshProjectsAfterDetailView(
    RefreshProjectsAfterDetailView event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      // Check if we have current loaded projects
      if (state is ProjectsLoaded) {
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
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error refreshing projects after detail view: $e');
      }
      // Don't emit error state for better UX - just keep current state
    }
  }

  // ========== Real-time Event Handlers ==========

  Future<void> _onRealTimeProjectUpdateReceived(RealTimeProjectUpdateReceived event, Emitter<ProjectState> emit) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      final projects = currentState.projectsResponse.items;
      final updatedProjects = projects.map((p) {
        return p.projectId == event.project.projectId ? event.project : p;
      }).toList();

      emit(
        ProjectsLoaded(
          projectsResponse: ProjectsResponse(
            items: updatedProjects,
            totalCount: currentState.projectsResponse.totalCount,
            pageNumber: currentState.projectsResponse.pageNumber,
            pageSize: currentState.projectsResponse.pageSize,
            totalPages: currentState.projectsResponse.totalPages,
            hasPreviousPage: currentState.projectsResponse.hasPreviousPage,
            hasNextPage: currentState.projectsResponse.hasNextPage,
            metadata: currentState.projectsResponse.metadata,
          ),
        ),
      );
    }
  }

  Future<void> _onRealTimeProjectCreatedReceived(
    RealTimeProjectCreatedReceived event,
    Emitter<ProjectState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      final projects = List<Project>.from(currentState.projectsResponse.projects)..add(event.project);

      emit(
        ProjectsLoaded(
          projectsResponse: currentState.projectsResponse.copyWith(
            projects: projects,
            totalCount: currentState.projectsResponse.totalCount + 1,
          ),
        ),
      );
    }
  }

  Future<void> _onRealTimeProjectDeletedReceived(
    RealTimeProjectDeletedReceived event,
    Emitter<ProjectState> emit,
  ) async {
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      final projects = currentState.projectsResponse.projects.where((p) => p.id != event.projectId).toList();

      emit(
        ProjectsLoaded(
          projectsResponse: currentState.projectsResponse.copyWith(
            projects: projects,
            totalCount: currentState.projectsResponse.totalCount - 1,
          ),
        ),
      );
    }
  }

  Future<void> _onInitializeRealTimeConnection(InitializeRealTimeConnection event, Emitter<ProjectState> emit) async {
    try {
      await _signalRService.startConnection();
      if (kDebugMode) {
        debugPrint('✅ Real-time connection initialized for projects');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to initialize real-time connection: $e');
      }
    }
  }

  Future<void> _onStartLiveProjectUpdates(StartLiveProjectUpdates event, Emitter<ProjectState> emit) async {
    try {
      await _liveUpdateSubscription?.cancel();

      final realTimeService = getIt<RealtimeService>();
      final query = event.query ?? const ProjectsQuery();

      _liveUpdateSubscription = realTimeService
          .getProjectStream(query: query, userRole: event.userRole)
          .listen(
            (projectsResponse) => add(LiveProjectUpdateReceived(projectsResponse: projectsResponse)),
            onError: (error) {
              if (kDebugMode) {
                debugPrint('❌ Live updates stream error: $error');
              }
            },
          );

      if (kDebugMode) {
        debugPrint('✅ Live project updates started');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to start live updates: $e');
      }
    }
  }

  Future<void> _onStopLiveProjectUpdates(StopLiveProjectUpdates event, Emitter<ProjectState> emit) async {
    await _liveUpdateSubscription?.cancel();
    _liveUpdateSubscription = null;

    if (kDebugMode) {
      debugPrint('✅ Live project updates stopped');
    }
  }

  Future<void> _onLiveProjectUpdateReceived(LiveProjectUpdateReceived event, Emitter<ProjectState> emit) async {
    // Don't emit if same data
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      if (currentState.projectsResponse == event.projectsResponse) {
        return;
      }
    }

    emit(ProjectsLoaded(projectsResponse: event.projectsResponse));
  }

  Future<void> _onStartProjectRealtimeUpdates(StartProjectRealtimeUpdates event, Emitter<ProjectState> emit) async {
    try {
      await _realtimeApiSubscription?.cancel();

      final realtimeApiStreams = getIt<RealtimeApiStreams>();
      final query = event.query ?? const ProjectsQuery();

      _realtimeApiSubscription = realtimeApiStreams
          .getProjectsStream(query: query, userRole: event.userRole)
          .listen(
            (projectsResponse) => add(ProjectRealtimeUpdateReceived(projectsResponse: projectsResponse)),
            onError: (error) {
              if (kDebugMode) {
                debugPrint('❌ Realtime API stream error: $error');
              }
            },
          );

      if (kDebugMode) {
        debugPrint('✅ Project realtime updates started');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to start realtime updates: $e');
      }
    }
  }

  Future<void> _onStopProjectRealtimeUpdates(StopProjectRealtimeUpdates event, Emitter<ProjectState> emit) async {
    await _realtimeApiSubscription?.cancel();
    _realtimeApiSubscription = null;

    if (kDebugMode) {
      debugPrint('✅ Project realtime updates stopped');
    }
  }

  Future<void> _onProjectRealtimeUpdateReceived(ProjectRealtimeUpdateReceived event, Emitter<ProjectState> emit) async {
    // Don't emit if same data
    if (state is ProjectsLoaded) {
      final currentState = state as ProjectsLoaded;
      if (currentState.projectsResponse == event.projectsResponse) {
        return;
      }
    }

    emit(ProjectsLoaded(projectsResponse: event.projectsResponse));
  }

  // ========== Real-time Event Handling ==========

  void _handleRealtimeEvent(RealtimeEvent event) {
    if (kDebugMode) {
      debugPrint('📡 Received real-time event: ${event.type}');
    }

    switch (event.type) {
      case RealtimeEventType.projectUpdated:
        if (event.data is Map<String, dynamic>) {
          try {
            final project = Project.fromJson(event.data as Map<String, dynamic>);
            add(RealTimeProjectUpdateReceived(project: project));
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ Error parsing project update: $e');
            }
          }
        }
        break;
      case RealtimeEventType.projectCreated:
        if (event.data is Map<String, dynamic>) {
          try {
            final project = Project.fromJson(event.data as Map<String, dynamic>);
            add(RealTimeProjectCreatedReceived(project: project));
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ Error parsing project creation: $e');
            }
          }
        }
        break;
      case RealtimeEventType.projectDeleted:
        if (event.data is String) {
          add(RealTimeProjectDeletedReceived(projectId: event.data as String));
        }
        break;
      default:
        if (kDebugMode) {
          debugPrint('🔄 Unhandled real-time event: ${event.type}');
        }
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
