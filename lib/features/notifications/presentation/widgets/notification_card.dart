import 'package:flutter/material.dart';
import '../../domain/entities/notification.dart';
import '../helpers/notification_icons.dart';

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
        leading: _buildNotificationIcon(context, theme),
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

  Widget _buildNotificationIcon(BuildContext context, ThemeData theme) {
    return NotificationIcons.buildIconContainer(
      context,
      notification.type,
      notification.priority,
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
    return NotificationIcons.formatTimestamp(timestamp);
  }
}
