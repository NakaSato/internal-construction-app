import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/notification_bloc.dart';
import '../../infrastructure/mock_notification_repository.dart';
import '../../infrastructure/notification_repository_adapter.dart';
import '../../domain/entities/notification.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_filter_chip.dart';

/// Main notifications screen showing the notification list and management features
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late final NotificationBloc _notificationBloc;
  late final TabController _tabController;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Create repository and adapter
    final repository = MockNotificationRepository();
    final adapter = NotificationRepositoryAdapter(repository);

    _notificationBloc = NotificationBloc(adapter)..add(const LoadNotifications());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notificationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _notificationBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded && state.unreadCount > 0) {
                  return IconButton(
                    icon: const Icon(Icons.mark_email_read),
                    onPressed: () => _notificationBloc.add(const MarkAllAsRead()),
                    tooltip: 'Mark all as read',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _notificationBloc.add(const LoadNotifications()),
              tooltip: 'Refresh',
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Unread'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Filter chips section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    NotificationFilterChip(
                      label: 'All',
                      isSelected: _selectedFilter == 'All',
                      onSelected: () => setState(() => _selectedFilter = 'All'),
                    ),
                    const SizedBox(width: 8),
                    NotificationFilterChip(
                      label: 'Info',
                      isSelected: _selectedFilter == 'Info',
                      onSelected: () => setState(() => _selectedFilter = 'Info'),
                    ),
                    const SizedBox(width: 8),
                    NotificationFilterChip(
                      label: 'Warning',
                      isSelected: _selectedFilter == 'Warning',
                      onSelected: () => setState(() => _selectedFilter = 'Warning'),
                    ),
                    const SizedBox(width: 8),
                    NotificationFilterChip(
                      label: 'Error',
                      isSelected: _selectedFilter == 'Error',
                      onSelected: () => setState(() => _selectedFilter = 'Error'),
                    ),
                    const SizedBox(width: 8),
                    NotificationFilterChip(
                      label: 'Success',
                      isSelected: _selectedFilter == 'Success',
                      onSelected: () => setState(() => _selectedFilter = 'Success'),
                    ),
                  ],
                ),
              ),
            ),
            // Notifications list
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNotificationsList(showOnlyUnread: false),
                  _buildNotificationsList(showOnlyUnread: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList({required bool showOnlyUnread}) {
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
                Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text('Error loading notifications', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _notificationBloc.add(const LoadNotifications()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is NotificationLoaded) {
          var notifications = state.notifications;

          // Filter by read status
          if (showOnlyUnread) {
            notifications = notifications.where((n) => !n.isRead).toList();
          }

          // Filter by type
          if (_selectedFilter != 'All') {
            notifications = notifications
                .where((n) => n.type.toString().split('.').last.toLowerCase() == _selectedFilter.toLowerCase())
                .toList();
          }

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    showOnlyUnread ? Icons.mark_email_read : Icons.notifications_none,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    showOnlyUnread ? 'No unread notifications' : 'No notifications',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    showOnlyUnread ? 'You\'re all caught up!' : 'Notifications will appear here',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _notificationBloc.add(const LoadNotifications()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationCard(
                  notification: notification,
                  onTap: () => _handleNotificationTap(notification),
                  onMarkAsRead: notification.isRead ? null : () => _notificationBloc.add(MarkAsRead(notification.id)),
                  onDelete: () => _notificationBloc.add(DeleteNotification(notification.id)),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      _notificationBloc.add(MarkAsRead(notification.id));
    }

    // Handle navigation based on notification action URL
    if (notification.actionUrl != null && notification.actionUrl!.isNotEmpty) {
      context.push(notification.actionUrl!);
    }
  }
}
