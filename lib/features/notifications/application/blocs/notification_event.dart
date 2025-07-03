import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_item.dart';

/// Base class for all notification events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Load notifications with optional filters
class LoadNotifications extends NotificationEvent {
  final int page;
  final int pageSize;
  final bool? unreadOnly;
  final NotificationType? type;
  final bool refresh;

  const LoadNotifications({
    this.page = 1,
    this.pageSize = 20,
    this.unreadOnly,
    this.type,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, pageSize, unreadOnly, type, refresh];
}

/// Load more notifications for pagination
class LoadMoreNotifications extends NotificationEvent {
  const LoadMoreNotifications();
}

/// Load notification count
class LoadNotificationCount extends NotificationEvent {
  const LoadNotificationCount();
}

/// Load notification statistics
class LoadNotificationStatistics extends NotificationEvent {
  const LoadNotificationStatistics();
}

/// Mark a specific notification as read
class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read
class MarkAllNotificationsAsRead extends NotificationEvent {
  const MarkAllNotificationsAsRead();
}

/// Send a test notification
class SendTestNotification extends NotificationEvent {
  final String message;
  final NotificationType type;

  const SendTestNotification({
    required this.message,
    this.type = NotificationType.info,
  });

  @override
  List<Object?> get props => [message, type];
}

/// Send an announcement
class SendAnnouncement extends NotificationEvent {
  final String message;
  final NotificationPriority priority;
  final String targetAudience;

  const SendAnnouncement({
    required this.message,
    this.priority = NotificationPriority.medium,
    this.targetAudience = 'All',
  });

  @override
  List<Object?> get props => [message, priority, targetAudience];
}

/// Test SignalR functionality
class TestSignalR extends NotificationEvent {
  final String message;
  final String? targetUserId;

  const TestSignalR({required this.message, this.targetUserId});

  @override
  List<Object?> get props => [message, targetUserId];
}

/// Delete a notification
class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Filter notifications by type
class FilterNotificationsByType extends NotificationEvent {
  final NotificationType? type;

  const FilterNotificationsByType(this.type);

  @override
  List<Object?> get props => [type];
}

/// Filter notifications by read status
class FilterNotificationsByReadStatus extends NotificationEvent {
  final bool? unreadOnly;

  const FilterNotificationsByReadStatus(this.unreadOnly);

  @override
  List<Object?> get props => [unreadOnly];
}

/// Refresh all notification data
class RefreshNotifications extends NotificationEvent {
  const RefreshNotifications();
}

/// Clear notification filters
class ClearNotificationFilters extends NotificationEvent {
  const ClearNotificationFilters();
}

/// Notification received from SignalR
class NotificationReceived extends NotificationEvent {
  final NotificationItem notification;

  const NotificationReceived(this.notification);

  @override
  List<Object?> get props => [notification];
}
