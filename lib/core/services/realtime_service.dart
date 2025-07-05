import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

import '../config/environment_config.dart';
import '../storage/secure_storage_service.dart';

/// Real-time WebSocket service for live updates
/// Handles WebSocket connections and real-time event streaming
@LazySingleton()
class RealtimeService {
  WebSocketChannel? _channel;
  final SecureStorageService _storageService;
  StreamController<RealtimeEvent>? _eventController;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);

  RealtimeService(this._storageService);

  /// Stream of real-time events
  Stream<RealtimeEvent> get eventStream => _eventController?.stream ?? const Stream.empty();

  /// Check if WebSocket is connected
  bool get isConnected => _channel != null;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnecting || isConnected) return;

    _isConnecting = true;
    _eventController ??= StreamController<RealtimeEvent>.broadcast();

    try {
      final token = await _storageService.getAccessToken();
      if (token == null) {
        debugPrint('❌ RealtimeService: No auth token available');
        _isConnecting = false;
        return;
      }

      final wsUrl = EnvironmentConfig.websocketUrl;
      debugPrint('🔌 RealtimeService: Connecting to $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse('$wsUrl?token=$token'));

      // Listen to WebSocket messages
      _channel!.stream.listen(_onMessage, onError: _onError, onDone: _onDisconnect);

      // Send authentication message
      _sendMessage({'type': 'auth', 'token': token});

      // Start heartbeat to keep connection alive
      _startHeartbeat();

      _reconnectAttempts = 0;
      _isConnecting = false;
      debugPrint('✅ RealtimeService: Connected successfully');

      _eventController?.add(RealtimeEvent(type: RealtimeEventType.connectionStatus, data: {'connected': true}));
    } catch (e) {
      debugPrint('❌ RealtimeService: Connection failed: $e');
      _isConnecting = false;
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _stopHeartbeat();
    _reconnectTimer?.cancel();

    try {
      await _channel?.sink.close();
    } catch (e) {
      debugPrint('⚠️ RealtimeService: Error closing connection: $e');
    }

    _channel = null;
    _eventController?.add(RealtimeEvent(type: RealtimeEventType.connectionStatus, data: {'connected': false}));

    debugPrint('🔌 RealtimeService: Disconnected');
  }

  /// Subscribe to specific event types
  void subscribe(List<String> eventTypes) {
    if (!isConnected) return;

    _sendMessage({'type': 'subscribe', 'events': eventTypes});
  }

  /// Unsubscribe from specific event types
  void unsubscribe(List<String> eventTypes) {
    if (!isConnected) return;

    _sendMessage({'type': 'unsubscribe', 'events': eventTypes});
  }

  /// Subscribe to all project management events
  void subscribeToProjectEvents() {
    subscribe(['project_created', 'project_updated', 'project_deleted', 'project_status_changed']);
  }

  /// Subscribe to all task management events
  void subscribeToTaskEvents() {
    subscribe(['task_created', 'task_updated', 'task_deleted', 'task_status_changed', 'task_assigned']);
  }

  /// Subscribe to all daily report events
  void subscribeToDailyReportEvents() {
    subscribe([
      'daily_report_created',
      'daily_report_updated',
      'daily_report_deleted',
      'daily_report_submitted',
      'daily_report_approved',
    ]);
  }

  /// Subscribe to all WBS (Work Breakdown Structure) events
  void subscribeToWbsEvents() {
    subscribe(['wbs_task_created', 'wbs_task_updated', 'wbs_task_deleted', 'wbs_structure_changed']);
  }

  /// Subscribe to all work calendar events
  void subscribeToCalendarEvents() {
    subscribe(['calendar_event_created', 'calendar_event_updated', 'calendar_event_deleted', 'schedule_changed']);
  }

  /// Subscribe to all work request approval events
  void subscribeToWorkRequestEvents() {
    subscribe([
      'work_request_created',
      'work_request_updated',
      'work_request_approved',
      'work_request_rejected',
      'approval_status_changed',
    ]);
  }

  /// Subscribe to all user and authentication events
  void subscribeToUserEvents() {
    subscribe(['user_activity', 'user_joined', 'user_left', 'user_profile_updated']);
  }

  /// Subscribe to all notification events
  void subscribeToNotificationEvents() {
    subscribe(['notification_created', 'notification_read', 'notification_deleted']);
  }

  /// Subscribe to all system events
  void subscribeToSystemEvents() {
    subscribe(['system_maintenance', 'broadcast_message']);
  }

  /// Subscribe to all events across the entire system
  /// Use this for admin dashboards or comprehensive monitoring
  void subscribeToAllEvents() {
    subscribeToProjectEvents();
    subscribeToTaskEvents();
    subscribeToDailyReportEvents();
    subscribeToWbsEvents();
    subscribeToCalendarEvents();
    subscribeToWorkRequestEvents();
    subscribeToUserEvents();
    subscribeToNotificationEvents();
    subscribeToSystemEvents();
  }

  /// Subscribe to events relevant to a specific project
  void subscribeToProjectSpecificEvents(String projectId) {
    subscribe([
      'project_updated_$projectId',
      'project_status_changed_$projectId',
      'task_created_$projectId',
      'task_updated_$projectId',
      'task_deleted_$projectId',
      'daily_report_created_$projectId',
      'daily_report_updated_$projectId',
      'wbs_task_created_$projectId',
      'wbs_task_updated_$projectId',
      'calendar_event_created_$projectId',
      'calendar_event_updated_$projectId',
    ]);
  }

  /// Subscribe to events relevant to a specific user
  void subscribeToUserSpecificEvents(String userId) {
    subscribe([
      'task_assigned_$userId',
      'work_request_created_$userId',
      'work_request_approved_$userId',
      'work_request_rejected_$userId',
      'notification_created_$userId',
      'daily_report_approved_$userId',
    ]);
  }

  /// Handle incoming WebSocket messages
  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final eventType = _parseEventType(data['type'] as String?);

      if (eventType != null) {
        final event = RealtimeEvent(
          type: eventType,
          data: data['data'] as Map<String, dynamic>? ?? {},
          timestamp: DateTime.now(),
        );

        _eventController?.add(event);
        debugPrint('📨 RealtimeService: Received ${eventType.name} event');
      }
    } catch (e) {
      debugPrint('❌ RealtimeService: Error parsing message: $e');
    }
  }

  /// Handle WebSocket errors
  void _onError(dynamic error) {
    debugPrint('❌ RealtimeService: WebSocket error: $error');
    _eventController?.add(RealtimeEvent(type: RealtimeEventType.error, data: {'error': error.toString()}));
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnection
  void _onDisconnect() {
    debugPrint('🔌 RealtimeService: WebSocket disconnected');
    _channel = null;
    _stopHeartbeat();

    _eventController?.add(RealtimeEvent(type: RealtimeEventType.connectionStatus, data: {'connected': false}));

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// Send message to WebSocket server
  void _sendMessage(Map<String, dynamic> message) {
    if (!isConnected) return;

    try {
      _channel?.sink.add(jsonEncode(message));
    } catch (e) {
      debugPrint('❌ RealtimeService: Error sending message: $e');
    }
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      _sendMessage({'type': 'ping'});
    });
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('🛑 RealtimeService: Max reconnect attempts reached');
      return;
    }

    _reconnectAttempts++;
    debugPrint('🔄 RealtimeService: Scheduling reconnect attempt $_reconnectAttempts');

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_shouldReconnect) {
        connect();
      }
    });
  }

  /// Parse event type from string
  RealtimeEventType? _parseEventType(String? type) {
    switch (type) {
      // Project Management Events
      case 'project_created':
        return RealtimeEventType.projectCreated;
      case 'project_updated':
        return RealtimeEventType.projectUpdated;
      case 'project_deleted':
        return RealtimeEventType.projectDeleted;
      case 'project_status_changed':
        return RealtimeEventType.projectStatusChanged;

      // Task Management Events
      case 'task_created':
        return RealtimeEventType.taskCreated;
      case 'task_updated':
        return RealtimeEventType.taskUpdated;
      case 'task_deleted':
        return RealtimeEventType.taskDeleted;
      case 'task_status_changed':
        return RealtimeEventType.taskStatusChanged;
      case 'task_assigned':
        return RealtimeEventType.taskAssigned;

      // Daily Reports Events
      case 'daily_report_created':
        return RealtimeEventType.dailyReportCreated;
      case 'daily_report_updated':
        return RealtimeEventType.dailyReportUpdated;
      case 'daily_report_deleted':
        return RealtimeEventType.dailyReportDeleted;
      case 'daily_report_submitted':
        return RealtimeEventType.dailyReportSubmitted;
      case 'daily_report_approved':
        return RealtimeEventType.dailyReportApproved;

      // WBS (Work Breakdown Structure) Events
      case 'wbs_task_created':
        return RealtimeEventType.wbsTaskCreated;
      case 'wbs_task_updated':
        return RealtimeEventType.wbsTaskUpdated;
      case 'wbs_task_deleted':
        return RealtimeEventType.wbsTaskDeleted;
      case 'wbs_structure_changed':
        return RealtimeEventType.wbsStructureChanged;

      // Work Calendar Events
      case 'calendar_event_created':
        return RealtimeEventType.calendarEventCreated;
      case 'calendar_event_updated':
        return RealtimeEventType.calendarEventUpdated;
      case 'calendar_event_deleted':
        return RealtimeEventType.calendarEventDeleted;
      case 'schedule_changed':
        return RealtimeEventType.scheduleChanged;

      // Work Request Approval Events
      case 'work_request_created':
        return RealtimeEventType.workRequestCreated;
      case 'work_request_updated':
        return RealtimeEventType.workRequestUpdated;
      case 'work_request_approved':
        return RealtimeEventType.workRequestApproved;
      case 'work_request_rejected':
        return RealtimeEventType.workRequestRejected;
      case 'approval_status_changed':
        return RealtimeEventType.approvalStatusChanged;

      // User & Authentication Events
      case 'user_activity':
        return RealtimeEventType.userActivity;
      case 'user_joined':
        return RealtimeEventType.userJoined;
      case 'user_left':
        return RealtimeEventType.userLeft;
      case 'user_profile_updated':
        return RealtimeEventType.userProfileUpdated;

      // Notification Events
      case 'notification_created':
        return RealtimeEventType.notificationCreated;
      case 'notification_read':
        return RealtimeEventType.notificationRead;
      case 'notification_deleted':
        return RealtimeEventType.notificationDeleted;

      // System Events
      case 'connection_status':
        return RealtimeEventType.connectionStatus;
      case 'error':
        return RealtimeEventType.error;
      case 'system_maintenance':
        return RealtimeEventType.systemMaintenance;
      case 'broadcast_message':
        return RealtimeEventType.broadcastMessage;

      default:
        debugPrint('⚠️ RealtimeService: Unknown event type: $type');
        return null;
    }
  }

  /// Dispose of resources
  void dispose() {
    _shouldReconnect = false;
    disconnect();
    _eventController?.close();
  }
}

