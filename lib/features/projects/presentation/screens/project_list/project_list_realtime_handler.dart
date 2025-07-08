import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/services/universal_realtime_handler.dart';
import '../../../../../core/services/realtime_api_streams.dart';
import '../../../../../core/services/realtime_service.dart';
import '../../../application/project_bloc.dart';
import '../../../domain/entities/project_api_models.dart';

/// Handles real-time updates for the project list screen
///
/// This class manages:
/// - Real-time WebSocket connections
/// - Project, task, and daily report event handlers
/// - Live API update streams
/// - Real-time connection status
/// - User-friendly notification system
class ProjectListRealtimeHandler {
  final BuildContext context;
  final VoidCallback onSilentRefresh;
  final void Function(RealtimeProjectUpdate) onShowNotification;
  final void Function(bool) onConnectionStatusChanged;

  late final UniversalRealtimeHandler _realtimeHandler;
  late final RealtimeApiStreams _realtimeApiStreams;
  StreamSubscription<RealtimeProjectUpdate>? _realtimeApiSubscription;
  bool _isConnected = false;

  ProjectListRealtimeHandler({
    required this.context,
    required this.onSilentRefresh,
    required this.onShowNotification,
    required this.onConnectionStatusChanged,
  });

  /// Initialize real-time updates
  Future<void> initialize() async {
    await _initializeUniversalRealtimeHandler();
    await _initializeRealtimeApiStreams();
  }

  /// Initialize universal real-time handler for WebSocket events
  Future<void> _initializeUniversalRealtimeHandler() async {
    try {
      _realtimeHandler = getIt<UniversalRealtimeHandler>();

      // Initialize the handler if not already connected
      if (!_realtimeHandler.isConnected) {
        await _realtimeHandler.initialize();
      }

      _registerEventHandlers();
      debugPrint('✅ Project List: Universal real-time handler initialized');
    } catch (e) {
      debugPrint('❌ Project List: Failed to initialize universal real-time handler: $e');
    }
  }

  /// Register event handlers for different types of real-time events
  void _registerEventHandlers() {
    // Register handlers for project-related events
    _realtimeHandler.registerProjectHandler(_handleProjectEvent);

    // Register handlers for task-related events (affects project status)
    _realtimeHandler.registerTaskHandler(_handleTaskEvent);

    // Register handlers for daily report events (affects project status)
    _realtimeHandler.registerDailyReportHandler(_handleDailyReportEvent);
  }

  /// Handle project-related real-time events
  void _handleProjectEvent(RealtimeEvent event) {
    debugPrint('📡 Real-time project event: ${event.type.name}');

    final projectData = event.data;

    switch (event.type.name) {
      case 'projectCreated':
        _handleProjectCreated(projectData);
        break;
      case 'projectUpdated':
        _handleProjectUpdated(projectData);
        break;
      case 'projectDeleted':
        _handleProjectDeleted(projectData);
        break;
      case 'projectStatusChanged':
        _handleProjectStatusChanged();
        break;
      default:
        debugPrint('Unknown project event type: ${event.type.name}');
        onSilentRefresh();
    }
  }

  /// Handle project creation events
  void _handleProjectCreated(Map<String, dynamic> projectData) {
    try {
      final project = Project.fromJson(projectData);
      context.read<ProjectBloc>().add(RealTimeProjectCreatedReceived(project: project));
    } catch (e) {
      debugPrint('❌ Error parsing project created event: $e');
      onSilentRefresh();
    }
  }

  /// Handle project update events
  void _handleProjectUpdated(Map<String, dynamic> projectData) {
    try {
      final project = Project.fromJson(projectData);
      context.read<ProjectBloc>().add(RealTimeProjectUpdateReceived(project: project));
    } catch (e) {
      debugPrint('❌ Error parsing project updated event: $e');
      onSilentRefresh();
    }
  }

  /// Handle project deletion events
  void _handleProjectDeleted(Map<String, dynamic> projectData) {
    final projectId = projectData['id'] as String? ?? projectData['projectId'] as String?;

    if (projectId != null) {
      context.read<ProjectBloc>().add(RealTimeProjectDeletedReceived(projectId: projectId));
    } else {
      debugPrint('No project ID in delete event');
      onSilentRefresh();
    }
  }

  /// Handle project status change events
  void _handleProjectStatusChanged() {
    // For status changes, refresh to get the latest data
    onSilentRefresh();
  }

  /// Handle task-related events that may affect project status
  void _handleTaskEvent(RealtimeEvent event) {
    debugPrint('📡 Real-time task event: ${event.type.name}');
    // Refresh project list when tasks are updated (may affect project progress)
    onSilentRefresh();
  }

  /// Handle daily report events that may affect project status
  void _handleDailyReportEvent(RealtimeEvent event) {
    debugPrint('📡 Real-time daily report event: ${event.type.name}');
    // Refresh project list when daily reports are updated
    onSilentRefresh();
  }

  /// Initialize enhanced real-time API streams
  Future<void> _initializeRealtimeApiStreams() async {
    try {
      _realtimeApiStreams = getIt<RealtimeApiStreams>();

      // Initialize connection
      await _realtimeApiStreams.initialize();

      _isConnected = _realtimeApiStreams.isConnected;
      onConnectionStatusChanged(_isConnected);

      // Start enhanced real-time updates through BLoC
      context.read<ProjectBloc>().add(const StartProjectRealtimeUpdates());

      // Subscribe for UI feedback and live connection status
      _realtimeApiSubscription = _realtimeApiStreams.projectsStream.listen(
        _handleRealtimeApiUpdate,
        onError: _handleRealtimeApiError,
      );

      debugPrint('✅ Enhanced real-time API streams initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize enhanced real-time API streams: $e');
      _isConnected = false;
      onConnectionStatusChanged(_isConnected);
    }
  }

  /// Handle real-time API updates
  void _handleRealtimeApiUpdate(RealtimeProjectUpdate update) {
    debugPrint('📡 Enhanced real-time project update: ${update.type}');
    onShowNotification(update);
  }

  /// Handle real-time API errors
  void _handleRealtimeApiError(dynamic error) {
    debugPrint('Enhanced real-time error: $error');
    _isConnected = false;
    onConnectionStatusChanged(_isConnected);
  }

  /// Start live API updates
  void startLiveUpdates(ProjectsQuery query) {
    if (_isConnected) {
      context.read<ProjectBloc>().add(
        StartLiveProjectUpdates(query: query, updateInterval: const Duration(seconds: 30), includeDeltas: true),
      );
    }
  }

  /// Stop live API updates
  void stopLiveUpdates() {
    context.read<ProjectBloc>().add(const StopLiveProjectUpdates());
  }

  /// Get current connection status
  bool get isConnected => _isConnected;

  /// Clean up all subscriptions
  void dispose() {
    _realtimeApiSubscription?.cancel();
    context.read<ProjectBloc>().add(const StopProjectRealtimeUpdates());
  }
}
