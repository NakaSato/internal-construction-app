import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'calendar_management/application/calendar_management_bloc.dart';
import 'calendar_management/application/calendar_management_event.dart';
import 'calendar_management/application/calendar_management_state.dart';
import 'calendar_management/domain/entities/calendar_event.dart';
import 'calendar_management/presentation/widgets/calendar_event_dialog.dart';
import 'calendar_management/presentation/widgets/calendar_filter_widget.dart';
import 'calendar_management/presentation/widgets/calendar_search_widget.dart';

/// Comprehensive demo showcasing the Calendar Management API functionality
class CalendarManagementApiDemo extends StatefulWidget {
  const CalendarManagementApiDemo({super.key});

  @override
  State<CalendarManagementApiDemo> createState() => _CalendarManagementApiDemoState();
}

/// Helper function to convert hex color string to Color object
Color _parseColor(String hexColor) {
  try {
    return Color(int.parse(hexColor.replaceFirst('#', '0xff')));
  } catch (e) {
    return Colors.grey; // Fallback color
  }
}

class _CalendarManagementApiDemoState extends State<CalendarManagementApiDemo>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<CalendarManagementBloc>()
        ..add(const CalendarEventsRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Calendar Management API Demo'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.calendar_today), text: 'Events'),
              Tab(icon: Icon(Icons.category), text: 'Types & Status'),
              Tab(icon: Icon(Icons.api), text: 'API Features'),
              Tab(icon: Icon(Icons.info), text: 'Documentation'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            _EventsTab(),
            _TypesStatusTab(),
            _ApiFeaturesTab(),
            _DocumentationTab(),
          ],
        ),
      ),
    );
  }
}

/// Events management tab
class _EventsTab extends StatelessWidget {
  const _EventsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Action buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateEventDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Event'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showFilterDialog(context),
                icon: const Icon(Icons.filter_list),
                label: const Text('Filter'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showSearchDialog(context),
                icon: const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ],
          ),
        ),
        // Events list
        Expanded(
          child: BlocBuilder<CalendarManagementBloc, CalendarManagementState>(
            builder: (context, state) {
              if (state is CalendarManagementLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CalendarManagementError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading events',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CalendarManagementBloc>()
                              .add(const CalendarEventsRequested());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is CalendarEventsLoaded) {
                if (state.events.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64),
                        SizedBox(height: 16),
                        Text(
                          'No events found',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        Text('Create your first calendar event to get started'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: state.events.length,
                  itemBuilder: (context, index) {
                    final event = state.events[index];
                    return _EventCard(event: event);
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
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
}

/// Event card widget
class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    final colorValue = event.color ?? event.eventType.defaultColor;
    final eventColor = _parseColor(colorValue);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _showEventDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and status
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: eventColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _StatusChip(status: event.status),
                ],
              ),
              const SizedBox(height: 8),
              // Event details
              Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          icon: Icons.access_time,
                          text: _formatDateTime(event.startDateTime, event.endDateTime),
                        ),
                        if (event.location?.isNotEmpty == true)
                          _InfoRow(
                            icon: Icons.location_on,
                            text: event.location!,
                          ),
                        _InfoRow(
                          icon: Icons.category,
                          text: event.eventType.displayName,
                        ),
                        _InfoRow(
                          icon: Icons.priority_high,
                          text: event.priority.displayName,
                          color: _parseColor(event.priority.hexColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (event.description?.isNotEmpty == true) ...[
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(event.description!),
                const SizedBox(height: 16),
              ],
              Text(
                'Event Details',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.access_time,
                text: _formatDateTime(event.startDateTime, event.endDateTime),
              ),
              _InfoRow(
                icon: Icons.category,
                text: event.eventType.displayName,
              ),
              _InfoRow(
                icon: Icons.flag,
                text: event.status.displayName,
              ),
              _InfoRow(
                icon: Icons.priority_high,
                text: event.priority.displayName,
              ),
              if (event.location?.isNotEmpty == true)
                _InfoRow(
                  icon: Icons.location_on,
                  text: event.location!,
                ),
              if (event.projectName?.isNotEmpty == true)
                _InfoRow(
                  icon: Icons.folder,
                  text: 'Project: ${event.projectName!}',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime start, DateTime end) {
    final startStr = '${start.day}/${start.month} ${start.hour}:${start.minute.toString().padLeft(2, '0')}';
    final endStr = '${end.hour}:${end.minute.toString().padLeft(2, '0')}';
    return '$startStr - $endStr';
  }
}

/// Status chip widget
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final CalendarEventStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(status.color);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Info row widget
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color ?? Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Types and status demonstration tab
class _TypesStatusTab extends StatelessWidget {
  const _TypesStatusTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Types
          Text(
            'Event Types',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...CalendarEventType.values.map((type) => _TypeCard(
            title: type.displayName,
            description: type.description,
            color: _parseColor(type.defaultColor),
            value: type.value.toString(),
          )),
          const SizedBox(height: 32),
          
          // Event Status
          Text(
            'Event Status',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...CalendarEventStatus.values.map((status) => _StatusCard(
            title: status.displayName,
            color: _parseColor(status.color),
            value: status.value.toString(),
          )),
          const SizedBox(height: 32),
          
          // Event Priority
          Text(
            'Event Priority',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...CalendarEventPriority.values.map((priority) => _PriorityCard(
            title: priority.displayName,
            color: _parseColor(priority.hexColor),
            value: priority.value.toString(),
          )),
        ],
      ),
    );
  }
}

/// Type card widget
class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.title,
    required this.description,
    required this.color,
    required this.value,
  });

  final String title;
  final String description;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status card widget
class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.color,
    required this.value,
  });

  final String title;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Priority card widget
