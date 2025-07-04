import '../application/notification_bloc.dart';
import '../domain/entities/notification.dart';

/// Mock notification repository for development and testing
class MockNotificationRepository implements NotificationRepository {
  final List<AppNotification> _notifications = _generateMockNotifications();

  @override
  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate network delay
    return List.from(_notifications);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _notifications.removeWhere((n) => n.id == notificationId);
  }

  @override
  Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _notifications.where((n) => !n.isRead).length;
  }

  static List<AppNotification> _generateMockNotifications() {
    final now = DateTime.now();

    return [
      AppNotification(
        id: '1',
        title: 'Project Update',
        message: 'Solar Farm Project Alpha has been updated with new timeline.',
        type: NotificationType.projectUpdate,
        createdAt: now.subtract(const Duration(minutes: 30)),
        isRead: false,
        actionUrl: '/projects/alpha',
      ),
      AppNotification(
        id: '2',
        title: 'New Task Assigned',
        message: 'You have been assigned to install panels on Building C.',
        type: NotificationType.taskAssignment,
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
        actionUrl: '/tasks/building-c',
      ),
      AppNotification(
        id: '3',
        title: 'Daily Report Submitted',
        message:
            'Your daily report for March 15 has been successfully submitted.',
        type: NotificationType.reportSubmission,
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      AppNotification(
        id: '4',
        title: 'System Maintenance',
        message: 'Scheduled maintenance will occur tonight from 12-2 AM.',
        type: NotificationType.systemMaintenance,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: false,
      ),
      AppNotification(
        id: '5',
        title: 'Approval Required',
        message: 'Work request #WR-2024-001 requires your approval.',
        type: NotificationType.approval,
        createdAt: now.subtract(const Duration(days: 2)),
        isRead: true,
        actionUrl: '/approvals/wr-2024-001',
      ),
      AppNotification(
        id: '6',
        title: 'Installation Complete',
        message: 'Phase 1 installation has been completed successfully.',
        type: NotificationType.success,
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
      ),
      AppNotification(
        id: '7',
        title: 'Weather Alert',
        message:
            'High winds expected tomorrow. Consider rescheduling outdoor work.',
        type: NotificationType.warning,
        createdAt: now.subtract(const Duration(days: 4)),
        isRead: false,
      ),
    ];
  }
}
