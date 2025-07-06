import 'package:flutter/material.dart';
import '../../domain/entities/calendar_event.dart';
import 'calendar_event_list_widget.dart';

/// Agenda (List) view for calendar events
class CalendarAgendaView extends StatelessWidget {
  const CalendarAgendaView({
    super.key,
    required this.events,
    this.onEventTap,
    this.groupByDate = true,
  });

  final List<CalendarEvent> events;
  final Function(CalendarEvent)? onEventTap;
  final bool groupByDate;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _buildEmptyState(context);
    }

    if (groupByDate) {
      return _buildGroupedByDate(context);
    }

    return CalendarEventListWidget(events: events, onEventTap: onEventTap);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No upcoming events',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Your agenda is clear',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedByDate(BuildContext context) {
    final groupedEvents = _groupEventsByDate(events);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedEvents.length,
      itemBuilder: (context, index) {
        final entry = groupedEvents.entries.elementAt(index);
        final date = entry.key;
        final dayEvents = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _formatDateHeader(date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${dayEvents.length} event${dayEvents.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Events for this date
            CalendarEventListWidget(
              events: dayEvents,
              onEventTap: onEventTap,
              showDate: false, // Don't show date since we have headers
            ),
          ],
        );
      },
    );
  }

  Map<DateTime, List<CalendarEvent>> _groupEventsByDate(
    List<CalendarEvent> events,
  ) {
    final Map<DateTime, List<CalendarEvent>> grouped = {};

    for (final event in events) {
      final date = DateTime(
        event.startDateTime.year,
        event.startDateTime.month,
        event.startDateTime.day,
      );

      if (grouped.containsKey(date)) {
        grouped[date]!.add(event);
      } else {
        grouped[date] = [event];
      }
    }

    // Sort by date
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedMap = <DateTime, List<CalendarEvent>>{};

    for (final key in sortedKeys) {
      // Sort events within each day by start time
      grouped[key]!.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == tomorrow) {
      return 'Tomorrow';
    } else if (date.isAfter(today) &&
        date.isBefore(today.add(const Duration(days: 7)))) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}';
    }
  }
}
