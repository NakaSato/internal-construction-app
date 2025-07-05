import 'dart:async';
import 'package:flutter/foundation.dart';

import '../services/realtime_api_streams.dart';
import '../di/injection.dart';

/// Universal helper to enhance any existing repository with real-time capabilities
/// Following the Medium article's approach for efficient real-time data handling
class RealtimeRepositoryEnhancer<T extends RealtimeUpdate> {
  late final RealtimeApiStreams _realtimeStreams;
  late final Stream<T> _endpointStream;
  final String _endpointName;
  StreamSubscription<T>? _subscription;
  bool _isInitialized = false;

  // Callbacks for different update types
  Function(T update)? _onUpdate;
  Function(T update)? _onCreate;
  Function(T update)? _onDelete;
  Function(T update)? _onBulkUpdate;
  Function(Object error)? _onError;

  RealtimeRepositoryEnhancer({required String endpointName}) : _endpointName = endpointName;

  /// Initialize the real-time enhancer
  Future<void> initialize() async {
    if (_isInitialized) return;

    _realtimeStreams = getIt<RealtimeApiStreams>();

    // Initialize connection
    await _realtimeStreams.initialize();

    // Get appropriate stream based on endpoint
    _endpointStream = _getStreamForEndpoint();

    _isInitialized = true;

    if (kDebugMode) {
      debugPrint('✅ RealtimeRepositoryEnhancer: Initialized for $_endpointName');
    }
  }

  /// Start listening to real-time updates
  void startListening({
    Function(T update)? onUpdate,
    Function(T update)? onCreate,
    Function(T update)? onDelete,
    Function(T update)? onBulkUpdate,
    Function(Object error)? onError,
  }) {
    if (!_isInitialized) {
      throw StateError('RealtimeRepositoryEnhancer must be initialized before starting to listen');
    }

    // Store callbacks
    _onUpdate = onUpdate;
    _onCreate = onCreate;
    _onDelete = onDelete;
    _onBulkUpdate = onBulkUpdate;
    _onError = onError;

    // Start subscription
    _subscription?.cancel();
    _subscription = _endpointStream.listen(_handleUpdate, onError: _handleError);

    if (kDebugMode) {
      debugPrint('🎧 RealtimeRepositoryEnhancer: Started listening for $_endpointName');
    }
  }

  /// Stop listening to real-time updates
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;

    if (kDebugMode) {
      debugPrint('🛑 RealtimeRepositoryEnhancer: Stopped listening for $_endpointName');
    }
  }

  /// Check if currently listening
  bool get isListening => _subscription != null && !_subscription!.isPaused;

  /// Check if real-time service is connected
  bool get isConnected => _realtimeStreams.isConnected;

  /// Request initial data for the endpoint
  Future<void> requestInitialData({Map<String, dynamic>? filters}) async {
    if (!_isInitialized) return;
    await _realtimeStreams.requestEndpointData(_endpointName, filters: filters);
  }

  /// Handle incoming real-time updates
  void _handleUpdate(T update) {
    if (kDebugMode) {
      debugPrint('📡 RealtimeRepositoryEnhancer: Received ${update.type} for $_endpointName');
    }

    switch (update.type) {
      case 'update':
        _onUpdate?.call(update);
        break;
      case 'create':
        _onCreate?.call(update);
        break;
      case 'delete':
        _onDelete?.call(update);
        break;
      case 'bulk_update':
        _onBulkUpdate?.call(update);
        break;
      default:
        if (kDebugMode) {
          debugPrint('⚠️ RealtimeRepositoryEnhancer: Unknown update type: ${update.type}');
        }
    }
  }

  /// Handle errors
  void _handleError(Object error) {
    if (kDebugMode) {
      debugPrint('❌ RealtimeRepositoryEnhancer: Error for $_endpointName: $error');
    }
    _onError?.call(error);
  }

  /// Get the appropriate stream for the endpoint
  Stream<T> _getStreamForEndpoint() {
    switch (_endpointName) {
      case 'projects':
        return _realtimeStreams.projectsStream as Stream<T>;
      case 'tasks':
        return _realtimeStreams.tasksStream as Stream<T>;
      case 'daily-reports':
        return _realtimeStreams.dailyReportsStream as Stream<T>;
      case 'calendar':
        return _realtimeStreams.calendarStream as Stream<T>;
      case 'work-calendar':
        return _realtimeStreams.workCalendarStream as Stream<T>;
      case 'wbs':
        return _realtimeStreams.wbsStream as Stream<T>;
      case 'authorization':
        return _realtimeStreams.authorizationStream as Stream<T>;
      case 'auth':
        return _realtimeStreams.authStream as Stream<T>;
      case 'calendar-management':
        return _realtimeStreams.calendarManagementStream as Stream<T>;
      default:
        throw ArgumentError('Unknown endpoint: $_endpointName');
    }
  }

  /// Dispose resources
  void dispose() {
    stopListening();
    _isInitialized = false;

    if (kDebugMode) {
      debugPrint('🗑️ RealtimeRepositoryEnhancer: Disposed for $_endpointName');
    }
  }
}

/// Mixin to easily add real-time capabilities to any repository
mixin RealtimeEnhancedRepositoryMixin<T extends RealtimeUpdate> {
  late final RealtimeRepositoryEnhancer<T> _realtimeEnhancer;

  /// Endpoint name for this repository - must be implemented by the repository
  String get realtimeEndpointName;

  /// Initialize real-time capabilities
  Future<void> initializeRealtime() async {
    _realtimeEnhancer = RealtimeRepositoryEnhancer<T>(endpointName: realtimeEndpointName);
    await _realtimeEnhancer.initialize();
  }

  /// Start real-time updates with callbacks
  void startRealtimeUpdates({
    Function(T update)? onUpdate,
    Function(T update)? onCreate,
    Function(T update)? onDelete,
    Function(T update)? onBulkUpdate,
    Function(Object error)? onError,
  }) {
    _realtimeEnhancer.startListening(
      onUpdate: onUpdate,
      onCreate: onCreate,
      onDelete: onDelete,
      onBulkUpdate: onBulkUpdate,
      onError: onError,
    );
  }

  /// Stop real-time updates
  void stopRealtimeUpdates() {
    _realtimeEnhancer.stopListening();
  }

  /// Check if real-time is active
  bool get isRealtimeActive => _realtimeEnhancer.isListening;

  /// Check if real-time is connected
  bool get isRealtimeConnected => _realtimeEnhancer.isConnected;

  /// Request initial data
  Future<void> requestRealtimeData({Map<String, dynamic>? filters}) async {
    await _realtimeEnhancer.requestInitialData(filters: filters);
  }

  /// Dispose real-time resources
  void disposeRealtime() {
    _realtimeEnhancer.dispose();
  }
}

/// Factory for creating real-time enhanced repositories
class RealtimeRepositoryFactory {
  /// Create a real-time enhancer for any endpoint
  static RealtimeRepositoryEnhancer<T> createEnhancer<T extends RealtimeUpdate>(String endpointName) {
    return RealtimeRepositoryEnhancer<T>(endpointName: endpointName);
  }

  /// Available endpoints
  static const List<String> availableEndpoints = [
    'projects',
    'tasks',
    'daily-reports',
    'calendar',
    'work-calendar',
    'wbs',
    'authorization',
    'auth',
    'calendar-management',
  ];

  /// Check if endpoint is supported
  static bool isEndpointSupported(String endpoint) {
    return availableEndpoints.contains(endpoint);
  }
}
