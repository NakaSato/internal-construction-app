import 'package:equatable/equatable.dart';

/// Notification entity representing system notifications
///
/// This class represents notifications in the Solar Projects platform,
/// supporting real-time updates, push notifications, and customizable settings.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.readAt,
    this.expiresAt,
    this.priority = NotificationPriority.medium,
    this.category,
    this.actionUrl,
    this.iconType,
    this.data,
    this.metadata,
  });

  /// Unique identifier for the notification
  final String id;
  
  /// Title of the notification
  final String title;
  
  /// Detailed message content of the notification
  final String message;
  
  /// Type of notification (e.g., ProjectStatusChanged, TaskAssigned)
  final NotificationType type;
  
  /// Timestamp when the notification was created
  final DateTime createdAt;
  
  /// Whether the notification has been read by the user
  final bool isRead;
  
  /// Timestamp when the notification was read (null if unread)
  final DateTime? readAt;
  
  /// Timestamp when the notification expires (null if no expiration)
  final DateTime? expiresAt;
  
  /// Priority level of the notification
  final NotificationPriority priority;
  
  /// Category grouping for the notification (e.g., Project, Task, Report)
  final String? category;
  
  /// URL to navigate to when the notification is tapped
  final String? actionUrl;
  
  /// Icon identifier for the notification
  final String? iconType;
  
  /// Structured data payload associated with the notification
  final Map<String, dynamic>? data;
  
  /// Additional metadata for the notification
  final Map<String, dynamic>? metadata;

  /// Creates a copy of this notification marked as read
  AppNotification markAsRead() {
    if (isRead) return this;
    return copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
  }

  /// Determines if the notification has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Determines if the notification is a critical priority
  bool get isCritical => priority == NotificationPriority.critical;

  /// Determines if the notification is a high priority
  bool get isHighPriority => priority == NotificationPriority.high;

  /// Determines if the notification is for a system-wide announcement
  bool get isSystemAnnouncement => type == NotificationType.systemAnnouncement;

  /// Creates an AppNotification instance from JSON data
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['notificationId'] as String? ?? json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.fromString(json['type'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
      priority: NotificationPriority.fromString(json['priority'] as String? ?? 'medium'),
      category: json['category'] as String?,
      actionUrl: json['actionUrl'] as String?,
      iconType: json['iconType'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts this notification to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'notificationId': id,
      'title': title,
      'message': message,
      'type': type.value,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      if (readAt != null) 'readAt': readAt!.toIso8601String(),
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      'priority': priority.value,
      if (category != null) 'category': category,
      if (actionUrl != null) 'actionUrl': actionUrl,
      if (iconType != null) 'iconType': iconType,
      if (data != null) 'data': data,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Creates a copy of this notification with the specified fields replaced with new values
  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
    DateTime? expiresAt,
    NotificationPriority? priority,
    String? category,
    String? actionUrl,
    String? iconType,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      expiresAt: expiresAt ?? this.expiresAt,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      actionUrl: actionUrl ?? this.actionUrl,
      iconType: iconType ?? this.iconType,
      data: data ?? this.data,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    type,
    createdAt,
    isRead,
    readAt,
    expiresAt,
    priority,
    category,
    actionUrl,
    iconType,
    data,
    metadata,
  ];
}

/// Priority levels for notifications
enum NotificationPriority {
  critical('critical'),
  high('high'),
  medium('medium'),
  low('low');

  const NotificationPriority(this.value);
  final String value;

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotificationPriority.medium,
    );
  }

  String get displayName {
    switch (this) {
      case NotificationPriority.critical:
        return 'Critical';
      case NotificationPriority.high:
        return 'High';
      case NotificationPriority.medium:
        return 'Medium';
      case NotificationPriority.low:
        return 'Low';
    }
  }
}

/// Types of notifications
/// 
/// Comprehensive set of notification types matching the API specification
enum NotificationType {
  // Generic types
  info('info'),
  warning('warning'),
  error('error'),
  success('success'),
  
  // Project notifications
  projectCreated('project_created'),
  projectStatusChanged('project_status_changed'),
  projectDeleted('project_deleted'),
  projectLocationUpdated('project_location_updated'),
  projectUpdate('project_update'),
  
  // Task notifications
  taskCreated('task_created'),
  taskAssigned('task_assigned'),
  taskStatusChanged('task_status_changed'),
  taskOverdue('task_overdue'),
  taskCompleted('task_completed'),
  
  // Report notifications
  dailyReportSubmitted('daily_report_submitted'),
  weeklyReportSubmitted('weekly_report_submitted'),
  reportApproved('report_approved'),
  reportRejected('report_rejected'),
  reportSubmission('report_submission'),
  
  // Work request notifications
  workRequestCreated('work_request_created'),
  workRequestApproved('work_request_approved'),
  workRequestCompleted('work_request_completed'),
  weeklyWorkRequestCreated('weekly_work_request_created'),
  
  // System and user notifications
  systemAnnouncement('system_announcement'),
  maintenanceScheduled('maintenance_scheduled'),
  systemMaintenance('system_maintenance'),
  userRoleChanged('user_role_changed'),
  securityAlert('security_alert'),
  approval('approval'),
  
