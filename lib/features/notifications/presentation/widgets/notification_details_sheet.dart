import 'package:flutter/material.dart';
import '../../domain/entities/notification.dart';

/// Widget for displaying notification details in a bottom sheet
class NotificationDetailsSheet extends StatelessWidget {
  const NotificationDetailsSheet({
    Key? key,
    required this.notification,
    required this.onDelete,
    required this.onNavigateToAction,
  }) : super(key: key);

  final AppNotification notification;
  final VoidCallback onDelete;
  final VoidCallback? onNavigateToAction;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            notification.message,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _buildDetailsSection(context),
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          _getIconForType(),
          color: _getColorForPriority(),
          size: 32,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            notification.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(context, 'Type', notification.type.toString()),
        _buildDetailRow(context, 'Priority', notification.priority.displayName),
        if (notification.category != null)
          _buildDetailRow(context, 'Category', notification.category!),
        _buildDetailRow(
          context,
          'Created',
          _formatDate(notification.createdAt),
        ),
        if (notification.readAt != null)
          _buildDetailRow(context, 'Read', _formatDate(notification.readAt!)),
        if (notification.expiresAt != null)
          _buildDetailRow(
            context,
            'Expires',
            _formatDate(notification.expiresAt!),
          ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (notification.actionUrl != null && onNavigateToAction != null)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onNavigateToAction?.call();
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open'),
          ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onDelete();
          },
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete'),
        ),
      ],
    );
  }

  IconData _getIconForType() {
    switch (notification.type) {
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.warning:
        return Icons.warning_amber_outlined;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.projectCreated:
      case NotificationType.projectDeleted:
      case NotificationType.projectLocationUpdated:
      case NotificationType.projectStatusChanged:
      case NotificationType.projectUpdate:
        return Icons.business;
      case NotificationType.taskAssigned:
      case NotificationType.taskCreated:
      case NotificationType.taskStatusChanged:
      case NotificationType.taskOverdue:
      case NotificationType.taskCompleted:
        return Icons.task_alt;
      case NotificationType.reportSubmission:
      case NotificationType.dailyReportSubmitted:
      case NotificationType.weeklyReportSubmitted:
      case NotificationType.reportApproved:
      case NotificationType.reportRejected:
        return Icons.summarize;
      case NotificationType.systemMaintenance:
      case NotificationType.systemAnnouncement:
      case NotificationType.maintenanceScheduled:
      case NotificationType.securityAlert:
        return Icons.settings;
      case NotificationType.approval:
      case NotificationType.userRoleChanged:
        return Icons.verified_user;
      case NotificationType.calendarEventReminder:
      case NotificationType.calendarEventCreated:
      case NotificationType.eventConflict:
      case NotificationType.resourceConflict:
        return Icons.event;
      case NotificationType.workRequestCreated:
      case NotificationType.workRequestApproved:
      case NotificationType.workRequestCompleted:
      case NotificationType.weeklyWorkRequestCreated:
        return Icons.work;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForPriority() {
    switch (notification.priority) {
      case NotificationPriority.critical:
        return Colors.red;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.medium:
        return Colors.blue;
      case NotificationPriority.low:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
