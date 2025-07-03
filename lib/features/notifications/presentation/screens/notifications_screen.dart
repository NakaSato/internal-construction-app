import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/blocs/notification_bloc.dart';
import '../../application/blocs/notification_event.dart';
import '../../application/blocs/notification_state.dart';
import '../../domain/entities/notification_item.dart';
import '../widgets/notification_list_widget.dart';
import '../widgets/notification_filter_widget.dart';
import '../widgets/notification_statistics_widget.dart';
import '../../../../common/widgets/responsive_layout.dart';
import '../../../../core/di/injection.dart';

/// Main notifications screen showing the notification list and management features
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    _notificationBloc = getIt<NotificationBloc>();
    _notificationBloc.add(const LoadNotifications(refresh: true));
    _notificationBloc.add(const LoadNotificationCount());
    _notificationBloc.add(const LoadNotificationStatistics());
  }

  @override
  void dispose() {
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
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterBottomSheet(context),
              tooltip: 'Filter notifications',
            ),
            IconButton(
              icon: const Icon(Icons.mark_email_read),
              onPressed: () => _markAllAsRead(),
              tooltip: 'Mark all as read',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _refreshNotifications(),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: ResponsiveLayout(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showSendTestNotificationDialog(context),
          tooltip: 'Send test notification',
          child: const Icon(Icons.add_alert),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Statistics summary at the top
        BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoaded && state.statistics != null) {
              return NotificationStatisticsWidget(
                statistics: state.statistics!,
                isCompact: true,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        // Main notification list
        const Expanded(child: NotificationListWidget()),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Sidebar with statistics and filters
        SizedBox(
          width: 320,
          child: Column(
            children: [
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoaded && state.statistics != null) {
                    return NotificationStatisticsWidget(
                      statistics: state.statistics!,
                      isCompact: false,
                    );
                  }
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Loading statistics...'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Expanded(child: NotificationFilterWidget()),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Main content area
        const Expanded(child: NotificationListWidget()),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout(); // Same layout as tablet for now
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filter Notifications',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: const NotificationFilterWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markAllAsRead() {
    _notificationBloc.add(const MarkAllNotificationsAsRead());
  }

  void _refreshNotifications() {
    _notificationBloc.add(const RefreshNotifications());
  }

  void _showSendTestNotificationDialog(BuildContext context) {
    final messageController = TextEditingController();
    NotificationType selectedType = NotificationType.info;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Send Test Notification'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Enter test notification message',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<NotificationType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Notification Type',
                ),
                items: NotificationType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.value));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedType = value;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (messageController.text.isNotEmpty) {
                  _notificationBloc.add(
                    SendTestNotification(
                      message: messageController.text,
                      type: selectedType,
                    ),
                  );
                  context.pop();
                }
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
