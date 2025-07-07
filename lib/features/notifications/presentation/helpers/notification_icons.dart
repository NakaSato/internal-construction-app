import 'package:flutter/material.dart';

import '../../domain/entities/notification.dart';

/// Helper class for notification icons and styling
class NotificationIcons {
  /// Get icon data for notification type
  static IconData getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.projectCreated:
      case NotificationType.projectDeleted:
      case NotificationType.projectLocationUpdated:
      case NotificationType.projectStatusChanged:
      case NotificationType.projectUpdate:
        return Icons.business;
      case NotificationType.taskAssigned:
      case NotificationType.taskCreated:
      case NotificationType.taskStatusChanged:
      case NotificationType.taskOverdue:
      case NotificationType.taskCompleted:
        return Icons.task_alt;
      case NotificationType.reportSubmission:
      case NotificationType.dailyReportSubmitted:
      case NotificationType.weeklyReportSubmitted:
      case NotificationType.reportApproved:
      case NotificationType.reportRejected:
        return Icons.summarize;
      case NotificationType.systemMaintenance:
      case NotificationType.systemAnnouncement:
      case NotificationType.maintenanceScheduled:
      case NotificationType.securityAlert:
        return Icons.settings;
      case NotificationType.approval:
      case NotificationType.userRoleChanged:
        return Icons.verified_user;
      case NotificationType.calendarEventReminder:
      case NotificationType.calendarEventCreated:
      case NotificationType.eventConflict:
      case NotificationType.resourceConflict:
        return Icons.event;
      case NotificationType.workRequestCreated:
      case NotificationType.workRequestApproved:
      case NotificationType.workRequestCompleted:
      case NotificationType.weeklyWorkRequestCreated:
        return Icons.work;
      default:
        return Icons.notifications;
    }
  }

  /// Get color for notification priority
  static Color getColorForPriority(NotificationPriority priority, BuildContext context) {
    final theme = Theme.of(context);
    
    switch (priority) {
      case NotificationPriority.critical:
        return theme.colorScheme.error;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.medium:
        return theme.colorScheme.primary;
      case NotificationPriority.low:
        return Colors.green;
    }
  }

  /// Get container for notification icon with proper styling
  static Widget buildIconContainer(
    BuildContext context,
    NotificationType type,
    NotificationPriority priority, {
    double size = 24,
  }) {
    final iconData = getIconForType(type);
    final iconColor = getColorForPriority(priority, context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: size),
    );
  }

  /// Format timestamp for display in notifications
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Format full date and time
  static String formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
