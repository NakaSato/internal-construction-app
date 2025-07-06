import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'unified_realtime_api_service.dart';
import '../../features/projects/domain/entities/project_api_models.dart';

/// Real-time data streams for all API endpoints
/// Provides typed streams and helper methods for each endpoint
@LazySingleton()
class RealtimeApiStreams {
  final UnifiedRealtimeApiService _unifiedService;

  RealtimeApiStreams(this._unifiedService);

  /// Projects real-time stream
  Stream<RealtimeProjectUpdate> get projectsStream => _unifiedService
      .getEndpointStream(UnifiedRealtimeApiService.projectsEndpoint)
      .map((data) => RealtimeProjectUpdate.fromJson(data))
      .handleError((error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeApiStreams: Projects stream error: $error');
        }
      });

  /// Tasks real-time stream
  Stream<RealtimeTaskUpdate> get tasksStream => _unifiedService
      .getEndpointStream(UnifiedRealtimeApiService.tasksEndpoint)
      .map((data) => RealtimeTaskUpdate.fromJson(data))
      .handleError((error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeApiStreams: Tasks stream error: $error');
        }
      });

  /// Daily reports real-time stream
  Stream<RealtimeDailyReportUpdate> get dailyReportsStream => _unifiedService
      .getEndpointStream(UnifiedRealtimeApiService.dailyReportsEndpoint)
      .map((data) => RealtimeDailyReportUpdate.fromJson(data))
      .handleError((error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeApiStreams: Daily reports stream error: $error');
        }
      });

  /// Calendar real-time stream
  Stream<RealtimeCalendarUpdate> get calendarStream => _unifiedService
      .getEndpointStream(UnifiedRealtimeApiService.calendarEndpoint)
      .map((data) => RealtimeCalendarUpdate.fromJson(data))
      .handleError((error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeApiStreams: Calendar stream error: $error');
        }
      });

  /// Work calendar real-time stream
  Stream<RealtimeWorkCalendarUpdate> get workCalendarStream => _unifiedService
      .getEndpointStream(UnifiedRealtimeApiService.workCalendarEndpoint)
      .map((data) => RealtimeWorkCalendarUpdate.fromJson(data))
      .handleError((error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeApiStreams: Work calendar stream error: $error');
        }
      });

  /// WBS real-time stream
  Stream<RealtimeWbsUpdate> get wbsStream => _unifiedService
      .getEndpointStream(UnifiedRealtimeApiService.wbsEndpoint)
      .map((data) => RealtimeWbsUpdate.fromJson(data))
      .handleError((error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeApiStreams: WBS stream error: $error');
        }
      });

  /// Authorization real-time stream
  Stream<RealtimeAuthorizationUpdate> get authorizationStream => _unifiedService
      .getEndpointStream(UnifiedRealtimeApiService.authorizationEndpoint)
      .map((data) => RealtimeAuthorizationUpdate.fromJson(data))
      .handleError((error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeApiStreams: Authorization stream error: $error');
        }
      });

  /// Authentication real-time stream
  Stream<RealtimeAuthUpdate> get authStream => _unifiedService
      .getEndpointStream(UnifiedRealtimeApiService.authEndpoint)
      .map((data) => RealtimeAuthUpdate.fromJson(data))
      .handleError((error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeApiStreams: Auth stream error: $error');
        }
      });

  /// Calendar management real-time stream
  Stream<RealtimeCalendarManagementUpdate> get calendarManagementStream => _unifiedService
      .getEndpointStream(UnifiedRealtimeApiService.calendarManagementEndpoint)
      .map((data) => RealtimeCalendarManagementUpdate.fromJson(data))
      .handleError((error) {
        if (kDebugMode) {
          debugPrint('❌ RealtimeApiStreams: Calendar management stream error: $error');
        }
      });

  /// Initialize connection and subscribe to all streams
  Future<void> initialize() async {
    await _unifiedService.connect();
  }

  /// Subscribe to specific endpoints only
  Future<void> subscribeToEndpoints(List<String> endpoints) async {
    await _unifiedService.subscribeToEndpoints(endpoints);
  }

  /// Request initial data for specific endpoint
  Future<void> requestEndpointData(String endpoint, {Map<String, dynamic>? filters}) async {
    await _unifiedService.requestEndpointData(endpoint, filters: filters);
  }

  /// Check if real-time service is connected
  bool get isConnected => _unifiedService.isConnected;

  /// Dispose all resources
  void dispose() {
    _unifiedService.dispose();
  }
}

/// Base class for all real-time updates
abstract class RealtimeUpdate {
  final String type;
  final String endpoint;
  final DateTime timestamp;

  RealtimeUpdate({required this.type, required this.endpoint, required this.timestamp});
}

/// Real-time project update model
class RealtimeProjectUpdate extends RealtimeUpdate {
  final Map<String, dynamic> data;
  final Project? project;
  final String? projectId;

  RealtimeProjectUpdate({
    required super.type,
    required super.endpoint,
    required super.timestamp,
    required this.data,
    this.project,
    this.projectId,
  });

  factory RealtimeProjectUpdate.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;
      Project? project;
      String? projectId;

      if (data.containsKey('project')) {
        project = Project.fromJson(data['project']);
      }

      if (data.containsKey('projectId')) {
        projectId = data['projectId'] as String;
      }

      return RealtimeProjectUpdate(
        type: json['type'] as String,
        endpoint: json['endpoint'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        data: data,
        project: project,
        projectId: projectId,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RealtimeProjectUpdate.fromJson error: $e');
      }
      rethrow;
    }
  }
}

