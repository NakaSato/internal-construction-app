import 'package:flutter/material.dart';

/// Type of notification filter
enum NotificationFilterType {
  all('all', 'All notifications'),
  unread('unread', 'Unread only'),
  highPriority('high', 'High priority'),
  project('project', 'Project notifications'),
  task('task', 'Task notifications'),
  report('report', 'Report notifications'),
  system('system', 'System notifications');

  const NotificationFilterType(this.value, this.displayName);
  final String value;
  final String displayName;
}

/// Widget for filtering and displaying summary information about notifications
class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({
    Key? key,
    required this.unreadCount,
    required this.totalCount,
    this.onFilterSelected,
    this.selectedFilter = NotificationFilterType.all,
  }) : super(key: key);

  final int unreadCount;
  final int totalCount;
  final void Function(NotificationFilterType)? onFilterSelected;
  final NotificationFilterType selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSummaryText(context),
          _buildFilterButton(context),
        ],
      ),
    );
  }

  Widget _buildSummaryText(BuildContext context) {
    return Expanded(
      child: Text(
        'Total: $totalCount, Unread: $unreadCount',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return PopupMenuButton<NotificationFilterType>(
      icon: const Icon(Icons.filter_list),
      tooltip: 'Filter notifications',
      onSelected: (filter) {
        onFilterSelected?.call(filter);
      },
      itemBuilder: (BuildContext context) => NotificationFilterType.values.map((filter) {
        return PopupMenuItem<NotificationFilterType>(
          value: filter,
          child: Row(
            children: [
              if (filter == selectedFilter) 
                const Icon(Icons.check, size: 18)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(filter.displayName),
            ],
          ),
        );
      }).toList(),
    );
  }
}