class _PriorityCard extends StatelessWidget {
  const _PriorityCard({
    required this.title,
    required this.color,
    required this.value,
  });

  final String title;
  final Color color;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// API features demonstration tab
class _ApiFeaturesTab extends StatelessWidget {
  const _ApiFeaturesTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available API Features',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _FeatureCard(
            title: 'CRUD Operations',
            description: 'Create, Read, Update, Delete calendar events',
            icon: Icons.edit,
            features: [
              'Create new events with full details',
              'Retrieve events by ID',
              'Update existing events',
              'Delete events',
            ],
          ),
          
          _FeatureCard(
            title: 'Advanced Filtering',
            description: 'Filter events by multiple criteria',
            icon: Icons.filter_list,
            features: [
              'Date range filtering',
              'Event type filtering',
              'Status and priority filtering',
              'Project and task association',
              'User assignment filtering',
            ],
          ),
          
          _FeatureCard(
            title: 'Search & Query',
            description: 'Search events with flexible queries',
            icon: Icons.search,
            features: [
              'Text search in titles and descriptions',
              'Date-based queries',
              'Advanced query parameters',
              'Pagination support',
            ],
          ),
          
          _FeatureCard(
            title: 'Project Integration',
            description: 'Link events to projects and tasks',
            icon: Icons.folder,
            features: [
              'Associate events with projects',
              'Link to specific tasks',
              'Project-based event retrieval',
              'Task-based event filtering',
            ],
          ),
          
          _FeatureCard(
            title: 'Conflict Detection',
            description: 'Detect scheduling conflicts',
            icon: Icons.warning,
            features: [
              'Check for time conflicts',
              'User availability checking',
              'Resource conflict detection',
              'Conflict resolution suggestions',
            ],
          ),
          
          _FeatureCard(
            title: 'User Management',
            description: 'Assign and manage event participants',
            icon: Icons.people,
            features: [
              'Assign events to users',
              'Track event creators',
              'Attendee management',
              'User-specific event queries',
            ],
          ),
        ],
      ),
    );
  }
}

/// Feature card widget
class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.features,
  });

  final String title;
  final String description;
  final IconData icon;
  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

/// Documentation tab
class _DocumentationTab extends StatelessWidget {
  const _DocumentationTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendar Management API',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '🔒 Authentication Required',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.orange[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'The Calendar API provides comprehensive event planning and scheduling functionality for solar projects. It supports CRUD operations, advanced filtering, event associations with projects and tasks, conflict detection, and recurring events (future implementation).',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          _DocumentationSection(
            title: 'Base URL',
            content: '/api/v1/calendar',
          ),
          
          _DocumentationSection(
            title: 'Key Endpoints',
            content: '''
• GET /api/v1/calendar - Get all events with filtering
• GET /api/v1/calendar/{eventId} - Get event by ID
• POST /api/v1/calendar - Create new event
• PUT /api/v1/calendar/{eventId} - Update event
• DELETE /api/v1/calendar/{eventId} - Delete event
• GET /api/v1/calendar/project/{projectId} - Get project events
• GET /api/v1/calendar/upcoming - Get upcoming events
• POST /api/v1/calendar/conflicts - Check conflicts
            ''',
          ),
          
          _DocumentationSection(
            title: 'Query Parameters',
            content: '''
• startDate, endDate - Date range filtering
• eventType - Filter by event type (1-6)
• status - Filter by status (1-5)
• priority - Filter by priority (1-4)
• projectId, taskId - Association filtering
• pageNumber, pageSize - Pagination
• userId - User-specific filtering
            ''',
          ),
          
          _DocumentationSection(
            title: 'Response Format',
            content: '''
All responses follow the standard API format:
{
  "success": boolean,
  "message": string,
  "data": object,
  "errors": array
}
            ''',
          ),
          
          _DocumentationSection(
            title: 'Future Features',
            content: '''
• Recurring Events (GET/POST/PUT/DELETE /api/v1/calendar/recurring)
• Advanced Conflict Resolution
• Calendar Sync with External Systems
• Team Calendar Views
• Event Templates
            ''',
          ),
        ],
      ),
    );
  }
}

/// Documentation section widget
class _DocumentationSection extends StatelessWidget {
  const _DocumentationSection({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
