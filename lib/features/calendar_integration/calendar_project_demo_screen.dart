import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/widgets/enhanced_table_calendar.dart';
import '../../features/project_management/application/project_bloc.dart';
import '../../features/project_management/application/project_event.dart';
import '../../features/project_management/application/project_state.dart';
import '../../features/project_management/domain/entities/project.dart';

/// Demo screen showcasing the enhanced table calendar with project integration
class CalendarProjectDemoScreen extends StatefulWidget {
  const CalendarProjectDemoScreen({super.key});

  @override
  State<CalendarProjectDemoScreen> createState() =>
      _CalendarProjectDemoScreenState();
}

class _CalendarProjectDemoScreenState extends State<CalendarProjectDemoScreen> {
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    // Load projects when screen initializes
    context.read<ProjectBloc>().add(const ProjectLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Calendar with Projects'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
              });
            },
            tooltip: 'Go to Today',
          ),
        ],
      ),
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectLoaded) {
            setState(() {
              _projects = state.projects;
            });
          } else if (state is ProjectOperationSuccess) {
            setState(() {
              _projects = state.projects;
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced Table Calendar
              EnhancedTableCalendar(
                selectedDay: _selectedDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  // Focus day changed, no state tracking needed
                },
                eventLoader: _getEventsForDay,
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Project deadlines section
              _buildProjectDeadlinesSection(),

              const SizedBox(height: 24),

              // Selected day projects
              _buildSelectedDayProjects(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCalendarInfo(context),
        icon: const Icon(Icons.info_outline),
        label: const Text('Calendar Info'),
      ),
    );
  }

  Widget _buildProjectDeadlinesSection() {
    final theme = Theme.of(context);
    final upcomingProjects = _projects.where((project) {
      if (project.dueDate == null) return false;
      final now = DateTime.now();
      final dueDate = project.dueDate!;
      return dueDate.isAfter(now) &&
          dueDate.isBefore(now.add(const Duration(days: 30)));
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Upcoming Project Deadlines',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (upcomingProjects.isEmpty)
              Text(
                'No upcoming deadlines in the next 30 days',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...upcomingProjects.map(
                (project) => _buildProjectDeadlineItem(project),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectDeadlineItem(Project project) {
    final theme = Theme.of(context);
    final daysUntilDue = project.dueDate!.difference(DateTime.now()).inDays;
    final isOverdue = project.isOverdue;
    final isUrgent = daysUntilDue <= 7;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOverdue
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.3)
            : isUrgent
            ? theme.colorScheme.tertiary.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            width: 4,
            color: isOverdue
                ? theme.colorScheme.error
                : isUrgent
                ? Colors.orange
                : theme.colorScheme.primary,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Due: ${_formatDate(project.dueDate!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOverdue
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOverdue
                  ? theme.colorScheme.error
                  : isUrgent
                  ? Colors.orange
                  : theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isOverdue ? 'Overdue' : '$daysUntilDue days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayProjects() {
    final theme = Theme.of(context);
    final selectedDayProjects = _getProjectsForDay(_selectedDay);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_note, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Projects for ${_formatSelectedDay(_selectedDay)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (selectedDayProjects.isEmpty)
              Text(
                'No projects due on this date',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ...selectedDayProjects.map(
                (project) => _buildProjectItem(project),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectItem(Project project) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getStatusColor(project.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${project.status.displayName} • ${project.completionPercentage}% complete',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Chip(
            label: Text(
              project.priority.displayName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: _getPriorityColor(project.priority),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  List<Project> _getEventsForDay(DateTime day) {
    return _getProjectsForDay(day);
  }

  List<Project> _getProjectsForDay(DateTime day) {
    return _projects.where((project) {
      if (project.dueDate == null) return false;
      return isSameDay(project.dueDate!, day);
    }).toList();
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.blue;
      case ProjectStatus.inProgress:
        return Colors.orange;
      case ProjectStatus.onHold:
        return Colors.grey;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getPriorityColor(ProjectPriority priority) {
    switch (priority) {
      case ProjectPriority.low:
        return Colors.green.shade400;
      case ProjectPriority.medium:
        return Colors.orange.shade400;
      case ProjectPriority.high:
        return Colors.red.shade400;
      case ProjectPriority.urgent:
        return Colors.red.shade700;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _formatSelectedDay(DateTime date) {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
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

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  void _showCalendarInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enhanced Calendar Features'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🗓️ Interactive Calendar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Tap any date to select it'),
              Text('• Navigate months with arrow buttons'),
              Text('• Switch between Month/2 weeks/Week views'),
              SizedBox(height: 12),

              Text(
                '📅 Project Integration',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Project deadlines show as events'),
              Text('• Upcoming deadlines highlighted'),
              Text('• View projects due on selected date'),
              SizedBox(height: 12),

              Text(
                '🎨 Visual Indicators',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Today highlighted in secondary color'),
              Text('• Selected day highlighted in primary color'),
              Text('• Event markers show project deadlines'),
              Text('• Color-coded priority and status'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
