import 'package:flutter/material.dart';
import '../../domain/entities/notification.dart';

/// Card widget for displaying a single notification
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isUnread ? 2 : 0,
      color: isUnread
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
          : theme.colorScheme.surface,
      child: ListTile(
        leading: _buildNotificationIcon(theme),
        title: Text(
          notification.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: _buildTrailingActions(context, theme),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildNotificationIcon(ThemeData theme) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.info:
        iconData = Icons.info_outline;
        iconColor = theme.colorScheme.primary;
        break;
      case NotificationType.warning:
        iconData = Icons.warning_amber_outlined;
        iconColor = Colors.orange;
        break;
      case NotificationType.error:
        iconData = Icons.error_outline;
        iconColor = theme.colorScheme.error;
        break;
      case NotificationType.success:
        iconData = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case NotificationType.projectUpdate:
        iconData = Icons.business_outlined;
        iconColor = theme.colorScheme.secondary;
        break;
      case NotificationType.taskAssignment:
        iconData = Icons.assignment_outlined;
        iconColor = theme.colorScheme.tertiary;
        break;
      case NotificationType.reportSubmission:
        iconData = Icons.description_outlined;
        iconColor = Colors.blue;
        break;
      case NotificationType.systemMaintenance:
        iconData = Icons.build_outlined;
        iconColor = Colors.grey;
        break;
      case NotificationType.approval:
        iconData = Icons.approval_outlined;
        iconColor = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  Widget _buildTrailingActions(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!notification.isRead && onMarkAsRead != null)
          IconButton(
            icon: const Icon(Icons.mark_as_unread),
            onPressed: onMarkAsRead,
            tooltip: 'Mark as read',
            iconSize: 20,
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
            tooltip: 'Delete',
            iconSize: 20,
            color: theme.colorScheme.error,
          ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
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
}
