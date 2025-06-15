import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../application/calendar_management_bloc.dart';
import '../../application/calendar_management_event.dart';
import '../../application/calendar_management_state.dart';
import '../widgets/calendar_event_dialog.dart';

/// Simplified calendar management screen with basic functionality
class SimpleCalendarManagementScreen extends StatelessWidget {
  const SimpleCalendarManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<CalendarManagementBloc>()..add(const CalendarEventsRequested()),
      child: const _SimpleCalendarView(),
    );
  }
}

class _SimpleCalendarView extends StatelessWidget {
  const _SimpleCalendarView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: BlocBuilder<CalendarManagementBloc, CalendarManagementState>(
        builder: (context, state) {
          if (state is CalendarManagementLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CalendarManagementError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading events',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CalendarManagementBloc>().add(
                      const CalendarEventsRequested(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CalendarEventsLoaded) {
            final events = state.events;

            if (events.isEmpty) {
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
                      'No events found',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first event to get started',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getEventTypeColor(event),
                      child: Icon(
                        event.eventType.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(event.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${event.startDateTime.day}/${event.startDateTime.month}/${event.startDateTime.year} '
                          '${event.startDateTime.hour.toString().padLeft(2, '0')}:'
                          '${event.startDateTime.minute.toString().padLeft(2, '0')}',
                        ),
                        if (event.description?.isNotEmpty == true)
                          Text(
                            event.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                    trailing: Chip(
                      label: Text(
                        event.status.name.toUpperCase(),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: _getStatusColor(event.status),
                    ),
                    onTap: () => _showEventDetails(context, event),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Welcome to Calendar Management'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "calendar_management_simple_fab",
        onPressed: () => _showCreateEventDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(dynamic status) {
    // Simple color mapping for status
    switch (status.toString()) {
      case 'scheduled':
        return Colors.blue.withValues(alpha: 0.2);
      case 'inProgress':
        return Colors.orange.withValues(alpha: 0.2);
      case 'completed':
        return Colors.green.withValues(alpha: 0.2);
      case 'cancelled':
        return Colors.red.withValues(alpha: 0.2);
      default:
        return Colors.grey.withValues(alpha: 0.2);
    }
  }

  Color _getEventTypeColor(dynamic event) {
    // Use event's color if available, otherwise use type-based color
    if (event.color != null && event.color!.isNotEmpty) {
      try {
        // Parse hex color string (assumes format like "#FF5722")
        final colorStr = event.color!.replaceAll('#', '');
        return Color(int.parse('FF$colorStr', radix: 16));
      } catch (e) {
        // Fall back to type-based color if parsing fails
      }
    }

    // Default color mapping for event types
    switch (event.eventType.name) {
      case 'meeting':
        return Colors.blue;
      case 'deadline':
        return Colors.red;
      case 'installation':
        return Colors.orange;
      case 'maintenance':
        return Colors.purple;
      case 'training':
        return Colors.green;
      case 'other':
      default:
        return Colors.grey;
    }
  }

  void _showEventDetails(BuildContext context, dynamic event) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CalendarManagementBloc>(),
        child: CalendarEventDialog(event: event),
      ),
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CalendarManagementBloc>(),
        child: const CalendarEventDialog(),
      ),
    );
  }
}
