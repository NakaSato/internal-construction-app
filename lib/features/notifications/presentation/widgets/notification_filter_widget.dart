import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/blocs/notification_bloc.dart';
import '../../application/blocs/notification_event.dart';
import '../../application/blocs/notification_state.dart';
import '../../domain/entities/notification_item.dart';

/// Widget for filtering notifications by type and read status
class NotificationFilterWidget extends StatefulWidget {
  const NotificationFilterWidget({super.key});

  @override
  State<NotificationFilterWidget> createState() =>
      _NotificationFilterWidgetState();
}

class _NotificationFilterWidgetState extends State<NotificationFilterWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        NotificationType? currentTypeFilter;
        bool? currentUnreadFilter;

        if (state is NotificationLoaded) {
          currentTypeFilter = state.currentTypeFilter;
          currentUnreadFilter = state.currentUnreadFilter;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Filter Notifications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),

                // Read status filter
                Text(
                  'Read Status',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _buildReadStatusFilter(currentUnreadFilter),

                const SizedBox(height: 24),

                // Type filter
                Text(
                  'Notification Type',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _buildTypeFilter(currentTypeFilter),

                const SizedBox(height: 24),

                // Clear filters button
                OutlinedButton(
                  onPressed: () {
                    context.read<NotificationBloc>().add(
                      const ClearNotificationFilters(),
                    );
                  },
                  child: const Text('Clear All Filters'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadStatusFilter(bool? currentUnreadFilter) {
    return Column(
      children: [
        RadioListTile<bool?>(
          title: const Text('All'),
          value: null,
          groupValue: currentUnreadFilter,
          onChanged: (value) {
            context.read<NotificationBloc>().add(
              FilterNotificationsByReadStatus(value),
            );
          },
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<bool?>(
          title: const Text('Unread only'),
          value: true,
          groupValue: currentUnreadFilter,
          onChanged: (value) {
            context.read<NotificationBloc>().add(
              FilterNotificationsByReadStatus(value),
            );
          },
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<bool?>(
          title: const Text('Read only'),
          value: false,
          groupValue: currentUnreadFilter,
          onChanged: (value) {
            context.read<NotificationBloc>().add(
              FilterNotificationsByReadStatus(value),
            );
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildTypeFilter(NotificationType? currentTypeFilter) {
    return Column(
      children: [
        // All types option
        RadioListTile<NotificationType?>(
          title: const Text('All Types'),
          value: null,
          groupValue: currentTypeFilter,
          onChanged: (value) {
            context.read<NotificationBloc>().add(
              FilterNotificationsByType(value),
            );
          },
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),

        // Individual type options
        ...NotificationType.values.map(
          (type) => RadioListTile<NotificationType?>(
            title: Text(_getTypeDisplayName(type)),
            subtitle: Text(
              _getTypeDescription(type),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: type,
            groupValue: currentTypeFilter,
            onChanged: (value) {
              context.read<NotificationBloc>().add(
                FilterNotificationsByType(value),
              );
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  String _getTypeDisplayName(NotificationType type) {
    switch (type) {
      case NotificationType.projectAssignment:
        return 'Project Assignment';
      case NotificationType.dailyReportApproval:
        return 'Daily Report Approval';
      case NotificationType.workRequestCreated:
        return 'Work Request Created';
      case NotificationType.workRequestStatusChanged:
        return 'Work Request Status';
      case NotificationType.systemAnnouncement:
        return 'System Announcement';
      case NotificationType.projectUpdate:
        return 'Project Update';
      case NotificationType.taskAssignment:
        return 'Task Assignment';
      case NotificationType.info:
        return 'Information';
      case NotificationType.warning:
        return 'Warning';
      case NotificationType.error:
        return 'Error';
    }
  }

  String _getTypeDescription(NotificationType type) {
    switch (type) {
      case NotificationType.projectAssignment:
        return 'When you are assigned to a project';
      case NotificationType.dailyReportApproval:
        return 'Daily report approval requests';
      case NotificationType.workRequestCreated:
        return 'New work requests';
      case NotificationType.workRequestStatusChanged:
        return 'Work request status updates';
      case NotificationType.systemAnnouncement:
        return 'Important system announcements';
      case NotificationType.projectUpdate:
        return 'Updates on your projects';
      case NotificationType.taskAssignment:
        return 'Task assignments';
      case NotificationType.info:
        return 'General information';
      case NotificationType.warning:
        return 'Warning messages';
      case NotificationType.error:
        return 'Error notifications';
    }
  }
}
