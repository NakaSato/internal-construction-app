import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../application/calendar_management_bloc.dart';
import '../../application/calendar_management_event.dart';
import '../../application/calendar_management_state.dart';
import '../widgets/calendar_event_dialog.dart';
import '../widgets/calendar_event_list_widget.dart';
import '../widgets/calendar_filter_widget.dart';
import '../widgets/calendar_search_widget.dart';

/// Main screen for calendar management
class CalendarManagementScreen extends StatelessWidget {
  const CalendarManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.instance<CalendarManagementBloc>()
            ..add(const CalendarEventsRequested()),
      child: const CalendarManagementView(),
    );
  }
}

class CalendarManagementView extends StatelessWidget {
  const CalendarManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Management'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter Events',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
            tooltip: 'Search Events',
          ),
        ],
      ),
      body: const Column(
        children: [
          // Events list
          Expanded(child: _EventsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEventDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CalendarManagementBloc>(),
        child: const CalendarFilterWidget(),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CalendarManagementBloc>(),
        child: const CalendarSearchWidget(),
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

class _EventsList extends StatelessWidget {
  const _EventsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarManagementBloc, CalendarManagementState>(
      builder: (context, state) {
        if (state is CalendarManagementInitial) {
          return const Center(child: Text('Welcome to Calendar Management'));
        } else if (state is CalendarManagementLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CalendarEventsLoaded) {
          return CalendarEventListWidget(
            events: state.events,
            onEventTap: (event) => _showEventDetails(context, event),
          );
        } else if (state is CalendarSearchResultsLoaded) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Search results for "${state.query}" (${state.results.length} found)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Expanded(
                child: CalendarEventListWidget(
                  events: state.results,
                  onEventTap: (event) => _showEventDetails(context, event),
                ),
              ),
            ],
          );
        } else if (state is CalendarManagementError) {
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
        } else if (state is CalendarEventCreated) {
          return const Center(child: Text('Event created successfully'));
        } else if (state is CalendarEventUpdated) {
          return const Center(child: Text('Event updated successfully'));
        } else if (state is CalendarEventDeleted) {
          return const Center(child: Text('Event deleted successfully'));
        } else if (state is ConflictCheckCompleted) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.hasConflicts ? Icons.warning : Icons.check_circle,
                  size: 64,
                  color: state.hasConflicts
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  state.hasConflicts ? 'Conflicts Detected' : 'No Conflicts',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (state.hasConflicts &&
                    state.conflictingEvents.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '${state.conflictingEvents.length} conflicting events found',
                  ),
                ],
              ],
            ),
          );
        }

        return const Center(child: Text('Unknown state'));
      },
    );
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
}
