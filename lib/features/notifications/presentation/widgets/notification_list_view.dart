import 'package:flutter/material.dart';

import '../../domain/entities/notification.dart';
import '../widgets/notification_list_item.dart';
import '../widgets/notification_empty_state.dart';
import '../widgets/notification_filter_bar.dart';

/// Widget for displaying a list of notifications with filtering and pagination
class NotificationListView extends StatelessWidget {
  const NotificationListView({
    Key? key,
    required this.notifications,
    required this.unreadCount,
    required this.totalCount,
    required this.onNotificationTap,
    required this.onMarkAsRead,
    required this.onDelete,
    required this.onRefresh,
    required this.onLoadMore,
    required this.scrollController,
    this.isLoadingMore = false,
    this.hasMoreToLoad = false,
  }) : super(key: key);

  final List<AppNotification> notifications;
  final int unreadCount;
  final int totalCount;
  final void Function(AppNotification) onNotificationTap;
  final void Function(String) onMarkAsRead;
  final void Function(String) onDelete;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final bool hasMoreToLoad;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const NotificationEmptyState();
    }

    return Column(
      children: [
        NotificationFilterBar(
          unreadCount: unreadCount,
          totalCount: totalCount,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.builder(
              controller: scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: notifications.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the bottom while loading more
                if (index == notifications.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final notification = notifications[index];
                return NotificationListItem(
                  notification: notification,
                  onTap: () => onNotificationTap(notification),
                  onMarkAsRead: () => onMarkAsRead(notification.id),
                  onDelete: () => onDelete(notification.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
