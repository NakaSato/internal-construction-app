part of 'notification_cubit.dart';

/// Base state for notifications
abstract class NotificationState extends Equatable {
  final int unreadCount;
  
  const NotificationState({this.unreadCount = 0});
  
  @override
  List<Object?> get props => [unreadCount];
}

/// Initial state when the notification system starts
class NotificationInitial extends NotificationState {
  const NotificationInitial({super.unreadCount});
  
  @override
  List<Object?> get props => [unreadCount];
}

/// Loading state when fetching notifications
class NotificationLoading extends NotificationState {
  const NotificationLoading({super.unreadCount});
  
  @override
  List<Object?> get props => [unreadCount];
}

/// Loaded state with notifications data
class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;
  final bool hasMoreToLoad;
  final int currentPage;
  final int totalItems;
  final bool isLoadingMore;
  final bool isUpdating;
  final String? error;
  final NotificationSummary? summary;
  final bool hasNewNotifications;
  
  const NotificationLoaded({
    required this.notifications,
    required super.unreadCount,
    this.hasMoreToLoad = false,
    this.currentPage = 1,
    this.totalItems = 0,
    this.isLoadingMore = false,
    this.isUpdating = false,
    this.error,
    this.summary,
    this.hasNewNotifications = false,
  });
  
  /// Create a copy with updated fields
  NotificationLoaded copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? hasMoreToLoad,
    int? currentPage,
    int? totalItems,
    bool? isLoadingMore,
    bool? isUpdating,
    String? error,
    NotificationSummary? summary,
    bool? hasNewNotifications,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMoreToLoad: hasMoreToLoad ?? this.hasMoreToLoad,
      currentPage: currentPage ?? this.currentPage,
      totalItems: totalItems ?? this.totalItems,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,  // null will clear the error
      summary: summary ?? this.summary,
      hasNewNotifications: hasNewNotifications ?? this.hasNewNotifications,
    );
  }
  
  @override
  List<Object?> get props => [
    notifications, 
    unreadCount, 
    hasMoreToLoad, 
    currentPage, 
    totalItems, 
    isLoadingMore, 
    isUpdating, 
    error,
    summary,
    hasNewNotifications,
  ];
}

/// Error state when notification operations fail
class NotificationError extends NotificationState {
  final String message;
  
  const NotificationError(this.message, {super.unreadCount});
  
  @override
  List<Object?> get props => [message, unreadCount];
}