/// Real-time task update model
class RealtimeTaskUpdate extends RealtimeUpdate {
  final Map<String, dynamic> data;
  final String? taskId;
  final String? projectId;

  RealtimeTaskUpdate({
    required super.type,
    required super.endpoint,
    required super.timestamp,
    required this.data,
    this.taskId,
    this.projectId,
  });

  factory RealtimeTaskUpdate.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;

      return RealtimeTaskUpdate(
        type: json['type'] as String,
        endpoint: json['endpoint'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        data: data,
        taskId: data['taskId'] as String?,
        projectId: data['projectId'] as String?,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RealtimeTaskUpdate.fromJson error: $e');
      }
      rethrow;
    }
  }
}

/// Real-time daily report update model
class RealtimeDailyReportUpdate extends RealtimeUpdate {
  final Map<String, dynamic> data;
  final String? reportId;
  final String? projectId;

  RealtimeDailyReportUpdate({
    required super.type,
    required super.endpoint,
    required super.timestamp,
    required this.data,
    this.reportId,
    this.projectId,
  });

  factory RealtimeDailyReportUpdate.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;

      return RealtimeDailyReportUpdate(
        type: json['type'] as String,
        endpoint: json['endpoint'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        data: data,
        reportId: data['reportId'] as String?,
        projectId: data['projectId'] as String?,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RealtimeDailyReportUpdate.fromJson error: $e');
      }
      rethrow;
    }
  }
}

/// Real-time calendar update model
class RealtimeCalendarUpdate extends RealtimeUpdate {
  final Map<String, dynamic> data;
  final String? eventId;

  RealtimeCalendarUpdate({
    required super.type,
    required super.endpoint,
    required super.timestamp,
    required this.data,
    this.eventId,
  });

  factory RealtimeCalendarUpdate.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;

      return RealtimeCalendarUpdate(
        type: json['type'] as String,
        endpoint: json['endpoint'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        data: data,
        eventId: data['eventId'] as String?,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RealtimeCalendarUpdate.fromJson error: $e');
      }
      rethrow;
    }
  }
}

/// Real-time work calendar update model
class RealtimeWorkCalendarUpdate extends RealtimeUpdate {
  final Map<String, dynamic> data;
  final String? scheduleId;
  final String? projectId;

  RealtimeWorkCalendarUpdate({
    required super.type,
    required super.endpoint,
    required super.timestamp,
    required this.data,
    this.scheduleId,
    this.projectId,
  });

  factory RealtimeWorkCalendarUpdate.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;

      return RealtimeWorkCalendarUpdate(
        type: json['type'] as String,
        endpoint: json['endpoint'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        data: data,
        scheduleId: data['scheduleId'] as String?,
        projectId: data['projectId'] as String?,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RealtimeWorkCalendarUpdate.fromJson error: $e');
      }
      rethrow;
    }
  }
}

/// Real-time WBS update model
class RealtimeWbsUpdate extends RealtimeUpdate {
  final Map<String, dynamic> data;
  final String? wbsId;
  final String? projectId;

  RealtimeWbsUpdate({
    required super.type,
    required super.endpoint,
    required super.timestamp,
    required this.data,
    this.wbsId,
    this.projectId,
  });

  factory RealtimeWbsUpdate.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;

      return RealtimeWbsUpdate(
        type: json['type'] as String,
        endpoint: json['endpoint'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        data: data,
        wbsId: data['wbsId'] as String?,
        projectId: data['projectId'] as String?,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RealtimeWbsUpdate.fromJson error: $e');
      }
      rethrow;
    }
  }
}

/// Real-time authorization update model
class RealtimeAuthorizationUpdate extends RealtimeUpdate {
  final Map<String, dynamic> data;
  final String? userId;
  final String? roleId;

  RealtimeAuthorizationUpdate({
    required super.type,
    required super.endpoint,
    required super.timestamp,
    required this.data,
    this.userId,
    this.roleId,
  });

  factory RealtimeAuthorizationUpdate.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;

      return RealtimeAuthorizationUpdate(
        type: json['type'] as String,
        endpoint: json['endpoint'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        data: data,
        userId: data['userId'] as String?,
        roleId: data['roleId'] as String?,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RealtimeAuthorizationUpdate.fromJson error: $e');
      }
      rethrow;
    }
  }
}

/// Real-time authentication update model
class RealtimeAuthUpdate extends RealtimeUpdate {
  final Map<String, dynamic> data;
  final String? userId;

  RealtimeAuthUpdate({
    required super.type,
    required super.endpoint,
    required super.timestamp,
    required this.data,
    this.userId,
  });

  factory RealtimeAuthUpdate.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;

      return RealtimeAuthUpdate(
        type: json['type'] as String,
        endpoint: json['endpoint'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        data: data,
        userId: data['userId'] as String?,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RealtimeAuthUpdate.fromJson error: $e');
      }
      rethrow;
    }
  }
}

/// Real-time calendar management update model
class RealtimeCalendarManagementUpdate extends RealtimeUpdate {
  final Map<String, dynamic> data;
  final String? calendarId;

  RealtimeCalendarManagementUpdate({
    required super.type,
    required super.endpoint,
    required super.timestamp,
    required this.data,
    this.calendarId,
  });

  factory RealtimeCalendarManagementUpdate.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] as Map<String, dynamic>;

      return RealtimeCalendarManagementUpdate(
        type: json['type'] as String,
        endpoint: json['endpoint'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        data: data,
        calendarId: data['calendarId'] as String?,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ RealtimeCalendarManagementUpdate.fromJson error: $e');
      }
      rethrow;
    }
  }
}
