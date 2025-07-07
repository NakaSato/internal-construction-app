import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/cubits/notification_cubit.dart';
import '../../domain/entities/notification.dart';
import '../widgets/notification_details_sheet.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/notification_list_view.dart';
import 'notification_settings_screen.dart';

/// Screen for displaying and managing notifications
class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({Key? key}) : super(key: key);

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<NotificationCubit>().fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          _buildMarkAllReadButton(),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(value: 'settings', child: Text('Notification Settings')),
              const PopupMenuItem<String>(value: 'refresh', child: Text('Refresh')),
            ],
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<NotificationCubit>().fetchNotifications(refresh: true),
            );
          } else if (state is NotificationLoaded) {
            context.read<NotificationCubit>().markNotificationsAsSeen();
            return NotificationListView(
              notifications: state.notifications,
              unreadCount: state.unreadCount,
              totalCount: state.totalItems,
              onNotificationTap: _handleNotificationTap,
              onMarkAsRead: (id) => context.read<NotificationCubit>().markAsRead(id),
              onDelete: _deleteNotification,
              onRefresh: () => context.read<NotificationCubit>().fetchNotifications(refresh: true),
              onLoadMore: () => context.read<NotificationCubit>().loadMoreNotifications(),
              scrollController: _scrollController,
              isLoadingMore: state.isLoadingMore,
              hasMoreToLoad: state.hasMoreToLoad,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMarkAllReadButton() {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoaded && state.unreadCount > 0) {
          return TextButton.icon(
            onPressed: () => context.read<NotificationCubit>().markAllAsRead(),
            icon: const Icon(Icons.done_all),
            label: const Text('Mark All Read'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // No longer needed as we use NotificationListView component directly

  // No longer needed as we use ErrorStateWidget component

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read
    if (!notification.isRead) {
      context.read<NotificationCubit>().markAsRead(notification.id);
    }

    // Navigate if action URL is present
    if (notification.actionUrl != null) {
      // TODO: Navigate to the specified route
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigating to: ${notification.actionUrl}')));
    }

    // Show details
    showModalBottomSheet(context: context, builder: (context) => _buildNotificationDetailsSheet(notification));
  }

  Widget _buildNotificationDetailsSheet(AppNotification notification) {
    return NotificationDetailsSheet(
      notification: notification,
      onDelete: () => _deleteNotification(notification.id),
      onNavigateToAction: notification.actionUrl != null
          ? () {
              // TODO: Navigate to action URL
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Navigating to: ${notification.actionUrl}')));
            }
          : null,
    );
  }

  void _deleteNotification(String id) {
    final cubit = context.read<NotificationCubit>();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Since we can't restore the deleted notification,
            // we just fetch notifications again
            cubit.fetchNotifications(refresh: true);
          },
        ),
      ),
    );

    cubit.deleteNotification(id);
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'settings':
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()));
        break;
      case 'refresh':
        context.read<NotificationCubit>().fetchNotifications(refresh: true);
        break;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<NotificationCubit>().state;
      if (state is NotificationLoaded && !state.isLoadingMore && state.hasMoreToLoad) {
        context.read<NotificationCubit>().loadMoreNotifications();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
