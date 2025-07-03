import 'package:dio/dio.dart';
import '../models/notification_model.dart';
import '../models/notification_statistics_model.dart';

/// Data source for notification API operations
abstract class NotificationRemoteDataSource {
  /// Get paginated notifications
  Future<NotificationResponseModel> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool? unreadOnly,
    String? type,
  });

  /// Get notification count
  Future<NotificationCountModel> getNotificationCount();

  /// Get notification statistics
  Future<NotificationStatisticsModel> getNotificationStatistics();

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead();

  /// Send test notification
  Future<void> sendTestNotification({
    required String message,
    String type = 'Info',
  });

  /// Send announcement
  Future<void> sendAnnouncement({
    required String message,
    String priority = 'Medium',
    String targetAudience = 'All',
  });

  /// Test SignalR
  Future<void> testSignalR({required String message, String? targetUserId});

  /// Get connection info
  Future<SignalRConnectionInfoModel> getConnectionInfo();

  /// Delete notification
  Future<void> deleteNotification(String notificationId);

  /// Get notification by ID
  Future<NotificationModel> getNotificationById(String notificationId);
}

/// Implementation of notification remote data source
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  NotificationRemoteDataSourceImpl({required this.dio, required this.baseUrl});

  @override
  Future<NotificationResponseModel> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool? unreadOnly,
    String? type,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (unreadOnly != null) {
      queryParameters['unreadOnly'] = unreadOnly;
    }

    if (type != null) {
      queryParameters['type'] = type;
    }

    final response = await dio.get(
      '$baseUrl/api/v1/notifications',
      queryParameters: queryParameters,
    );

    return NotificationResponseModel.fromJson(response.data);
  }

  @override
  Future<NotificationCountModel> getNotificationCount() async {
    final response = await dio.get('$baseUrl/api/v1/notifications/count');
    return NotificationCountModel.fromJson(response.data['data']);
  }

  @override
  Future<NotificationStatisticsModel> getNotificationStatistics() async {
    final response = await dio.get('$baseUrl/api/v1/notifications/statistics');
    return NotificationStatisticsModel.fromJson(response.data['data']);
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await dio.post('$baseUrl/api/v1/notifications/$notificationId/read');
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    await dio.post('$baseUrl/api/v1/notifications/read-all');
  }

  @override
  Future<void> sendTestNotification({
    required String message,
    String type = 'Info',
  }) async {
    await dio.post(
      '$baseUrl/api/v1/notifications/test',
      data: {'message': message, 'type': type},
    );
  }

  @override
  Future<void> sendAnnouncement({
    required String message,
    String priority = 'Medium',
    String targetAudience = 'All',
  }) async {
    await dio.post(
      '$baseUrl/api/v1/notifications/announcement',
      data: {
        'message': message,
        'priority': priority,
        'targetAudience': targetAudience,
      },
    );
  }

  @override
  Future<void> testSignalR({
    required String message,
    String? targetUserId,
  }) async {
    final data = {'message': message};
    if (targetUserId != null) {
      data['targetUserId'] = targetUserId;
    }

    await dio.post('$baseUrl/api/v1/notifications/test-signalr', data: data);
  }

  @override
  Future<SignalRConnectionInfoModel> getConnectionInfo() async {
    final response = await dio.get(
      '$baseUrl/api/v1/notifications/connection-info',
    );
    return SignalRConnectionInfoModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await dio.delete('$baseUrl/api/v1/notifications/$notificationId');
  }

  @override
  Future<NotificationModel> getNotificationById(String notificationId) async {
    final response = await dio.get(
      '$baseUrl/api/v1/notifications/$notificationId',
    );
    return NotificationModel.fromJson(response.data['data']);
  }
}

/// Response model for notification list API
class NotificationResponseModel {
  final bool success;
  final List<NotificationModel> data;
  final NotificationPaginationModel? pagination;

  const NotificationResponseModel({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseModel(
      success: json['success'] ?? false,
      data:
          (json['data'] as List?)
              ?.map((item) => NotificationModel.fromJson(item))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? NotificationPaginationModel.fromJson(json['pagination'])
          : null,
    );
  }
}

/// Pagination model for API responses
class NotificationPaginationModel {
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const NotificationPaginationModel({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory NotificationPaginationModel.fromJson(Map<String, dynamic> json) {
    return NotificationPaginationModel(
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

/// SignalR connection info model
class SignalRConnectionInfoModel {
  final String hubUrl;
  final bool isEnabled;
  final int activeConnections;
  final List<String> availableGroups;

  const SignalRConnectionInfoModel({
    required this.hubUrl,
    required this.isEnabled,
    required this.activeConnections,
    required this.availableGroups,
  });

  factory SignalRConnectionInfoModel.fromJson(Map<String, dynamic> json) {
    return SignalRConnectionInfoModel(
      hubUrl: json['hubUrl'] ?? '',
      isEnabled: json['isEnabled'] ?? false,
      activeConnections: json['activeConnections'] ?? 0,
      availableGroups: List<String>.from(json['availableGroups'] ?? []),
    );
  }
}