/// Real-time event types for comprehensive live updates across all API endpoints
enum RealtimeEventType {
  // Project Management Events
  projectCreated,
  projectUpdated,
  projectDeleted,
  projectStatusChanged,

  // Task Management Events
  taskCreated,
  taskUpdated,
  taskDeleted,
  taskStatusChanged,
  taskAssigned,

  // Daily Reports Events
  dailyReportCreated,
  dailyReportUpdated,
  dailyReportDeleted,
  dailyReportSubmitted,
  dailyReportApproved,

  // WBS (Work Breakdown Structure) Events
  wbsTaskCreated,
  wbsTaskUpdated,
  wbsTaskDeleted,
  wbsStructureChanged,

  // Work Calendar Events
  calendarEventCreated,
  calendarEventUpdated,
  calendarEventDeleted,
  scheduleChanged,

  // Work Request Approval Events
  workRequestCreated,
  workRequestUpdated,
  workRequestApproved,
  workRequestRejected,
  approvalStatusChanged,

  // User & Authentication Events
  userActivity,
  userJoined,
  userLeft,
  userProfileUpdated,

  // Notification Events
  notificationCreated,
  notificationRead,
  notificationDeleted,

  // System Events
  connectionStatus,
  error,
  systemMaintenance,
  broadcastMessage,
}

/// Real-time event model
class RealtimeEvent {
  final RealtimeEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  RealtimeEvent({required this.type, required this.data, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'RealtimeEvent(type: $type, data: $data, timestamp: $timestamp)';
}
