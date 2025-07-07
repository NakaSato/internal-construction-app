import 'package:flutter/material.dart';

import '../../domain/entities/notification.dart';

/// Widget to display a notification item in the list
class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onDelete,
  }) : super(key: key);

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: notification.isRead ? 1 : 2,
        color: notification.isRead
            ? Theme.of(context).cardColor
            : Theme.of(context).colorScheme.primary.withOpacity(0.05),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildTypeIcon(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold),
                      ),
                    ),
                    _buildPriorityIndicator(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 32.0, top: 4.0, bottom: 4.0),
                  child: Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0),
                      child: Text(
                        _formatDateTime(notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    if (!notification.isRead) TextButton(onPressed: onMarkAsRead, child: const Text('Mark as read')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color iconColor;

    // Determine icon based on notification type
    switch (notification.type) {
      case NotificationType.info:
        iconData = Icons.info_outline;
        iconColor = Colors.blue;
        break;
      case NotificationType.warning:
        iconData = Icons.warning_amber_outlined;
        iconColor = Colors.amber;
        break;
      case NotificationType.error:
        iconData = Icons.error_outline;
        iconColor = Colors.red;
        break;
      case NotificationType.success:
        iconData = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case NotificationType.projectUpdate:
      case NotificationType.projectStatusChanged:
      case NotificationType.projectCreated:
      case NotificationType.projectDeleted:
      case NotificationType.projectLocationUpdated:
        iconData = Icons.business;
        iconColor = Colors.indigo;
        break;
      case NotificationType.taskAssigned: // Fixed from taskAssignment to taskAssigned
      case NotificationType.taskCreated:
      case NotificationType.taskStatusChanged:
      case NotificationType.taskOverdue:
      case NotificationType.taskCompleted:
        iconData = Icons.task_alt;
        iconColor = Colors.teal;
        break;
      case NotificationType.reportSubmission:
      case NotificationType.dailyReportSubmitted:
      case NotificationType.weeklyReportSubmitted:
      case NotificationType.reportApproved:
      case NotificationType.reportRejected:
        iconData = Icons.summarize;
        iconColor = Colors.deepPurple;
        break;
      case NotificationType.systemMaintenance:
      case NotificationType.systemAnnouncement:
      case NotificationType.maintenanceScheduled:
      case NotificationType.securityAlert:
        iconData = Icons.settings;
        iconColor = Colors.grey;
        break;
      case NotificationType.approval:
      case NotificationType.userRoleChanged:
        iconData = Icons.verified_user;
        iconColor = Colors.brown;
        break;
      case NotificationType.calendarEventReminder:
      case NotificationType.calendarEventCreated:
      case NotificationType.eventConflict:
      case NotificationType.resourceConflict:
        iconData = Icons.event;
        iconColor = Colors.cyan;
        break;
      case NotificationType.workRequestCreated:
      case NotificationType.workRequestApproved:
      case NotificationType.workRequestCompleted:
      case NotificationType.weeklyWorkRequestCreated:
        iconData = Icons.work;
        iconColor = Colors.deepOrange;
        break;
    }

    return Icon(iconData, color: iconColor, size: 24);
  }

  Widget _buildPriorityIndicator() {
    Color color;
    String label = '';
    bool showLabel = false;

    switch (notification.priority) {
      case NotificationPriority.critical:
        color = Colors.red;
        label = 'CRITICAL';
        showLabel = true;
        break;
      case NotificationPriority.high:
        color = Colors.orange;
        label = 'HIGH';
        showLabel = notification.isRead ? false : true;
        break;
      case NotificationPriority.medium:
        color = Colors.blue;
        break;
      case NotificationPriority.low:
        color = Colors.grey;
        break;
    }

    if (showLabel) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    // For simplicity, using a basic formatter
    // In a real app, use intl package with proper localization
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
