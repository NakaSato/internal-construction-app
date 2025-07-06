import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../config/environment_config.dart';
import '../storage/secure_storage_service.dart';
import 'realtime_service.dart';

/// SignalR-based real-time service for live updates
/// Handles SignalR connections and real-time event streaming
@LazySingleton()
class SignalRService {
  HubConnection? _hubConnection;
  final SecureStorageService _storageService;
  StreamController<RealtimeEvent>? _eventController;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 5);

  SignalRService(this._storageService);

  /// Stream of real-time events
  Stream<RealtimeEvent> get eventStream => _eventController?.stream ?? const Stream.empty();

  /// Check if SignalR is connected
  bool get isConnected => _hubConnection?.state == HubConnectionState.Connected;

  /// Connect to SignalR hub
  Future<void> connect() async {
    if (_isConnecting || isConnected) return;

    _isConnecting = true;
    _eventController ??= StreamController<RealtimeEvent>.broadcast();

    try {
      await _connectWithFallback();

      _reconnectAttempts = 0;
      _isConnecting = false;
      debugPrint('SignalRService: Connected successfully');

      _eventController?.add(RealtimeEvent(type: RealtimeEventType.connectionStatus, data: {'connected': true}));
    } on Exception catch (e) {
      debugPrint('SignalRService: Connection failed with Exception: $e');
      await diagnoseConnection(); // Run diagnostics
      _isConnecting = false;
      _scheduleReconnect();
      rethrow;
    } catch (e) {
      debugPrint('SignalRService: Connection failed with error: $e');
      debugPrint('SignalRService: Error type: ${e.runtimeType}');
      await diagnoseConnection(); // Run diagnostics
      _isConnecting = false;
      _scheduleReconnect();
      rethrow;
    }
  }

  /// Disconnect from SignalR hub
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();

    try {
      await _hubConnection?.stop();
    } catch (e) {
      debugPrint('SignalRService: Error stopping connection: $e');
    }

    _hubConnection = null;
    _eventController?.add(RealtimeEvent(type: RealtimeEventType.connectionStatus, data: {'connected': false}));

    debugPrint('SignalRService: Disconnected');
  }

  /// Join a project group for project-specific updates
  Future<void> joinProjectGroup(String projectId) async {
    if (!isConnected) return;

    try {
      await _hubConnection!.invoke('JoinProjectGroup', args: [projectId]);
      debugPrint('SignalRService: Joined project group: $projectId');
    } catch (e) {
      debugPrint('SignalRService: Failed to join project group: $e');
    }
  }

  /// Leave a project group
  Future<void> leaveProjectGroup(String projectId) async {
    if (!isConnected) return;

    try {
      await _hubConnection!.invoke('LeaveProjectGroup', args: [projectId]);
      debugPrint('SignalRService: Left project group: $projectId');
    } catch (e) {
      debugPrint('SignalRService: Failed to leave project group: $e');
    }
  }

  /// Join a daily report session for collaborative editing
  Future<void> joinDailyReportSession(String reportId) async {
    if (!isConnected) return;

    try {
      await _hubConnection!.invoke('JoinDailyReportSession', args: [reportId]);
      debugPrint('SignalRService: Joined daily report session: $reportId');
    } catch (e) {
      debugPrint('SignalRService: Failed to join daily report session: $e');
    }
  }

  /// Leave a daily report session
  Future<void> leaveDailyReportSession(String reportId) async {
    if (!isConnected) return;

    try {
      await _hubConnection!.invoke('LeaveDailyReportSession', args: [reportId]);
      debugPrint('SignalRService: Left daily report session: $reportId');
    } catch (e) {
      debugPrint('SignalRService: Failed to leave daily report session: $e');
    }
  }

  /// Update user status (online, away, busy)
  Future<void> updateUserStatus(String status) async {
    if (!isConnected) return;

    try {
      await _hubConnection!.invoke('UpdateUserStatus', args: [status]);
      debugPrint('SignalRService: Updated user status: $status');
    } catch (e) {
      debugPrint('SignalRService: Failed to update user status: $e');
    }
  }

  /// Send a message to a project group
  Future<void> sendProjectMessage(String projectId, String message) async {
    if (!isConnected) return;

    try {
      await _hubConnection!.invoke('SendProjectMessage', args: [projectId, message]);
      debugPrint('SignalRService: Sent project message to: $projectId');
    } catch (e) {
      debugPrint('SignalRService: Failed to send project message: $e');
    }
  }

  /// Set up all SignalR event handlers
  void _setupEventHandlers() {
    if (_hubConnection == null) return;

    // General notification events
    _hubConnection!.on('ReceiveNotification', _handleReceiveNotification);

    // Project events
    _hubConnection!.on('UserJoinedProject', _handleUserJoinedProject);
    _hubConnection!.on('UserLeftProject', _handleUserLeftProject);
    _hubConnection!.on('ProjectMessageReceived', _handleProjectMessageReceived);

    // Daily report events
    _hubConnection!.on('UserJoinedReportSession', _handleUserJoinedReportSession);
    _hubConnection!.on('UserLeftReportSession', _handleUserLeftReportSession);
    _hubConnection!.on('ReportFieldUpdated', _handleReportFieldUpdated);
    _hubConnection!.on('UserStartedTyping', _handleUserStartedTyping);
    _hubConnection!.on('UserStoppedTyping', _handleUserStoppedTyping);

    // Work request events
    _hubConnection!.on('WorkRequestCreated', _handleWorkRequestCreated);
    _hubConnection!.on('WorkRequestStatusChanged', _handleWorkRequestStatusChanged);

    // Daily report approval events
    _hubConnection!.on('DailyReportCreated', _handleDailyReportCreated);
    _hubConnection!.on('DailyReportApprovalStatusChanged', _handleDailyReportApprovalStatusChanged);

    // Progress and system events
    _hubConnection!.on('RealTimeProgressUpdate', _handleRealTimeProgressUpdate);
    _hubConnection!.on('SystemAnnouncement', _handleSystemAnnouncement);
    _hubConnection!.on('UserStatusChanged', _handleUserStatusChanged);

    debugPrint('✅ SignalRService: Event handlers set up');
  }

  /// Get the SignalR hub URL
  String _getSignalRHubUrl() {
    // Use the dedicated WebSocket URL if available, otherwise fall back to API base URL
    final wsUrl = EnvironmentConfig.websocketUrl;
    if (wsUrl.contains('/notificationHub')) {
      debugPrint('🔌 SignalRService: Using WebSocket URL: $wsUrl');
      return wsUrl;
    } else {
      final baseUrl = EnvironmentConfig.apiBaseUrl;
      final hubUrl = '$baseUrl/notificationHub';
      debugPrint('🔌 SignalRService: Using API base URL: $hubUrl');
      return hubUrl;
    }
  }

  /// Schedule reconnection attempt (fallback for manual reconnection)
  void _scheduleReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('🛑 SignalRService: Max reconnect attempts reached');
      return;
    }

    _reconnectAttempts++;
    debugPrint('🔄 SignalRService: Scheduling reconnect attempt $_reconnectAttempts');

    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_shouldReconnect) {
        connect();
      }
    });
  }

  /// Try to connect with fallback transport modes
  Future<void> _connectWithFallback() async {
    final transportModes = [
      HttpTransportType.WebSockets,
      HttpTransportType.ServerSentEvents,
      HttpTransportType.LongPolling,
    ];

    for (int i = 0; i < transportModes.length; i++) {
      try {
        debugPrint('SignalRService: Attempting connection with transport: ${transportModes[i]}');
        await _connectWithTransport(transportModes[i]);
        return; // Success!
      } catch (e) {
        debugPrint('SignalRService: Failed with transport ${transportModes[i]}: $e');
        if (i == transportModes.length - 1) {
          // Last transport mode, re-throw the error
          debugPrint('SignalRService: All transport modes failed');
          rethrow;
        }
        // Try next transport mode
        debugPrint('SignalRService: Trying next transport mode...');
      }
    }
  }

  /// Connect with specific transport mode
  Future<void> _connectWithTransport(HttpTransportType transport) async {
    final token = await _storageService.getAccessToken();
    if (token == null) {
      throw Exception('No authentication token available');
    }

    // Use the HTTP URL for SignalR (not WebSocket URL)
    // SignalR will handle the WebSocket upgrade automatically during negotiation
    final hubUrl = '${EnvironmentConfig.apiBaseUrl}/notificationHub';
    debugPrint('SignalRService: Connecting to $hubUrl with transport: $transport');
    debugPrint('SignalRService: Token length: ${token.length}');

    // Configure options based on transport type
    final options = HttpConnectionOptions(
      accessTokenFactory: () async {
        final currentToken = await _storageService.getAccessToken();
        debugPrint('SignalRService: Providing token for auth');
        return currentToken ?? '';
      },
      transport: transport,
      skipNegotiation: false, // Always allow negotiation for proper auth handling
      logMessageContent: kDebugMode,
    );

    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl, options: options)
        .withAutomaticReconnect(
          retryDelays: [
            2000, // 2 seconds
            5000, // 5 seconds
            10000, // 10 seconds
          ],
        )
        .build();

    // Set up event handlers
    _setupEventHandlers();

    debugPrint('SignalRService: Starting connection...');
    await _hubConnection!.start();
    debugPrint('SignalRService: Connected successfully with transport: $transport');
  }

  /// Diagnose connection issues by testing basic HTTP connectivity
  Future<void> diagnoseConnection() async {
    try {
      final hubUrl = _getSignalRHubUrl();
      debugPrint('SignalRService: Diagnosing connection to $hubUrl');

      final token = await _storageService.getAccessToken();
      if (token == null) {
        debugPrint('SignalRService: No authentication token found');
        return;
      }

      debugPrint('SignalRService: Token available: ${token.substring(0, 20)}...');
      debugPrint('SignalRService: Hub URL: $hubUrl');
      debugPrint('SignalRService: Base URL: ${EnvironmentConfig.apiBaseUrl}');

      // Try to ping the base API endpoint first
      final baseUrl = EnvironmentConfig.apiBaseUrl;
      debugPrint('SignalRService: Testing base API connectivity to $baseUrl');
    } catch (e) {
      debugPrint('SignalRService: Diagnostic failed: $e');
    }
  }

  // Event handlers for different SignalR events

  void _handleReceiveNotification(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.notificationCreated, data: data));
    } catch (e) {
      debugPrint('SignalRService: Error handling notification: $e');
    }
  }

  void _handleUserJoinedProject(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.userJoined, data: data));
    } catch (e) {
      debugPrint('SignalRService: Error handling user joined project: $e');
    }
  }

  void _handleUserLeftProject(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.userLeft, data: data));
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling user left project: $e');
    }
  }

  void _handleProjectMessageReceived(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.broadcastMessage, data: data));
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling project message: $e');
    }
  }

  void _handleUserJoinedReportSession(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.userJoined, data: data));
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling user joined report session: $e');
    }
  }

  void _handleUserLeftReportSession(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.userLeft, data: data));
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling user left report session: $e');
    }
  }

  void _handleReportFieldUpdated(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.dailyReportUpdated, data: data));
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling report field updated: $e');
    }
  }

  void _handleUserStartedTyping(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(
        RealtimeEvent(type: RealtimeEventType.userActivity, data: {...data, 'activity': 'startedTyping'}),
      );
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling user started typing: $e');
    }
  }

  void _handleUserStoppedTyping(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(
        RealtimeEvent(type: RealtimeEventType.userActivity, data: {...data, 'activity': 'stoppedTyping'}),
      );
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling user stopped typing: $e');
    }
  }

  void _handleWorkRequestCreated(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.workRequestCreated, data: data));
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling work request created: $e');
    }
  }

  void _handleWorkRequestStatusChanged(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.workRequestUpdated, data: data));
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling work request status changed: $e');
    }
  }

  void _handleDailyReportCreated(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.dailyReportCreated, data: data));
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling daily report created: $e');
    }
  }

  void _handleDailyReportApprovalStatusChanged(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.dailyReportApproved, data: data));
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling daily report approval status changed: $e');
    }
  }

  void _handleRealTimeProgressUpdate(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.projectStatusChanged, data: data));
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling real-time progress update: $e');
    }
  }

  void _handleSystemAnnouncement(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.systemMaintenance, data: data));
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling system announcement: $e');
    }
  }

  void _handleUserStatusChanged(List<Object?>? args) {
    if (args == null || args.isEmpty) return;

    try {
      final data = args[0] as Map<String, dynamic>;
      _eventController?.add(RealtimeEvent(type: RealtimeEventType.userProfileUpdated, data: data));
    } catch (e) {
      debugPrint('❌ SignalRService: Error handling user status changed: $e');
    }
  }

  /// Dispose of resources
  void dispose() {
    _shouldReconnect = false;
    disconnect();
    _eventController?.close();
  }
}
