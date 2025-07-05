import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/calendar_management_bloc.dart';
import '../../application/calendar_management_state.dart';
import '../../domain/entities/calendar_event.dart';

/// Calendar dashboard widget showing overview and statistics
class CalendarDashboardWidget extends StatelessWidget {
  const CalendarDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarManagementBloc, CalendarManagementState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildQuickStats(context, state),
              const SizedBox(height: 16),
              _buildUpcomingEvents(context, state),
              const SizedBox(height: 16),
              _buildQuickActions(context),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context, CalendarManagementState state) {
    int totalEvents = 0;
    int todayEvents = 0;
    int upcomingEvents = 0;

    if (state is CalendarEventsLoaded) {
      totalEvents = state.events.length;
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      todayEvents = state.events
          .where(
            (event) =>
                event.startDateTime.isAfter(todayStart) &&
                event.startDateTime.isBefore(todayEnd),
          )
          .length;

      upcomingEvents = state.events
          .where((event) => event.startDateTime.isAfter(DateTime.now()))
          .length;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calendar Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                // Use different layouts based on available width
                if (constraints.maxWidth < 500) {
                  // Stack vertically on narrow screens
                  return Column(
                    children: [
                      _buildStatCard(
                        context,
                        'Total Events',
                        totalEvents.toString(),
                        Icons.event,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Today',
                              todayEvents.toString(),
                              Icons.today,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Upcoming',
                              upcomingEvents.toString(),
                              Icons.schedule,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  // Use horizontal layout on wider screens
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Events',
                          totalEvents.toString(),
                          Icons.event,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Today',
                          todayEvents.toString(),
                          Icons.today,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Upcoming',
                          upcomingEvents.toString(),
                          Icons.schedule,
                          Colors.orange,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(
    BuildContext context,
    CalendarManagementState state,
  ) {
    List<CalendarEvent> upcomingEvents = [];

    if (state is CalendarEventsLoaded) {
      upcomingEvents = state.events
          .where((event) => event.startDateTime.isAfter(DateTime.now()))
          .take(3) // Reduced from 5 to 3 to save space
          .toList();
      upcomingEvents.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize:
              MainAxisSize.min, // Added to prevent unnecessary expansion
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Events',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (upcomingEvents.length >= 3)
                  TextButton(
                    onPressed: () {
                      // Navigate to full events list
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (upcomingEvents.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No upcoming events')),
              )
            else
              ...upcomingEvents.map(
                (event) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 16, // Smaller avatar
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.event,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 16,
                      ),
                    ),
                    title: Text(
                      event.title,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${_formatDate(event.startDateTime)} • ${event.location ?? 'No location'}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      // Handle event tap
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final actions = [
                  _buildActionChip(context, 'Add Event', Icons.add, () {
                    // Handle add event
                  }),
                  _buildActionChip(context, 'View Today', Icons.today, () {
                    // Handle view today
                  }),
                  _buildActionChip(context, 'Search', Icons.search, () {
                    // Handle search
                  }),
                  _buildActionChip(context, 'Sync', Icons.sync, () {
                    // Handle sync
                  }),
                ];

                return Wrap(spacing: 8, runSpacing: 8, children: actions);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);

    if (eventDate == today) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (eventDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