  // Calendar and schedule notifications
  calendarEventCreated('calendar_event_created'),
  calendarEventReminder('calendar_event_reminder'),
  eventConflict('event_conflict'),
  resourceConflict('resource_conflict');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.info,
    );
  }

  /// Get the default category for this notification type
  String get defaultCategory {
    if ([
      NotificationType.projectCreated,
      NotificationType.projectStatusChanged, 
      NotificationType.projectDeleted,
      NotificationType.projectLocationUpdated,
      NotificationType.projectUpdate
    ].contains(this)) {
      return 'Project';
    } else if ([
      NotificationType.taskCreated,
      NotificationType.taskAssigned,
      NotificationType.taskStatusChanged,
      NotificationType.taskOverdue,
      NotificationType.taskCompleted
    ].contains(this)) {
      return 'Task';
    } else if ([
      NotificationType.dailyReportSubmitted,
      NotificationType.weeklyReportSubmitted,
      NotificationType.reportApproved,
      NotificationType.reportRejected,
      NotificationType.reportSubmission
    ].contains(this)) {
      return 'Report';
    } else if ([
      NotificationType.workRequestCreated,
      NotificationType.workRequestApproved,
      NotificationType.workRequestCompleted,
      NotificationType.weeklyWorkRequestCreated
    ].contains(this)) {
      return 'Work Request';
    } else if ([
      NotificationType.systemAnnouncement,
      NotificationType.maintenanceScheduled,
      NotificationType.systemMaintenance,
      NotificationType.securityAlert
    ].contains(this)) {
      return 'System';
    } else if ([
      NotificationType.calendarEventCreated,
      NotificationType.calendarEventReminder,
      NotificationType.eventConflict
    ].contains(this)) {
      return 'Calendar';
    }
    
    return 'Other';
  }

  /// Get the default priority for this notification type
  NotificationPriority get defaultPriority {
    if ([
      NotificationType.securityAlert,
      NotificationType.taskOverdue
    ].contains(this)) {
      return NotificationPriority.critical;
    } else if ([
      NotificationType.projectStatusChanged,
      NotificationType.projectDeleted,
      NotificationType.reportRejected,
      NotificationType.maintenanceScheduled,
      NotificationType.eventConflict,
      NotificationType.resourceConflict
    ].contains(this)) {
      return NotificationPriority.high;
    } else if ([
      NotificationType.taskAssigned,
      NotificationType.weeklyReportSubmitted,
      NotificationType.workRequestCreated,
      NotificationType.systemAnnouncement,
      NotificationType.calendarEventReminder
    ].contains(this)) {
      return NotificationPriority.medium;
    }
    
    return NotificationPriority.low;
  }

  /// Get the default icon type for this notification type
  String get defaultIconType {
    switch (this) {
      // Project notifications
      case NotificationType.projectCreated:
        return 'project-created';
      case NotificationType.projectStatusChanged:
        return 'project-status';
      case NotificationType.projectDeleted:
        return 'project-deleted';
      case NotificationType.projectLocationUpdated:
        return 'project-location';
      case NotificationType.projectUpdate:
        return 'project-update';
        
      // Task notifications
      case NotificationType.taskCreated:
        return 'task-created';
      case NotificationType.taskAssigned:
        return 'task-assigned';
      case NotificationType.taskStatusChanged:
        return 'task-status';
      case NotificationType.taskOverdue:
        return 'task-overdue';
      case NotificationType.taskCompleted:
        return 'task-completed';
        
      // Report notifications
      case NotificationType.dailyReportSubmitted:
        return 'report-daily';
      case NotificationType.weeklyReportSubmitted:
        return 'report-weekly';
      case NotificationType.reportApproved:
        return 'report-approved';
      case NotificationType.reportRejected:
        return 'report-rejected';
      case NotificationType.reportSubmission:
        return 'report-submission';
        
      // Work request notifications
      case NotificationType.workRequestCreated:
        return 'work-request-created';
      case NotificationType.workRequestApproved:
        return 'work-request-approved';
      case NotificationType.workRequestCompleted:
        return 'work-request-completed';
      case NotificationType.weeklyWorkRequestCreated:
        return 'work-request-weekly';
        
      // System and user notifications
      case NotificationType.systemAnnouncement:
        return 'system-announcement';
      case NotificationType.maintenanceScheduled:
        return 'system-maintenance';
      case NotificationType.systemMaintenance:
        return 'system-maintenance';
      case NotificationType.userRoleChanged:
        return 'user-role';
      case NotificationType.securityAlert:
        return 'security-alert';
      case NotificationType.approval:
        return 'approval';
        
      // Calendar and schedule notifications
      case NotificationType.calendarEventCreated:
        return 'calendar-event';
      case NotificationType.calendarEventReminder:
        return 'calendar-reminder';
      case NotificationType.eventConflict:
        return 'calendar-conflict';
      case NotificationType.resourceConflict:
        return 'resource-conflict';
        
      // Generic types
      case NotificationType.info:
        return 'info';
      case NotificationType.warning:
        return 'warning';
      case NotificationType.error:
        return 'error';
      case NotificationType.success:
        return 'success';
    }
  }
}
