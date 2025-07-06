import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/universal_realtime_handler.dart';
import '../../../../core/services/realtime_api_streams.dart';
import '../../../authentication/application/auth_bloc.dart';
import '../../../authentication/application/auth_state.dart';
import '../../application/project_bloc.dart';
import '../../domain/entities/project_api_models.dart';

/// Mixin to handle real-time project updates functionality
mixin ProjectRealtimeMixin<T extends StatefulWidget> on State<T> {
  late final UniversalRealtimeHandler _realtimeHandler;
  late final RealtimeApiStreams _realtimeApiStreams;
  StreamSubscription<RealtimeProjectUpdate>? _realtimeApiSubscription;
  StreamSubscription? _authSubscription;
  bool _isRealtimeConnected = false;

  bool get isRealtimeConnected => _isRealtimeConnected;

  /// Initialize real-time components
  void initializeRealtimeComponents() {
    _realtimeHandler = getIt<UniversalRealtimeHandler>();
    _realtimeApiStreams = getIt<RealtimeApiStreams>();
  }

  /// Check authentication and initialize real-time updates if authenticated
  Future<void> checkAuthAndInitializeRealtime() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      await _initializeRealtimeUpdates();
    } else {
      debugPrint('⚠️ Project List: User not authenticated, skipping real-time initialization');
      // Listen for authentication changes
      _authSubscription = context.read<AuthBloc>().stream.listen((state) {
        if (state is AuthAuthenticated && mounted) {
          _initializeRealtimeUpdates();
        } else if (state is AuthUnauthenticated && mounted) {
          _disconnectRealtime();
        }
      });
    }
  }

  /// Initialize enhanced real-time API system
  Future<void> initializeEnhancedRealtime() async {
    try {
      // Initialize connection
      await _realtimeApiStreams.initialize();

      if (mounted) {
        setState(() {
          _isRealtimeConnected = _realtimeApiStreams.isConnected;
        });

        // Start enhanced real-time updates through BLoC
        context.read<EnhancedProjectBloc>().add(const StartProjectRealtimeUpdates());

        // Subscribe for UI feedback and live connection status
        _realtimeApiSubscription = _realtimeApiStreams.projectsStream.listen(
          (update) {
            if (!mounted) return;

            debugPrint('📡 Enhanced real-time project update: ${update.type}');

            // Update connection status
            if (!_isRealtimeConnected) {
              setState(() {
                _isRealtimeConnected = true;
              });
            }

            // Handle the update
            onRealtimeUpdate(update);
          },
          onError: (error) {
            debugPrint('❌ Enhanced real-time error: $error');
            if (mounted) {
              setState(() {
                _isRealtimeConnected = false;
              });

              // Try to reconnect after a delay
              Future.delayed(const Duration(seconds: 5), () {
                if (mounted && !_isRealtimeConnected) {
                  initializeEnhancedRealtime();
                }
              });
            }
          },
          onDone: () {
            debugPrint('📡 Enhanced real-time connection closed');
            if (mounted) {
              setState(() {
                _isRealtimeConnected = false;
              });
            }
          },
        );

        debugPrint('✅ Enhanced real-time system initialized for project list');
      }
    } catch (e) {
      debugPrint('❌ Failed to initialize enhanced real-time: $e');
      if (mounted) {
        setState(() {
          _isRealtimeConnected = false;
        });

        // Try to reconnect after a delay
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted && !_isRealtimeConnected) {
            initializeEnhancedRealtime();
          }
        });
      }
    }
  }

  /// Initialize real-time updates for comprehensive live data synchronization
  Future<void> _initializeRealtimeUpdates() async {
    try {
      // Initialize the universal real-time handler if not already connected
      if (!_realtimeHandler.isConnected) {
        await _realtimeHandler.initialize();
      }

      // Register handlers for project-related events
      _realtimeHandler.registerProjectHandler((event) {
        if (!mounted) return;

        debugPrint('📡 Real-time project event: ${event.type.name}');
        onProjectRealtimeEvent(event);
      });

      // Register handlers for task-related events (affects project status)
      _realtimeHandler.registerTaskHandler((event) {
        if (!mounted) return;

        debugPrint('📡 Real-time task event: ${event.type.name}');
        onTaskRealtimeEvent(event);
      });

      // Register handlers for daily report events (affects project status)
      _realtimeHandler.registerDailyReportHandler((event) {
        if (!mounted) return;

        debugPrint('📡 Real-time daily report event: ${event.type.name}');
        onDailyReportRealtimeEvent(event);
      });

      debugPrint('✅ Project List: Real-time updates initialized successfully');
    } catch (e) {
      debugPrint('❌ Project List: Failed to initialize real-time updates: $e');
      // Continue with fallback polling if real-time fails
    }
  }

  /// Disconnect real-time updates when user logs out
  Future<void> _disconnectRealtime() async {
    try {
      // The UniversalRealtimeHandler will handle cleanup automatically
      debugPrint('🔌 Project List: Disconnecting real-time updates due to logout');
    } catch (e) {
      debugPrint('❌ Project List: Error disconnecting real-time updates: $e');
    }
  }

  /// Clean up real-time subscriptions
  void disposeRealtimeComponents() {
    _authSubscription?.cancel();
    context.read<EnhancedProjectBloc>().add(const StopProjectRealtimeUpdates());
    _realtimeApiSubscription?.cancel();
  }

  /// Default implementation for showing realtime update notifications
  void showRealtimeUpdateNotification(RealtimeProjectUpdate update) {
    final (message, color, icon) = getUpdateNotificationData(update.type);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(message),
            ],
          ),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
    }
  }

  /// Get notification data for different update types
  (String, Color, IconData) getUpdateNotificationData(String type) {
    switch (type) {
      case 'create':
        return ('New project added', Colors.green, Icons.add_circle);
      case 'update':
        return ('Project updated', Colors.blue, Icons.update);
      case 'delete':
        return ('Project removed', Colors.orange, Icons.remove_circle);
      default:
        return ('Project data changed', Colors.grey, Icons.sync);
    }
  }

  /// Default implementation for handling realtime updates
  void handleRealtimeUpdate(RealtimeProjectUpdate update) {
    if (!mounted) return;

    switch (update.type) {
      case 'create':
        if (update.project != null) {
          context.read<EnhancedProjectBloc>().add(RealTimeProjectCreatedReceived(project: update.project!));
        } else {
          onSilentRefresh();
        }
        break;
      case 'update':
        if (update.project != null) {
          context.read<EnhancedProjectBloc>().add(RealTimeProjectUpdateReceived(project: update.project!));
        } else {
          onSilentRefresh();
        }
        break;
      case 'delete':
        final projectId = update.data['id']?.toString() ?? update.data['projectId']?.toString();
        if (projectId != null) {
          context.read<EnhancedProjectBloc>().add(RealTimeProjectDeletedReceived(projectId: projectId));
        } else {
          onSilentRefresh();
        }
        break;
      default:
        onSilentRefresh();
    }

    if (shouldRefreshForUpdate(update)) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) refreshCurrentView();
      });
    }
  }

  /// Default implementation for handling project events
  void handleProjectRealtimeEvent(dynamic event) {
    final projectData = event.data;
    switch (event.type.name) {
      case 'projectCreated':
        handleProjectCreated(projectData);
        break;
      case 'projectUpdated':
        handleProjectUpdated(projectData);
        break;
      case 'projectDeleted':
        handleProjectDeleted(projectData);
        break;
      default:
        onSilentRefresh();
    }
  }

  /// Handle project created event
  void handleProjectCreated(Map<String, dynamic> projectData) {
    try {
      final project = EnhancedProject.fromJson(projectData);
      context.read<EnhancedProjectBloc>().add(RealTimeProjectCreatedReceived(project: project));
      checkAndRefreshView(projectData);
    } catch (e) {
      debugPrint('❌ Error parsing project created event: $e');
      onSilentRefresh();
    }
  }

  /// Handle project updated event
  void handleProjectUpdated(Map<String, dynamic> projectData) {
    try {
      final project = EnhancedProject.fromJson(projectData);
      context.read<EnhancedProjectBloc>().add(RealTimeProjectUpdateReceived(project: project));
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) refreshCurrentView();
      });
    } catch (e) {
      debugPrint('❌ Error parsing project updated event: $e');
      onSilentRefresh();
    }
  }

  /// Handle project deleted event
  void handleProjectDeleted(Map<String, dynamic> projectData) {
    final projectId = projectData['id'] as String? ?? projectData['projectId'] as String?;
    if (projectId != null) {
      context.read<EnhancedProjectBloc>().add(RealTimeProjectDeletedReceived(projectId: projectId));
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) refreshCurrentView();
      });
    } else {
      onSilentRefresh();
    }
  }

  /// Check if view should be refreshed and refresh if needed
  void checkAndRefreshView(Map<String, dynamic> projectData) {
    final mockUpdate = RealtimeProjectUpdate(
      type: 'create',
      endpoint: 'projects',
      timestamp: DateTime.now(),
      data: projectData,
      project: null,
    );
    if (shouldRefreshForUpdate(mockUpdate)) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) refreshCurrentView();
      });
    }
  }

  // Abstract methods that must be implemented by the using class
  void onSilentRefresh();
  void refreshCurrentView();
  bool shouldRefreshForUpdate(RealtimeProjectUpdate update);
  void onRealtimeUpdate(RealtimeProjectUpdate update);
  void onProjectRealtimeEvent(dynamic event);
  void onTaskRealtimeEvent(dynamic event);
  void onDailyReportRealtimeEvent(dynamic event);
}
