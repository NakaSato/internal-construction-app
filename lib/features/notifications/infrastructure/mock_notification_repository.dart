import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../domain/entities/notification.dart';
import '../domain/entities/notification_settings.dart';
import '../domain/entities/notifications_response.dart';
import '../domain/repositories/notification_repository.dart';

/// Mock notification repository for development and testing
class MockNotificationRepository implements NotificationRepository {
  late final List<AppNotification> _notifications;
  final StreamController<AppNotification> _notificationStreamController = StreamController<AppNotification>.broadcast();
  final StreamController<int> _unreadCountStreamController = StreamController<int>.broadcast();

  MockNotificationRepository() {
    // Initialize notifications list
    _notifications = _generateMockNotifications();

    // Initialize stream with current unread count
    _updateUnreadCountStream();

    // Simulate occasional new notifications
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _simulateNewNotification();
    });
  }

  void _simulateNewNotification() {
    final now = DateTime.now();
    final newNotification = AppNotification(
      id: 'simulated-${now.millisecondsSinceEpoch}',
      title: 'New Activity',
      message: 'A new update has been posted to your project.',
      type: NotificationType.projectUpdate,
      createdAt: now,
      isRead: false,
      priority: NotificationPriority.medium,
      category: 'Project',
      actionUrl: '/projects/123',
    );

    _notifications.insert(0, newNotification);
    _notificationStreamController.add(newNotification);
    _updateUnreadCountStream();
  }

  void _updateUnreadCountStream() {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    _unreadCountStreamController.add(unreadCount);
  }

  @override
  Future<Either<Failure, NotificationsResponse>> getNotifications({
    NotificationsQuery query = const NotificationsQuery(),
  }) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay

    // Apply filters
    var filteredNotifications = _notifications.where((notification) {
      // Filter by read status
      if (query.isRead != null && notification.isRead != query.isRead) {
        return false;
      }

      // Filter by type
      if (query.type != null && notification.type != query.type) {
        return false;
      }

      // Filter by priority
      if (query.priority != null && notification.priority != query.priority) {
        return false;
      }

      // Filter by category
      if (query.category != null && notification.category != query.category) {
        return false;
      }

      // Filter by date range
      if (query.startDate != null && notification.createdAt.isBefore(query.startDate!)) {
        return false;
      }

      if (query.endDate != null && notification.createdAt.isAfter(query.endDate!)) {
        return false;
      }

      // Filter expired notifications
      if (!query.includeExpired && notification.expiresAt != null && DateTime.now().isAfter(notification.expiresAt!)) {
        return false;
      }

      return true;
    }).toList();

    // Sort by createdAt descending (newest first) by default
    filteredNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Calculate pagination
    final totalCount = filteredNotifications.length;
    final totalPages = (totalCount / query.pageSize).ceil();
    final startIndex = (query.pageNumber - 1) * query.pageSize;
    final endIndex = startIndex + query.pageSize > totalCount ? totalCount : startIndex + query.pageSize;

    // Handle out of range page number
    if (startIndex >= totalCount) {
      return Right(
        NotificationsResponse(
          items: [],
          pageNumber: query.pageNumber,
          pageSize: query.pageSize,
          totalCount: totalCount,
          totalPages: totalPages,
          hasPreviousPage: query.pageNumber > 1,
          hasNextPage: false,
          summary: query.includeSummary ? _createNotificationSummary() : null,
        ),
      );
    }

    // Get page items
    final pageItems = filteredNotifications.sublist(startIndex, endIndex);

    return Right(
      NotificationsResponse(
        items: pageItems,
        pageNumber: query.pageNumber,
        pageSize: query.pageSize,
        totalCount: totalCount,
        totalPages: totalPages,
        hasPreviousPage: query.pageNumber > 1,
        hasNextPage: endIndex < totalCount,
        summary: query.includeSummary ? _createNotificationSummary() : null,
      ),
    );
  }

  @override
  Future<Either<Failure, AppNotification>> getNotificationById(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final notification = _notifications.firstWhere((n) => n.id == notificationId);
      return Right(notification);
    } catch (e) {
      return Left(ServerFailure('Notification not found'));
    }
  }

  @override
  Future<Either<Failure, AppNotification>> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) {
      return Left(ServerFailure('Notification not found'));
    }

    final notification = _notifications[index];
    if (notification.isRead) {
      return Right(notification); // Already read, return as-is
    }

    final updatedNotification = notification.copyWith(isRead: true, readAt: DateTime.now());

    _notifications[index] = updatedNotification;
    _updateUnreadCountStream();

    return Right(updatedNotification);
  }

  @override
  Future<Either<Failure, BulkNotificationResult>> markMultipleAsRead(List<String> notificationIds) async {
    await Future.delayed(const Duration(milliseconds: 300));

    int successCount = 0;
    final errors = <String>[];

    for (final id in notificationIds) {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index == -1) {
        errors.add('Notification not found: $id');
        continue;
      }

      if (!_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true, readAt: DateTime.now());
        successCount++;
      }
    }

    _updateUnreadCountStream();

    return Right(
      BulkNotificationResult(
        totalRequested: notificationIds.length,
        successfullyProcessed: successCount,
        errors: errors,
      ),
    );
  }

  @override
  Future<Either<Failure, BulkNotificationResult>> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 300));

    int successCount = 0;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true, readAt: DateTime.now());
        successCount++;
      }
    }

    _updateUnreadCountStream();

    return Right(
      BulkNotificationResult(
        totalRequested: _notifications.length,
        successfullyProcessed: successCount,
        errors: const [],
      ),
    );
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) {
      return Left(ServerFailure('Notification not found'));
    }

    _notifications.removeAt(index);
    _updateUnreadCountStream();

    return const Right(null);
  }

  @override
  Future<Either<Failure, BulkNotificationResult>> deleteMultipleNotifications(List<String> notificationIds) async {
    await Future.delayed(const Duration(milliseconds: 300));

    int successCount = 0;
    final errors = <String>[];

    for (final id in notificationIds) {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index == -1) {
        errors.add('Notification not found: $id');
        continue;
      }

      _notifications.removeAt(index);
      successCount++;
    }

    _updateUnreadCountStream();

    return Right(
      BulkNotificationResult(
        totalRequested: notificationIds.length,
        successfullyProcessed: successCount,
        errors: errors,
      ),
    );
  }

  @override
  Future<Either<Failure, NotificationCountStatistics>> getNotificationStatistics() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final totalCount = _notifications.length;
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    final readCount = totalCount - unreadCount;

    // Count by priority
    final priorityCounts = <String, int>{};
    for (final priority in NotificationPriority.values) {
      final count = _notifications.where((n) => n.priority == priority).length;
      priorityCounts[priority.value] = count;
    }

    // Count by type
    final typeCounts = <String, int>{};
    for (final notification in _notifications) {
      final type = notification.type.value;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    // Count by category
    final categoryCounts = <String, int>{};
    for (final notification in _notifications) {
      final category = notification.category ?? 'Uncategorized';
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    // Time-based counts
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final thisMonthStart = DateTime(now.year, now.month, 1);

    final timeBasedCounts = <String, int>{
      'today': _notifications.where((n) => n.createdAt.isAfter(today)).length,
      'thisWeek': _notifications.where((n) => n.createdAt.isAfter(thisWeekStart)).length,
      'thisMonth': _notifications.where((n) => n.createdAt.isAfter(thisMonthStart)).length,
      'expiringSoon': _notifications
          .where(
            (n) =>
                n.expiresAt != null &&
                n.expiresAt!.isAfter(now) &&
                n.expiresAt!.isBefore(now.add(const Duration(days: 3))),
          )
          .length,
      'expired': _notifications.where((n) => n.expiresAt != null && n.expiresAt!.isBefore(now)).length,
    };

    // Unread by priority
    final unreadByPriority = <String, int>{};
    for (final priority in NotificationPriority.values) {
      final count = _notifications.where((n) => n.priority == priority && !n.isRead).length;
      unreadByPriority[priority.value] = count;
    }

    return Right(
      NotificationCountStatistics(
        totalCount: totalCount,
        unreadCount: unreadCount,
        readCount: readCount,
        priorityCounts: priorityCounts,
        typeCounts: typeCounts,
        categoryCounts: categoryCounts,
        timeBasedCounts: timeBasedCounts,
        unreadByPriority: unreadByPriority,
      ),
    );
  }

  @override
  Future<Either<Failure, NotificationSettings>> getNotificationSettings() async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Return default mock settings
    final projectUpdatesPreference = NotificationTypePreference(
      enabled: true,
      email: true,
      push: true,
      priorityFilter: 'Medium',
      additionalSettings: {'immediateNotification': true},
    );

    final taskAssignmentsPreference = NotificationTypePreference(
      enabled: true,
      email: true,
      push: true,
      additionalSettings: {'immediateNotification': true},
    );

    final systemAnnouncementsPreference = NotificationTypePreference(
      enabled: true,
      email: true,
      push: true,
      sms: true,
      additionalSettings: {'criticalOnly': false},
    );

    final quietHours = QuietHoursSettings(
      enabled: true,
      startTime: '22:00',
      endTime: '07:00',
      allowCritical: true,
      weekendsOnly: false,
    );

    return Right(
      NotificationSettings(
        userId: 'mock-user-id',
        emailNotifications: true,
        pushNotifications: true,
        inAppNotifications: true,
        smsNotifications: false,
        preferences: {
          'projectUpdates': projectUpdatesPreference,
          'taskAssignments': taskAssignmentsPreference,
          'systemAnnouncements': systemAnnouncementsPreference,
        },
        quietHours: quietHours,
      ),
    );
  }

  @override
  Future<Either<Failure, NotificationSettings>> updateNotificationSettings(NotificationSettings settings) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // In a real implementation, we would persist these settings
    // For mock, just return the settings as if they were saved
    return Right(settings);
  }

  @override
  Stream<AppNotification> getNotificationStream() {
    return _notificationStreamController.stream;
  }

  @override
  Stream<int> getUnreadCountStream() {
    return _unreadCountStreamController.stream;
  }

  /// Clean up resources when the repository is no longer needed
  void dispose() {
    _notificationStreamController.close();
    _unreadCountStreamController.close();
  }

  // Helper method to create notification summary
  NotificationSummary _createNotificationSummary() {
    final now = DateTime.now();

    return NotificationSummary(
      unreadCount: _notifications.where((n) => !n.isRead).length,
      criticalCount: _notifications.where((n) => n.priority == NotificationPriority.critical).length,
      highPriorityCount: _notifications.where((n) => n.priority == NotificationPriority.high).length,
      expiringSoonCount: _notifications
          .where(
            (n) =>
                n.expiresAt != null &&
                n.expiresAt!.isAfter(now) &&
                n.expiresAt!.isBefore(now.add(const Duration(days: 3))),
          )
          .length,
      todayCount: _notifications
          .where((n) => n.createdAt.day == now.day && n.createdAt.month == now.month && n.createdAt.year == now.year)
          .length,
    );
  }

  List<AppNotification> _generateMockNotifications() {
    final now = DateTime.now();

    return [
      // Today's notifications
      AppNotification(
        id: '1',
        title: 'Project Update',
        message: 'Solar Farm Project Alpha has been updated with new timeline.',
        type: NotificationType.projectUpdate,
        createdAt: now.subtract(const Duration(minutes: 30)),
        isRead: false,
        priority: NotificationPriority.medium,
        category: 'Project',
        actionUrl: '/projects/alpha',
      ),
      AppNotification(
        id: '2',
        title: 'New Task Assigned',
        message: 'You have been assigned to install panels on Building C.',
        type: NotificationType.taskAssigned,
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
        priority: NotificationPriority.high,
        category: 'Task',
        actionUrl: '/tasks/building-c',
      ),
      AppNotification(
        id: '3',
        title: 'Daily Report Submitted',
        message: 'Your daily report for March 15 has been successfully submitted.',
        type: NotificationType.reportSubmission,
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
        priority: NotificationPriority.low,
        category: 'Report',
      ),

      // Recent notifications (1-2 days old)
      AppNotification(
        id: '4',
        title: 'System Maintenance',
        message: 'Scheduled maintenance will occur tonight from 12-2 AM.',
        type: NotificationType.systemMaintenance,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: false,
        priority: NotificationPriority.medium,
        category: 'System',
      ),
      AppNotification(
        id: '5',
        title: 'Approval Required',
        message: 'Work request #WR-2024-001 requires your approval.',
        type: NotificationType.approval,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
        priority: NotificationPriority.high,
        category: 'Work Request',
        actionUrl: '/approvals/wr-2024-001',
      ),

      // Older notifications
      AppNotification(
        id: '6',
        title: 'Installation Complete',
        message: 'Phase 1 installation has been completed successfully.',
        type: NotificationType.success,
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
        priority: NotificationPriority.medium,
        category: 'Project',
      ),
      AppNotification(
        id: '7',
        title: 'Weather Alert',
        message: 'High winds expected tomorrow. Consider rescheduling outdoor work.',
        type: NotificationType.warning,
        createdAt: now.subtract(const Duration(days: 4)),
        isRead: false,
        priority: NotificationPriority.medium,
        category: 'System',
      ),

      // Critical notifications
      AppNotification(
        id: '8',
        title: 'Security Alert',
        message: 'Unusual login detected from new location.',
        type: NotificationType.securityAlert,
        createdAt: now.subtract(const Duration(hours: 6)),
        isRead: false,
        priority: NotificationPriority.critical,
        category: 'Security',
      ),

      // Expiring notifications
      AppNotification(
        id: '9',
        title: 'Task Approaching Deadline',
        message: 'Task "Update wiring diagrams" is due in 2 days.',
        type: NotificationType.taskOverdue,
        createdAt: now.subtract(const Duration(days: 1)),
        expiresAt: now.add(const Duration(days: 2)),
        isRead: false,
        priority: NotificationPriority.high,
        category: 'Task',
        actionUrl: '/tasks/wiring-diagrams',
      ),

      // Special events
      AppNotification(
        id: '10',
        title: 'Team Meeting Reminder',
        message: 'Weekly team sync starts in 1 hour.',
        type: NotificationType.calendarEventReminder,
        createdAt: now.subtract(const Duration(hours: 23)),
        isRead: true,
        priority: NotificationPriority.medium,
        category: 'Calendar',
        actionUrl: '/calendar/team-sync',
      ),
    ];
  }
}
