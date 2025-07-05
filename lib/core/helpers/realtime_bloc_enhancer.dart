import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/realtime_api_streams.dart';
import '../di/injection.dart';

/// Enhanced BLoC helper for real-time updates
/// Provides easy integration of real-time capabilities into any BLoC
class RealtimeBlocEnhancer<T extends RealtimeUpdate> {
  final String endpointName;
  late final RealtimeApiStreams _realtimeStreams;
  StreamSubscription<T>? _subscription;
  bool _isInitialized = false;

  RealtimeBlocEnhancer({required this.endpointName});

  /// Initialize the real-time enhancer
  Future<void> initialize() async {
    if (_isInitialized) return;

    _realtimeStreams = getIt<RealtimeApiStreams>();
    await _realtimeStreams.initialize();

    _isInitialized = true;

    if (kDebugMode) {
      debugPrint('✅ RealtimeBlocEnhancer: Initialized for $endpointName');
    }
  }

  /// Start listening with a BLoC event handler
  void startListening<E>({
    required Emitter<dynamic> emitter,
    required E Function(T update) createEvent,
    required void Function(E event) addEvent,
    Function(Object error)? onError,
  }) {
    if (!_isInitialized) {
      throw StateError('RealtimeBlocEnhancer must be initialized before starting to listen');
    }

    _subscription?.cancel();
    _subscription = _getStreamForEndpoint().listen(
      (update) {
        final event = createEvent(update);
        addEvent(event);

        if (kDebugMode) {
          debugPrint('📡 RealtimeBlocEnhancer: Dispatched event for $endpointName: ${update.type}');
        }
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeBlocEnhancer: Error for $endpointName: $error');
        }
        onError?.call(error);
      },
    );

    if (kDebugMode) {
      debugPrint('🎧 RealtimeBlocEnhancer: Started listening for $endpointName');
    }
  }

  /// Start listening with direct state emission
  void startListeningWithDirectEmission({
    required Emitter<dynamic> emitter,
    required Function(T update, Emitter<dynamic> emitter) onUpdate,
    Function(Object error)? onError,
  }) {
    if (!_isInitialized) {
      throw StateError('RealtimeBlocEnhancer must be initialized before starting to listen');
    }

    _subscription?.cancel();
    _subscription = _getStreamForEndpoint().listen(
      (update) {
        onUpdate(update, emitter);

        if (kDebugMode) {
          debugPrint('📡 RealtimeBlocEnhancer: Direct emission for $endpointName: ${update.type}');
        }
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeBlocEnhancer: Error for $endpointName: $error');
        }
        onError?.call(error);
      },
    );

    if (kDebugMode) {
      debugPrint('🎧 RealtimeBlocEnhancer: Started direct listening for $endpointName');
    }
  }

  /// Stop listening
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;

    if (kDebugMode) {
      debugPrint('🛑 RealtimeBlocEnhancer: Stopped listening for $endpointName');
    }
  }

  /// Check if listening
  bool get isListening => _subscription != null && !_subscription!.isPaused;

  /// Check if connected
  bool get isConnected => _realtimeStreams.isConnected;

  /// Request initial data
  Future<void> requestInitialData({Map<String, dynamic>? filters}) async {
    if (!_isInitialized) return;
    await _realtimeStreams.requestEndpointData(endpointName, filters: filters);
  }

  /// Get the appropriate stream for the endpoint
  Stream<T> _getStreamForEndpoint() {
    switch (endpointName) {
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
        throw ArgumentError('Unknown endpoint: $endpointName');
    }
  }

  /// Dispose
  void dispose() {
    stopListening();
    _isInitialized = false;

    if (kDebugMode) {
      debugPrint('🗑️ RealtimeBlocEnhancer: Disposed for $endpointName');
    }
  }
}

