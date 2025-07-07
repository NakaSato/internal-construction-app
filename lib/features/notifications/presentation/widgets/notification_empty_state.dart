import 'package:flutter/material.dart';

/// Widget to display when no notifications are available
class NotificationEmptyState extends StatelessWidget {
  const NotificationEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Notifications',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'You don\'t have any notifications yet. We\'ll notify you about important updates.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
