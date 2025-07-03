import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_item.dart';
import '../entities/notification_statistics.dart';
import '../entities/notification_pagination.dart';

/// Repository interface for notification operations
abstract class NotificationRepository {
  /// Get paginated list of notifications for the authenticated user
  ///
  /// [page] - Page number (1-based)
  /// [pageSize] - Number of items per page
  /// [unreadOnly] - If true, only return unread notifications
  /// [type] - Filter by notification type
  Future<Either<Failure, NotificationListResult>> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool? unreadOnly,
    NotificationType? type,
  });

  /// Get notification count information
  Future<Either<Failure, NotificationCount>> getNotificationCount();

  /// Get detailed notification statistics
  Future<Either<Failure, NotificationStatistics>> getNotificationStatistics();

  /// Mark a specific notification as read
  ///
  /// [notificationId] - ID of the notification to mark as read
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId);

  /// Mark all notifications as read for the current user
  Future<Either<Failure, void>> markAllNotificationsAsRead();

  /// Send a test notification (for testing purposes)
  ///
  /// [message] - Test message content
  /// [type] - Type of notification to send
  Future<Either<Failure, void>> sendTestNotification({
    required String message,
    NotificationType type = NotificationType.info,
  });

  /// Send an announcement to all users or specific audience
  ///
  /// [message] - Announcement message
  /// [priority] - Priority level of the announcement
  /// [targetAudience] - Target audience (All, Admins, etc.)
  Future<Either<Failure, void>> sendAnnouncement({
    required String message,
    NotificationPriority priority = NotificationPriority.medium,
    String targetAudience = 'All',
  });

  /// Test SignalR functionality
  ///
  /// [message] - Test message to send
  /// [targetUserId] - Optional specific user ID to target
  Future<Either<Failure, void>> testSignalR({
    required String message,
    String? targetUserId,
  });

  /// Get SignalR connection information
  Future<Either<Failure, SignalRConnectionInfo>> getConnectionInfo();

  /// Delete a notification
  ///
  /// [notificationId] - ID of the notification to delete
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Get a specific notification by ID
  ///
  /// [notificationId] - ID of the notification to retrieve
  Future<Either<Failure, NotificationItem>> getNotificationById(
    String notificationId,
  );
}

/// Result containing notifications and pagination info
class NotificationListResult {
  /// List of notifications
  final List<NotificationItem> notifications;

  /// Pagination information
  final NotificationPagination? pagination;

  const NotificationListResult({required this.notifications, this.pagination});
}

/// SignalR connection information
class SignalRConnectionInfo {
  /// Hub URL for SignalR connection
  final String hubUrl;

  /// Whether SignalR is enabled
  final bool isEnabled;

  /// Number of active connections
  final int activeConnections;

  /// List of available groups
  final List<String> availableGroups;

  const SignalRConnectionInfo({
    required this.hubUrl,
    required this.isEnabled,
    required this.activeConnections,
    required this.availableGroups,
  });
}
