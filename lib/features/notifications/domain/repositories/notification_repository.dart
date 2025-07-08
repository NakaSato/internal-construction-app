import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/notification.dart';
import '../entities/notification_settings.dart';
import '../entities/notifications_response.dart';

/// Query parameters for fetching notifications
class NotificationsQuery {
  const NotificationsQuery({
    this.pageNumber = 1,
    this.pageSize = 20,
    this.isRead,
    this.type,
    this.priority,
    this.category,
    this.startDate,
    this.endDate,
    this.includeSummary = false,
    this.includeExpired = false,
  });

  /// The page number (1-based)
  final int pageNumber;

  /// Number of items per page
  final int pageSize;

  /// Filter by read status (null for both)
  final bool? isRead;

  /// Filter by notification type
  final NotificationType? type;

  /// Filter by notification priority
  final NotificationPriority? priority;

  /// Filter by category
  final String? category;

  /// Filter by start date (created on or after)
  final DateTime? startDate;

  /// Filter by end date (created on or before)
  final DateTime? endDate;

  /// Whether to include summary statistics
  final bool includeSummary;

  /// Whether to include expired notifications
  final bool includeExpired;

  /// Convert query to parameters for API request
  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      'includeSummary': includeSummary.toString(),
      'includeExpired': includeExpired.toString(),
    };

    if (isRead != null) params['isRead'] = isRead.toString();
    if (type != null) params['type'] = type!.value;
    if (priority != null) params['priority'] = priority!.value;
    if (category != null) params['category'] = category!;
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();

    return params;
  }

  /// Create a copy with some fields replaced
  NotificationsQuery copyWith({
    int? pageNumber,
    int? pageSize,
    bool? isRead,
    NotificationType? type,
    NotificationPriority? priority,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    bool? includeSummary,
    bool? includeExpired,
  }) {
    return NotificationsQuery(
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      includeSummary: includeSummary ?? this.includeSummary,
      includeExpired: includeExpired ?? this.includeExpired,
    );
  }
}

/// Repository interface for notification operations
abstract class NotificationRepository {
  /// Get notifications for the authenticated user with filtering and pagination
  ///
  /// Returns a NotificationsResponse with items and pagination metadata
  Future<Either<Failure, NotificationsResponse>> getNotifications({
    NotificationsQuery query = const NotificationsQuery(),
  });

  /// Get a single notification by ID
  Future<Either<Failure, AppNotification>> getNotificationById(String notificationId);

  /// Mark a specific notification as read
  Future<Either<Failure, AppNotification>> markAsRead(String notificationId);

  /// Mark multiple notifications as read
  Future<Either<Failure, BulkNotificationResult>> markMultipleAsRead(List<String> notificationIds);

  /// Mark all notifications as read
  Future<Either<Failure, BulkNotificationResult>> markAllAsRead();

  /// Delete a specific notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Delete multiple notifications
  Future<Either<Failure, BulkNotificationResult>> deleteMultipleNotifications(List<String> notificationIds);

  /// Get notification statistics
  Future<Either<Failure, NotificationCountStatistics>> getNotificationStatistics();

  /// Get notification settings for the current user
  Future<Either<Failure, NotificationSettings>> getNotificationSettings();

  /// Update notification settings
  Future<Either<Failure, NotificationSettings>> updateNotificationSettings(NotificationSettings settings);

  /// Get the real-time notification stream
  Stream<AppNotification> getNotificationStream();

  /// Get the unread notification count stream
  Stream<int> getUnreadCountStream();
}