/// Mixin for BLoCs to easily add real-time capabilities
mixin RealtimeEnhancedBlocMixin<E, S, T extends RealtimeUpdate> on BlocBase<S> {
  late final RealtimeBlocEnhancer<T> _realtimeEnhancer;

  /// Endpoint name for this BLoC - must be implemented by the BLoC
  String get realtimeEndpointName;

  /// Initialize real-time capabilities
  Future<void> initializeRealtime() async {
    _realtimeEnhancer = RealtimeBlocEnhancer<T>(endpointName: realtimeEndpointName);
    await _realtimeEnhancer.initialize();
  }

  /// Start real-time updates that dispatch events
  void startRealtimeUpdates({
    required Emitter<S> emitter,
    required E Function(T update) createEvent,
    required void Function(E event) addEvent,
    Function(Object error)? onError,
  }) {
    _realtimeEnhancer.startListening(emitter: emitter, createEvent: createEvent, addEvent: addEvent, onError: onError);
  }

  /// Start real-time updates with direct state emission
  void startRealtimeUpdatesWithDirectEmission({
    required Emitter<S> emitter,
    required Function(T update, Emitter<S> emitter) onUpdate,
    Function(Object error)? onError,
  }) {
    _realtimeEnhancer.startListeningWithDirectEmission(
      emitter: emitter,
      onUpdate: (update, emit) => onUpdate(update, emitter),
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

/// Helper class for creating real-time events in BLoCs
class RealtimeEventHelper {
  /// Create a generic real-time update event
  static Map<String, dynamic> createUpdateEvent<T extends RealtimeUpdate>(T update) {
    return {
      'type': 'realtime_update',
      'updateType': update.type,
      'endpoint': update.endpoint,
      'timestamp': update.timestamp,
      'data': update,
    };
  }

  /// Create event data for specific update types
  static Map<String, dynamic> createProjectUpdateEvent(RealtimeProjectUpdate update) {
    return createUpdateEvent(update)..addAll({'projectId': update.projectId, 'project': update.project});
  }

  static Map<String, dynamic> createTaskUpdateEvent(RealtimeTaskUpdate update) {
    return createUpdateEvent(update)..addAll({'taskId': update.taskId, 'projectId': update.projectId});
  }

  static Map<String, dynamic> createDailyReportUpdateEvent(RealtimeDailyReportUpdate update) {
    return createUpdateEvent(update)..addAll({'reportId': update.reportId, 'projectId': update.projectId});
  }
}

/// Extension to add real-time capabilities to any existing BLoC
extension RealtimeBlocExtension<E, S> on BlocBase<S> {
  /// Quick setup for real-time updates in any BLoC
  StreamSubscription<T>? listenToRealtimeUpdates<T extends RealtimeUpdate>({
    required String endpointName,
    required Function(T update) onUpdate,
    Function(Object error)? onError,
  }) {
    final realtimeStreams = getIt<RealtimeApiStreams>();
    Stream<T> stream;

    switch (endpointName) {
      case 'projects':
        stream = realtimeStreams.projectsStream as Stream<T>;
        break;
      case 'tasks':
        stream = realtimeStreams.tasksStream as Stream<T>;
        break;
      case 'daily-reports':
        stream = realtimeStreams.dailyReportsStream as Stream<T>;
        break;
      case 'calendar':
        stream = realtimeStreams.calendarStream as Stream<T>;
        break;
      case 'work-calendar':
        stream = realtimeStreams.workCalendarStream as Stream<T>;
        break;
      case 'wbs':
        stream = realtimeStreams.wbsStream as Stream<T>;
        break;
      case 'authorization':
        stream = realtimeStreams.authorizationStream as Stream<T>;
        break;
      case 'auth':
        stream = realtimeStreams.authStream as Stream<T>;
        break;
      case 'calendar-management':
        stream = realtimeStreams.calendarManagementStream as Stream<T>;
        break;
      default:
        throw ArgumentError('Unknown endpoint: $endpointName');
    }

    return stream.listen(onUpdate, onError: onError);
  }
}
