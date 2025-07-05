import 'dart:async';
import 'package:flutter/foundation.dart';

import '../services/realtime_api_streams.dart';
import '../../core/di/injection.dart';

/// Mixin to add real-time capabilities to existing API repositories
/// Provides easy integration of real-time updates for any API service
mixin RealtimeApiMixin {
  StreamSubscription? _realtimeSubscription;

  /// Endpoint name for this repository
  String get endpointName;

  /// Start listening to real-time updates for this endpoint
  void startRealtimeUpdates<T extends RealtimeUpdate>({
    required Function(T update) onUpdate,
    Function(Object error)? onError,
  }) {
    final realtimeStreams = getIt<RealtimeApiStreams>();

    _realtimeSubscription?.cancel();

    // Get the appropriate stream based on endpoint name
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
        if (kDebugMode) {
          debugPrint('⚠️ RealtimeApiMixin: Unknown endpoint: $endpointName');
        }
        return;
    }

    _realtimeSubscription = stream.listen(
      onUpdate,
      onError: (error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeApiMixin: Stream error for $endpointName: $error');
        }
        onError?.call(error);
      },
    );

    if (kDebugMode) {
      debugPrint('✅ RealtimeApiMixin: Started real-time updates for $endpointName');
    }
  }

  /// Stop listening to real-time updates
  void stopRealtimeUpdates() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = null;

    if (kDebugMode) {
      debugPrint('🛑 RealtimeApiMixin: Stopped real-time updates for $endpointName');
    }
  }

  /// Check if real-time updates are active
  bool get isRealtimeActive => _realtimeSubscription != null && !_realtimeSubscription!.isPaused;

  /// Request initial data for this endpoint
  Future<void> requestInitialData({Map<String, dynamic>? filters}) async {
    final realtimeStreams = getIt<RealtimeApiStreams>();
    await realtimeStreams.requestEndpointData(endpointName, filters: filters);
  }

  /// Dispose real-time resources
  void disposeRealtime() {
    stopRealtimeUpdates();
  }
}

/// Helper class for integrating real-time updates into existing BLoCs
class RealtimeBlocHelper<T> {
  final Function(T data) onUpdate;
  final String endpointName;

  RealtimeBlocHelper({required this.endpointName, required this.onUpdate});

  /// Start real-time updates for BLoC
  static StreamSubscription<T> startBlocUpdates<T extends RealtimeUpdate>({
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

/// Extension to add real-time capabilities to any existing repository
extension RealtimeRepositoryExtension on Object {
  /// Quick setup for real-time updates in any repository
  StreamSubscription? listenToRealtimeUpdates<T extends RealtimeUpdate>({
    required String endpointName,
    required Function(T update) onUpdate,
    Function(Object error)? onError,
  }) {
    return RealtimeBlocHelper.startBlocUpdates<T>(endpointName: endpointName, onUpdate: onUpdate, onError: onError);
  }
}
