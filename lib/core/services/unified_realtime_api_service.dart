import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/environment_config.dart';
import '../storage/secure_storage_service.dart';

/// Unified real-time API update service
/// Handles real-time updates for ALL API endpoints using WebSockets
/// Inspired by efficient real-time data handling patterns
@LazySingleton()
class UnifiedRealtimeApiService {
  WebSocketChannel? _channel;
  final SecureStorageService _storageService;
  final Map<String, StreamController<Map<String, dynamic>>> _endpointControllers = {};
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;

  // Configuration
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 2);

  // Endpoint identifiers for all API services
  static const String projectsEndpoint = 'projects';
  static const String tasksEndpoint = 'tasks';
  static const String dailyReportsEndpoint = 'daily-reports';
  static const String authEndpoint = 'auth';
  static const String calendarEndpoint = 'calendar';
  static const String wbsEndpoint = 'wbs';
  static const String notificationsEndpoint = 'notifications';
  static const String authorizationEndpoint = 'authorization';
  static const String workCalendarEndpoint = 'work-calendar';
  static const String calendarManagementEndpoint = 'calendar-management';

  UnifiedRealtimeApiService(this._storageService);

  /// Get real-time stream for specific API endpoint
  Stream<Map<String, dynamic>> getEndpointStream(String endpoint) {
    if (!_endpointControllers.containsKey(endpoint)) {
      _endpointControllers[endpoint] = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _endpointControllers[endpoint]!.stream;
  }

  /// Check if WebSocket is connected
  bool get isConnected => _channel != null;

  /// Connect to real-time API service
  Future<void> connect() async {
    if (_isConnecting || isConnected) return;

    _isConnecting = true;

    try {
      final token = await _storageService.getAccessToken();
      if (token == null) {
        if (kDebugMode) {
          debugPrint('❌ UnifiedRealtimeApiService: No auth token available');
        }
        _isConnecting = false;
        return;
      }

      final wsUrl = '${EnvironmentConfig.websocketUrl}/api-updates';
      if (kDebugMode) {
        debugPrint('🔌 UnifiedRealtimeApiService: Connecting to $wsUrl');
      }

      // Connect with authentication
      _channel = WebSocketChannel.connect(Uri.parse('$wsUrl?token=$token'), protocols: ['api-updates']);

      // Listen to WebSocket messages
      _channel!.stream.listen(_onMessage, onError: _onError, onDone: _onDisconnect);

      // Send initial subscription message for all endpoints
      await _subscribeToAllEndpoints();

      // Start heartbeat
      _startHeartbeat();

      _reconnectAttempts = 0;
      _isConnecting = false;

      if (kDebugMode) {
        debugPrint('✅ UnifiedRealtimeApiService: Connected successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ UnifiedRealtimeApiService: Connection failed: $e');
      }
      _isConnecting = false;
      _scheduleReconnect();
    }
  }

  /// Subscribe to all API endpoints for real-time updates
  Future<void> _subscribeToAllEndpoints() async {
    final subscriptionMessage = {
      'type': 'subscribe',
      'endpoints': [
        projectsEndpoint,
        tasksEndpoint,
        dailyReportsEndpoint,
        authEndpoint,
        calendarEndpoint,
        wbsEndpoint,
        authorizationEndpoint,
        workCalendarEndpoint,
        calendarManagementEndpoint,
      ],
      'includeMetadata': true,
    };

    _sendMessage(subscriptionMessage);
  }

  /// Handle incoming WebSocket messages
  void _onMessage(dynamic message) {
    try {
      Map<String, dynamic> data;

      // Handle both text and binary messages
      if (message is String) {
        data = json.decode(message);
      } else if (message is Uint8List) {
        // Handle BSON or binary data if needed
        final decoded = utf8.decode(message);
        data = json.decode(decoded);
      } else {
        if (kDebugMode) {
          debugPrint('⚠️ UnifiedRealtimeApiService: Unsupported message type: ${message.runtimeType}');
        }
        return;
      }

      _processMessage(data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ UnifiedRealtimeApiService: Error processing message: $e');
      }
    }
  }

  /// Process real-time message and route to appropriate endpoint stream
  void _processMessage(Map<String, dynamic> data) {
    final messageType = data['type'] as String?;
    final endpoint = data['endpoint'] as String?;
    final payload = data['payload'] as Map<String, dynamic>?;

    if (messageType == null || endpoint == null || payload == null) {
      if (kDebugMode) {
        debugPrint('⚠️ UnifiedRealtimeApiService: Invalid message format');
      }
      return;
    }

    // Handle different message types
    switch (messageType) {
      case 'update':
        _handleUpdate(endpoint, payload);
        break;
      case 'create':
        _handleCreate(endpoint, payload);
        break;
      case 'delete':
        _handleDelete(endpoint, payload);
        break;
      case 'bulk_update':
        _handleBulkUpdate(endpoint, payload);
        break;
      case 'heartbeat':
        _handleHeartbeat(payload);
        break;
      default:
        if (kDebugMode) {
          debugPrint('⚠️ UnifiedRealtimeApiService: Unknown message type: $messageType');
        }
    }
  }

  /// Handle update messages for specific endpoints
  void _handleUpdate(String endpoint, Map<String, dynamic> payload) {
    final enrichedPayload = {
      'type': 'update',
      'endpoint': endpoint,
      'data': payload,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _emitToEndpoint(endpoint, enrichedPayload);

    if (kDebugMode) {
      debugPrint('📡 UnifiedRealtimeApiService: Update for $endpoint');
    }
  }

  /// Handle create messages for specific endpoints
  void _handleCreate(String endpoint, Map<String, dynamic> payload) {
    final enrichedPayload = {
      'type': 'create',
      'endpoint': endpoint,
      'data': payload,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _emitToEndpoint(endpoint, enrichedPayload);

    if (kDebugMode) {
      debugPrint('📡 UnifiedRealtimeApiService: Create for $endpoint');
    }
  }

  /// Handle delete messages for specific endpoints
  void _handleDelete(String endpoint, Map<String, dynamic> payload) {
    final enrichedPayload = {
      'type': 'delete',
      'endpoint': endpoint,
      'data': payload,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _emitToEndpoint(endpoint, enrichedPayload);

    if (kDebugMode) {
      debugPrint('📡 UnifiedRealtimeApiService: Delete for $endpoint');
    }
  }

  /// Handle bulk update messages for specific endpoints
  void _handleBulkUpdate(String endpoint, Map<String, dynamic> payload) {
    final enrichedPayload = {
      'type': 'bulk_update',
      'endpoint': endpoint,
      'data': payload,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _emitToEndpoint(endpoint, enrichedPayload);

    if (kDebugMode) {
      debugPrint('📡 UnifiedRealtimeApiService: Bulk update for $endpoint');
    }
  }

  /// Handle heartbeat messages
  void _handleHeartbeat(Map<String, dynamic> payload) {
    // Send heartbeat response
    _sendMessage({'type': 'heartbeat_response', 'timestamp': DateTime.now().toIso8601String()});
  }

  /// Emit data to specific endpoint stream
  void _emitToEndpoint(String endpoint, Map<String, dynamic> data) {
    if (_endpointControllers.containsKey(endpoint) && !_endpointControllers[endpoint]!.isClosed) {
      _endpointControllers[endpoint]!.add(data);
    }
  }

  /// Send message through WebSocket
  void _sendMessage(Map<String, dynamic> message) {
    if (!isConnected) return;

    try {
      final jsonMessage = json.encode(message);
      _channel!.sink.add(jsonMessage);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ UnifiedRealtimeApiService: Error sending message: $e');
      }
    }
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      _sendMessage({'type': 'ping', 'timestamp': DateTime.now().toIso8601String()});
    });
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Handle WebSocket errors
  void _onError(error) {
    if (kDebugMode) {
      debugPrint('❌ UnifiedRealtimeApiService: WebSocket error: $error');
    }
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnect
  void _onDisconnect() {
    if (kDebugMode) {
      debugPrint('🔌 UnifiedRealtimeApiService: Disconnected');
    }
    _channel = null;
    _stopHeartbeat();
    _scheduleReconnect();
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (!_shouldReconnect || _reconnectAttempts >= _maxReconnectAttempts) {
      if (kDebugMode) {
        debugPrint('❌ UnifiedRealtimeApiService: Max reconnect attempts reached');
      }
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      if (kDebugMode) {
        debugPrint('🔄 UnifiedRealtimeApiService: Reconnecting (attempt $_reconnectAttempts)...');
      }
      connect();
    });
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _stopHeartbeat();
    _reconnectTimer?.cancel();

    try {
      await _channel?.sink.close();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ UnifiedRealtimeApiService: Error closing connection: $e');
      }
    }

    _channel = null;

    if (kDebugMode) {
      debugPrint('🔌 UnifiedRealtimeApiService: Disconnected');
    }
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    for (final controller in _endpointControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _endpointControllers.clear();
  }

  /// Subscribe to specific endpoints only
  Future<void> subscribeToEndpoints(List<String> endpoints) async {
    if (!isConnected) return;

    _sendMessage({'type': 'subscribe', 'endpoints': endpoints, 'includeMetadata': true});
  }

  /// Unsubscribe from specific endpoints
  Future<void> unsubscribeFromEndpoints(List<String> endpoints) async {
    if (!isConnected) return;

    _sendMessage({'type': 'unsubscribe', 'endpoints': endpoints});
  }

  /// Request initial data for specific endpoint
  Future<void> requestEndpointData(String endpoint, {Map<String, dynamic>? filters}) async {
    if (!isConnected) return;

    _sendMessage({
      'type': 'request_data',
      'endpoint': endpoint,
      'filters': filters ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
