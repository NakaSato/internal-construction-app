import 'package:equatable/equatable.dart';

/// Represents a notification item in the domain layer
class NotificationItem extends Equatable {
  /// Unique identifier for the notification
  final String id;

  /// User ID this notification belongs to
  final String userId;

  /// Title of the notification
  final String title;

  /// Main message content
  final String message;

  /// Type of notification (ProjectAssignment, DailyReportApproval, etc.)
  final NotificationType type;

  /// Whether the notification has been read
  final bool isRead;

  /// When the notification was created
  final DateTime createdAt;

  /// Additional data specific to the notification type
  final Map<String, dynamic>? data;

  /// Priority level of the notification
  final NotificationPriority priority;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
    this.priority = NotificationPriority.medium,
  });

  /// Create a copy of this notification with some fields updated
  NotificationItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
    NotificationPriority? priority,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      priority: priority ?? this.priority,
    );
  }

  /// Mark this notification as read
  NotificationItem markAsRead() => copyWith(isRead: true);

  /// Mark this notification as unread
  NotificationItem markAsUnread() => copyWith(isRead: false);

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    message,
    type,
    isRead,
    createdAt,
    data,
    priority,
  ];
}

/// Types of notifications available in the system
enum NotificationType {
  projectAssignment('ProjectAssignment'),
  dailyReportApproval('DailyReportApproval'),
  workRequestCreated('WorkRequestCreated'),
  workRequestStatusChanged('WorkRequestStatusChanged'),
  systemAnnouncement('SystemAnnouncement'),
  projectUpdate('ProjectUpdate'),
  taskAssignment('TaskAssignment'),
  info('Info'),
  warning('Warning'),
  error('Error');

  const NotificationType(this.value);

  final String value;

  /// Get notification type from string value
  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.info,
    );
  }
}

/// Priority levels for notifications
enum NotificationPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  const NotificationPriority(this.value);

  final String value;

  /// Get priority from string value
  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotificationPriority.medium,
    );
  }
}
