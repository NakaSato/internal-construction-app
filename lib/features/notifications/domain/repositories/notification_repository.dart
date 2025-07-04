import '../entities/notification.dart';

/// Repository interface for notification operations
abstract class NotificationRepository {
  /// Get all notifications for the authenticated user
  Future<List<AppNotification>> getNotifications();

  /// Mark a specific notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Delete a specific notification
  Future<void> deleteNotification(String notificationId);

  /// Get the count of unread notifications
  Future<int> getUnreadCount();
}
