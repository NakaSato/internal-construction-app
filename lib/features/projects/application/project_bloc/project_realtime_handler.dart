import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/signalr_service.dart';
import '../../../../core/services/realtime_service.dart';
import '../../../../core/services/realtime_api_streams.dart';
import '../../domain/entities/project_api_models.dart';
import '../../domain/repositories/project_repository.dart';
import 'project_events.dart';
import 'project_states.dart';

/// Handles real-time project updates and WebSocket connections
class ProjectRealtimeHandler {
  ProjectRealtimeHandler({required ProjectRepository repository, required SignalRService signalRService})
    : _repository = repository,
      _signalRService = signalRService;

  final ProjectRepository _repository;
  final SignalRService _signalRService;

  StreamSubscription<RealtimeEvent>? _realtimeSubscription;
  StreamSubscription<ProjectsResponse>? _liveUpdateSubscription;
  StreamSubscription<ProjectsResponse>? _realtimeApiSubscription;

  /// Initialize real-time connection
  Future<void> onInitializeRealTimeConnection(InitializeRealTimeConnection event, Emitter<ProjectState> emit) async {
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

  /// Handle real-time project updates
  Future<void> onRealTimeProjectUpdateReceived(RealTimeProjectUpdateReceived event, Emitter<ProjectState> emit) async {
    final currentState = emit.state;
    if (currentState is ProjectsLoaded) {
      final projects = currentState.projectsResponse.projects;
      final updatedProjects = projects.map((p) {
        return p.id == event.project.id ? event.project : p;
      }).toList();

      emit(ProjectsLoaded(projectsResponse: currentState.projectsResponse.copyWith(projects: updatedProjects)));
    }
  }

  /// Handle real-time project creation
  Future<void> onRealTimeProjectCreatedReceived(
    RealTimeProjectCreatedReceived event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = emit.state;
    if (currentState is ProjectsLoaded) {
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

  /// Handle real-time project deletion
  Future<void> onRealTimeProjectDeletedReceived(
    RealTimeProjectDeletedReceived event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = emit.state;
    if (currentState is ProjectsLoaded) {
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

  /// Start live project updates
  Future<void> onStartLiveProjectUpdates(StartLiveProjectUpdates event, Emitter<ProjectState> emit) async {
    try {
      await _stopLiveUpdates();

      final realTimeService = RealtimeService();
      final query = event.query ?? const ProjectsQuery();

      _liveUpdateSubscription = realTimeService
          .getProjectStream(query: query, userRole: event.userRole)
          .listen(
            (projectsResponse) {
              // Don't emit if same data
              final currentState = emit.state;
              if (currentState is ProjectsLoaded && currentState.projectsResponse == projectsResponse) {
                return;
              }

              emit(ProjectsLoaded(projectsResponse: projectsResponse));
            },
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

  /// Stop live project updates
  Future<void> onStopLiveProjectUpdates(StopLiveProjectUpdates event, Emitter<ProjectState> emit) async {
    await _stopLiveUpdates();

    if (kDebugMode) {
      debugPrint('✅ Live project updates stopped');
    }
  }

  /// Handle live project update received
  Future<void> onLiveProjectUpdateReceived(LiveProjectUpdateReceived event, Emitter<ProjectState> emit) async {
    // Don't emit if same data
    final currentState = emit.state;
    if (currentState is ProjectsLoaded && currentState.projectsResponse == event.projectsResponse) {
      return;
    }

    emit(ProjectsLoaded(projectsResponse: event.projectsResponse));
  }

  /// Start project realtime updates
  Future<void> onStartProjectRealtimeUpdates(StartProjectRealtimeUpdates event, Emitter<ProjectState> emit) async {
    try {
      await _stopRealtimeApiUpdates();

      final realtimeApiStreams = RealtimeApiStreams();
      final query = event.query ?? const ProjectsQuery();

      _realtimeApiSubscription = realtimeApiStreams
          .getProjectsStream(query: query, userRole: event.userRole)
          .listen(
            (projectsResponse) {
              // Don't emit if same data
              final currentState = emit.state;
              if (currentState is ProjectsLoaded && currentState.projectsResponse == projectsResponse) {
                return;
              }

              emit(ProjectsLoaded(projectsResponse: projectsResponse));
            },
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

  /// Stop project realtime updates
  Future<void> onStopProjectRealtimeUpdates(StopProjectRealtimeUpdates event, Emitter<ProjectState> emit) async {
    await _stopRealtimeApiUpdates();

    if (kDebugMode) {
      debugPrint('✅ Project realtime updates stopped');
    }
  }

  /// Handle project realtime update received
  Future<void> onProjectRealtimeUpdateReceived(ProjectRealtimeUpdateReceived event, Emitter<ProjectState> emit) async {
    // Don't emit if same data
    final currentState = emit.state;
    if (currentState is ProjectsLoaded && currentState.projectsResponse == event.projectsResponse) {
      return;
    }

    emit(ProjectsLoaded(projectsResponse: event.projectsResponse));
  }

  /// Handle real-time events from SignalR
  void handleRealtimeEvent(RealtimeEvent event) {
    if (kDebugMode) {
      debugPrint('📡 Received real-time event: ${event.type}');
    }

    switch (event.type) {
      case 'ProjectUpdated':
        if (event.data is Map<String, dynamic>) {
          try {
            final project = Project.fromJson(event.data as Map<String, dynamic>);
            // Emit event to bloc
            // Note: This would need to be connected to the bloc's event stream
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ Error parsing project update: $e');
            }
          }
        }
        break;
      case 'ProjectCreated':
        if (event.data is Map<String, dynamic>) {
          try {
            final project = Project.fromJson(event.data as Map<String, dynamic>);
            // Emit event to bloc
            // Note: This would need to be connected to the bloc's event stream
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ Error parsing project creation: $e');
            }
          }
        }
        break;
      case 'ProjectDeleted':
        if (event.data is String) {
          // Emit event to bloc
          // Note: This would need to be connected to the bloc's event stream
        }
        break;
      default:
        if (kDebugMode) {
          debugPrint('🔄 Unhandled real-time event: ${event.type}');
        }
    }
  }

  /// Stop live updates subscription
  Future<void> _stopLiveUpdates() async {
    await _liveUpdateSubscription?.cancel();
    _liveUpdateSubscription = null;
  }

  /// Stop realtime API updates subscription
  Future<void> _stopRealtimeApiUpdates() async {
    await _realtimeApiSubscription?.cancel();
    _realtimeApiSubscription = null;
  }

  /// Initialize real-time event listening
  void initializeRealtimeEventListener() {
    _realtimeSubscription = _signalRService.eventStream.listen(handleRealtimeEvent);
  }

  /// Dispose all subscriptions
  Future<void> dispose() async {
    await _realtimeSubscription?.cancel();
    await _liveUpdateSubscription?.cancel();
    await _realtimeApiSubscription?.cancel();
    _signalRService.dispose();
  }
}
