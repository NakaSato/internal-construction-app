import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

import '../services/signalr_service.dart';
import '../services/realtime_service.dart';

/// Comprehensive real-time event handler for all API endpoints
/// Provides a centralized way to handle real-time events across all features
@LazySingleton()
class UniversalRealtimeHandler {
  final SignalRService _signalRService;
  final Map<String, List<Function(RealtimeEvent)>> _eventHandlers = {};
  StreamSubscription<RealtimeEvent>? _eventSubscription;

  UniversalRealtimeHandler(this._signalRService);

  /// Initialize the universal real-time handler
  Future<void> initialize() async {
    await _signalRService.connect();

    // Listen to all real-time events
    _eventSubscription = _signalRService.eventStream.listen(_handleRealtimeEvent);

    debugPrint('✅ UniversalRealtimeHandler: Initialized and listening to all events');
  }

  /// Register a handler for specific event types
  void registerHandler(List<RealtimeEventType> eventTypes, Function(RealtimeEvent) handler) {
    for (final eventType in eventTypes) {
      final key = eventType.name;
      _eventHandlers[key] ??= [];
      _eventHandlers[key]!.add(handler);
    }
  }

  /// Unregister a handler for specific event types
  void unregisterHandler(List<RealtimeEventType> eventTypes, Function(RealtimeEvent) handler) {
    for (final eventType in eventTypes) {
      final key = eventType.name;
      _eventHandlers[key]?.remove(handler);
      if (_eventHandlers[key]?.isEmpty == true) {
        _eventHandlers.remove(key);
      }
    }
  }

  /// Register handlers for project management events
  void registerProjectHandler(Function(RealtimeEvent) handler) {
    registerHandler([
      RealtimeEventType.projectCreated,
      RealtimeEventType.projectUpdated,
      RealtimeEventType.projectDeleted,
      RealtimeEventType.projectStatusChanged,
    ], handler);
  }

  /// Register handlers for task management events
  void registerTaskHandler(Function(RealtimeEvent) handler) {
    registerHandler([
      RealtimeEventType.taskCreated,
      RealtimeEventType.taskUpdated,
      RealtimeEventType.taskDeleted,
      RealtimeEventType.taskStatusChanged,
      RealtimeEventType.taskAssigned,
    ], handler);
  }

  /// Register handlers for daily report events
  void registerDailyReportHandler(Function(RealtimeEvent) handler) {
    registerHandler([
      RealtimeEventType.dailyReportCreated,
      RealtimeEventType.dailyReportUpdated,
      RealtimeEventType.dailyReportDeleted,
      RealtimeEventType.dailyReportSubmitted,
      RealtimeEventType.dailyReportApproved,
    ], handler);
  }

  /// Register handlers for WBS events
  void registerWbsHandler(Function(RealtimeEvent) handler) {
    registerHandler([
      RealtimeEventType.wbsTaskCreated,
      RealtimeEventType.wbsTaskUpdated,
      RealtimeEventType.wbsTaskDeleted,
      RealtimeEventType.wbsStructureChanged,
    ], handler);
  }

  /// Register handlers for calendar events
  void registerCalendarHandler(Function(RealtimeEvent) handler) {
    registerHandler([
      RealtimeEventType.calendarEventCreated,
      RealtimeEventType.calendarEventUpdated,
      RealtimeEventType.calendarEventDeleted,
      RealtimeEventType.scheduleChanged,
    ], handler);
  }

  /// Register handlers for work request events
  void registerWorkRequestHandler(Function(RealtimeEvent) handler) {
    registerHandler([
      RealtimeEventType.workRequestCreated,
      RealtimeEventType.workRequestUpdated,
      RealtimeEventType.workRequestApproved,
      RealtimeEventType.workRequestRejected,
      RealtimeEventType.approvalStatusChanged,
    ], handler);
  }

  /// Register handlers for user events
  void registerUserHandler(Function(RealtimeEvent) handler) {
    registerHandler([
      RealtimeEventType.userActivity,
      RealtimeEventType.userJoined,
      RealtimeEventType.userLeft,
      RealtimeEventType.userProfileUpdated,
    ], handler);
  }

  /// Register handlers for notification events
  void registerNotificationHandler(Function(RealtimeEvent) handler) {
    registerHandler([
      RealtimeEventType.notificationCreated,
      RealtimeEventType.notificationRead,
      RealtimeEventType.notificationDeleted,
    ], handler);
  }

  /// Register handlers for system events
  void registerSystemHandler(Function(RealtimeEvent) handler) {
    registerHandler([RealtimeEventType.systemMaintenance, RealtimeEventType.broadcastMessage], handler);
  }

  /// Handle incoming real-time events by dispatching to registered handlers
  void _handleRealtimeEvent(RealtimeEvent event) {
    final handlers = _eventHandlers[event.type.name];
    if (handlers != null) {
      for (final handler in handlers) {
        try {
          handler(event);
        } catch (e) {
          debugPrint('❌ UniversalRealtimeHandler: Error in handler for ${event.type.name}: $e');
        }
      }
    }
  }

  /// Get connection status
  bool get isConnected => _signalRService.isConnected;

  /// Get real-time event stream (for direct access if needed)
  Stream<RealtimeEvent> get eventStream => _signalRService.eventStream;

  /// Subscribe to specific project events
  void subscribeToProject(String projectId) {
    _signalRService.joinProjectGroup(projectId);
  }

  /// Subscribe to specific user events
  void subscribeToUser(String userId) {
    // SignalR automatically handles user-specific events based on authentication
    debugPrint('📡 UniversalRealtimeHandler: User-specific events are handled automatically for user: $userId');
  }

  /// Disconnect and cleanup
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    _eventHandlers.clear();
    await _signalRService.disconnect();
    debugPrint('🔌 UniversalRealtimeHandler: Disposed');
  }
}
