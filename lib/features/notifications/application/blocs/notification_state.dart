import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_item.dart';
import '../../domain/entities/notification_statistics.dart';
import '../../domain/entities/notification_pagination.dart';

/// Base class for all notification states
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state when notification bloc is created
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state for general operations
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// State when notifications are successfully loaded
class NotificationLoaded extends NotificationState {
  final List<NotificationItem> notifications;
  final NotificationPagination? pagination;
  final NotificationCount? count;
  final NotificationStatistics? statistics;
  final bool isLoadingMore;
  final NotificationType? currentTypeFilter;
  final bool? currentUnreadFilter;

  const NotificationLoaded({
    required this.notifications,
    this.pagination,
    this.count,
    this.statistics,
    this.isLoadingMore = false,
    this.currentTypeFilter,
    this.currentUnreadFilter,
  });

  /// Create a copy with updated values
  NotificationLoaded copyWith({
    List<NotificationItem>? notifications,
    NotificationPagination? pagination,
    NotificationCount? count,
    NotificationStatistics? statistics,
    bool? isLoadingMore,
    NotificationType? currentTypeFilter,
    bool? currentUnreadFilter,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      pagination: pagination ?? this.pagination,
      count: count ?? this.count,
      statistics: statistics ?? this.statistics,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentTypeFilter: currentTypeFilter ?? this.currentTypeFilter,
      currentUnreadFilter: currentUnreadFilter ?? this.currentUnreadFilter,
    );
  }

  /// Check if there are more pages to load
  bool get hasMorePages => pagination?.hasNextPage ?? false;

  /// Check if there are unread notifications
  bool get hasUnreadNotifications => count?.hasUnread ?? false;

  /// Get unread count
  int get unreadCount => count?.unreadCount ?? 0;

  /// Get total count
  int get totalCount => count?.totalCount ?? notifications.length;

  @override
  List<Object?> get props => [
    notifications,
    pagination,
    count,
    statistics,
    isLoadingMore,
    currentTypeFilter,
    currentUnreadFilter,
  ];
}

/// State when notification count is loaded
class NotificationCountLoaded extends NotificationState {
  final NotificationCount count;

  const NotificationCountLoaded(this.count);

  @override
  List<Object?> get props => [count];
}

/// State when notification statistics are loaded
class NotificationStatisticsLoaded extends NotificationState {
  final NotificationStatistics statistics;

  const NotificationStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

/// State when an operation is successful
class NotificationOperationSuccess extends NotificationState {
  final String message;

  const NotificationOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when an error occurs
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when marking notification as read
class NotificationMarkingAsRead extends NotificationState {
  final String notificationId;

  const NotificationMarkingAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// State when marking all notifications as read
class NotificationMarkingAllAsRead extends NotificationState {
  const NotificationMarkingAllAsRead();
}

/// State when sending test notification
class NotificationSendingTest extends NotificationState {
  const NotificationSendingTest();
}

/// State when sending announcement
class NotificationSendingAnnouncement extends NotificationState {
  const NotificationSendingAnnouncement();
}

/// State when testing SignalR
class NotificationTestingSignalR extends NotificationState {
  const NotificationTestingSignalR();
}

/// State when deleting notification
class NotificationDeleting extends NotificationState {
  final String notificationId;

  const NotificationDeleting(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// State when a new notification is received via SignalR
class NotificationReceivedState extends NotificationState {
  final NotificationItem notification;

  const NotificationReceivedState(this.notification);

  @override
  List<Object?> get props => [notification];
}
