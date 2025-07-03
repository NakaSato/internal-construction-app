import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/notification_bloc.dart';
import '../../application/blocs/notification_event.dart';
import '../../application/blocs/notification_state.dart';
import '../../domain/entities/notification_item.dart';
import 'notification_item_widget.dart';

/// Widget for displaying a list of notifications with pagination
class NotificationListWidget extends StatefulWidget {
  const NotificationListWidget({super.key});

  @override
  State<NotificationListWidget> createState() => _NotificationListWidgetState();
}

class _NotificationListWidgetState extends State<NotificationListWidget> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // Load more when 90% scrolled
      context.read<NotificationBloc>().add(const LoadMoreNotifications());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is NotificationError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading notifications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<NotificationBloc>().add(
                      const LoadNotifications(refresh: true),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is NotificationLoaded) {
          if (state.notifications.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<NotificationBloc>().add(
                const LoadNotifications(refresh: true),
              );
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount:
                  state.notifications.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.notifications.length) {
                  // Loading indicator at the bottom
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notification = state.notifications[index];
                return NotificationItemWidget(
                  notification: notification,
                  onTap: () => _onNotificationTap(notification),
                  onMarkAsRead: () => _markAsRead(notification.id),
                  onDelete: () => _deleteNotification(notification.id),
                );
              },
            ),
          );
        }

        return const Center(child: Text('Unknown state'));
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 96,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up! No new notifications to show.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<NotificationBloc>().add(
                const LoadNotifications(refresh: true),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  void _onNotificationTap(NotificationItem notification) {
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }
    // TODO: Navigate to relevant screen based on notification type and data
    _showNotificationDetails(notification);
  }

  void _markAsRead(String notificationId) {
    context.read<NotificationBloc>().add(
      MarkNotificationAsRead(notificationId),
    );
  }

  void _deleteNotification(String notificationId) {
    context.read<NotificationBloc>().add(DeleteNotification(notificationId));
  }

  void _showNotificationDetails(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            Text(
              'Type: ${notification.type.value}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Priority: ${notification.priority.value}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Created: ${_formatDateTime(notification.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!notification.isRead)
            ElevatedButton(
              onPressed: () {
                _markAsRead(notification.id);
                Navigator.of(context).pop();
              },
              child: const Text('Mark as Read'),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
