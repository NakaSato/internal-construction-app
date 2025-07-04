import 'package:equatable/equatable.dart';

/// Notification entity representing system notifications
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
    this.metadata,
  });

  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
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
    actionUrl,
    metadata,
  ];
}

/// Types of notifications
enum NotificationType {
  info('info'),
  warning('warning'),
  error('error'),
  success('success'),
  projectUpdate('project_update'),
  taskAssignment('task_assignment'),
  reportSubmission('report_submission'),
  systemMaintenance('system_maintenance'),
  approval('approval');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.info,
    );
  }

  String get displayName {
    switch (this) {
      case NotificationType.info:
        return 'Information';
      case NotificationType.warning:
        return 'Warning';
      case NotificationType.error:
        return 'Error';
      case NotificationType.success:
        return 'Success';
      case NotificationType.projectUpdate:
        return 'Project Update';
      case NotificationType.taskAssignment:
        return 'Task Assignment';
      case NotificationType.reportSubmission:
        return 'Report Submission';
      case NotificationType.systemMaintenance:
        return 'System Maintenance';
      case NotificationType.approval:
        return 'Approval Required';
    }
  }
}
