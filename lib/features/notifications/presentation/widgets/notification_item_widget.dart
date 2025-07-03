import 'package:flutter/material.dart';
import '../../domain/entities/notification_item.dart';

/// Widget for displaying a single notification item in a list
class NotificationItemWidget extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon and read indicator
              Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getTypeColor(colorScheme).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: _getTypeColor(colorScheme),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and timestamp
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDateTime(notification.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Message
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: notification.isRead
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Type and priority chips
                    Row(
                      children: [
                        _buildTypeChip(theme, colorScheme),
                        const SizedBox(width: 8),
                        _buildPriorityChip(theme, colorScheme),
                        const Spacer(),
                        // Action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!notification.isRead && onMarkAsRead != null)
                              IconButton(
                                icon: const Icon(Icons.mark_email_read),
                                onPressed: onMarkAsRead,
                                tooltip: 'Mark as read',
                                iconSize: 20,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            if (onDelete != null)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _confirmDelete(context),
                                tooltip: 'Delete',
                                iconSize: 20,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getTypeColor(colorScheme).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getTypeColor(colorScheme).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        notification.type.value,
        style: theme.textTheme.bodySmall?.copyWith(
          color: _getTypeColor(colorScheme),
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(ThemeData theme, ColorScheme colorScheme) {
    final priorityColor = _getPriorityColor(colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: priorityColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        notification.priority.value,
        style: theme.textTheme.bodySmall?.copyWith(
          color: priorityColor,
          fontSize: 10,
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (notification.type) {
      case NotificationType.projectAssignment:
        return Icons.assignment;
      case NotificationType.dailyReportApproval:
        return Icons.approval;
      case NotificationType.workRequestCreated:
        return Icons.work;
      case NotificationType.workRequestStatusChanged:
        return Icons.update;
      case NotificationType.systemAnnouncement:
        return Icons.campaign;
      case NotificationType.projectUpdate:
        return Icons.update;
      case NotificationType.taskAssignment:
        return Icons.task;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
    }
  }

  Color _getTypeColor(ColorScheme colorScheme) {
    switch (notification.type) {
      case NotificationType.projectAssignment:
        return colorScheme.primary;
      case NotificationType.dailyReportApproval:
        return colorScheme.secondary;
      case NotificationType.workRequestCreated:
        return colorScheme.tertiary;
      case NotificationType.workRequestStatusChanged:
        return colorScheme.tertiary;
      case NotificationType.systemAnnouncement:
        return colorScheme.primary;
      case NotificationType.projectUpdate:
        return colorScheme.secondary;
      case NotificationType.taskAssignment:
        return colorScheme.primary;
      case NotificationType.info:
        return colorScheme.primary;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return colorScheme.error;
    }
  }

  Color _getPriorityColor(ColorScheme colorScheme) {
    switch (notification.priority) {
      case NotificationPriority.low:
        return Colors.green;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.critical:
        return colorScheme.error;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text(
          'Are you sure you want to delete this notification? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
