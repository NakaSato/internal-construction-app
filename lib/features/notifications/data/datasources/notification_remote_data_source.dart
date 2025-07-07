import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/notification.dart';
import '../../domain/entities/notification_settings.dart';
import '../../domain/entities/notifications_response.dart';
import '../../domain/repositories/notification_repository.dart';

/// Remote data source for notifications 
/// Handles all API calls to the notifications endpoints
@LazySingleton()
class NotificationRemoteDataSource {
  final ApiClient _apiClient;
  static const String _baseUrl = '/api/v1/notifications';

  NotificationRemoteDataSource(this._apiClient);

  /// Fetch notifications with filtering and pagination
  Future<NotificationsResponse> getNotifications({
    NotificationsQuery query = const NotificationsQuery(),
  }) async {
    try {
      final queryParams = query.toQueryParameters();
      final response = await _apiClient.dio.get(
        _baseUrl,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return NotificationsResponse.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch notifications',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Get a single notification by ID
  Future<AppNotification> getNotificationById(String notificationId) async {
    try {
      final response = await _apiClient.dio.get('$_baseUrl/$notificationId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return AppNotification.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch notification',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Mark notification as read
  Future<AppNotification> markAsRead(String notificationId) async {
    try {
      final response = await _apiClient.dio.patch('$_baseUrl/$notificationId/read');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return AppNotification.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to mark notification as read',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Mark multiple notifications as read
  Future<BulkNotificationResult> markMultipleAsRead(List<String> notificationIds) async {
    try {
      final response = await _apiClient.dio.patch(
        '$_baseUrl/bulk-read',
        data: {'notificationIds': notificationIds},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return BulkNotificationResult.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to mark notifications as read',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Mark all notifications as read
  Future<BulkNotificationResult> markAllAsRead() async {
    try {
      final response = await _apiClient.dio.patch('$_baseUrl/read-all');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return BulkNotificationResult.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to mark all notifications as read',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await _apiClient.dio.delete('$_baseUrl/$notificationId');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete notification',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Delete multiple notifications
  Future<BulkNotificationResult> deleteMultipleNotifications(List<String> notificationIds) async {
    try {
      final response = await _apiClient.dio.delete(
        '$_baseUrl/bulk-delete',
        data: {'notificationIds': notificationIds},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return BulkNotificationResult.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete notifications',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Get notification statistics
  Future<NotificationCountStatistics> getNotificationStatistics() async {
    try {
      final response = await _apiClient.dio.get('$_baseUrl/count');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return NotificationCountStatistics.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch notification statistics',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final response = await _apiClient.dio.get('$_baseUrl/settings');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return NotificationSettings.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch notification settings',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Update notification settings
  Future<NotificationSettings> updateNotificationSettings(NotificationSettings settings) async {
    try {
      final response = await _apiClient.dio.put(
        '$_baseUrl/settings',
        data: settings.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return NotificationSettings.fromJson(data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update notification settings',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Register device for push notifications
  Future<void> registerDevice({
    required String pushToken,
    required String platform,
    Map<String, dynamic>? deviceInfo,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '$_baseUrl/register-device',
        data: {
          'pushToken': pushToken,
          'platform': platform,
          if (deviceInfo != null) 'deviceInfo': deviceInfo,
          if (preferences != null) 'preferences': preferences,
        },
      );

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to register device',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data?['message'] ?? 'Network error occurred',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
