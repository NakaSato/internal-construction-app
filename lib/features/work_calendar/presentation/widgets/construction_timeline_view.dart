import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../domain/entities/construction_task.dart';

/// Timeline view specifically designed for construction project visualization
class ConstructionTimelineView extends StatefulWidget {
  const ConstructionTimelineView({
    super.key,
    required this.tasks,
    required this.projectId,
    this.onTaskTapped,
    this.onTaskCreated,
  });

  final List<ConstructionTask> tasks;
  final String projectId;
  final Function(ConstructionTask)? onTaskTapped;
  final Function(DateTime)? onTaskCreated;

  @override
  State<ConstructionTimelineView> createState() =>
      _ConstructionTimelineViewState();
}

class _ConstructionTimelineViewState extends State<ConstructionTimelineView> {
  late CalendarController _controller;
  CalendarView _currentView = CalendarView.timelineWeek;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectTasks = widget.tasks
        .where((task) => task.projectId == widget.projectId)
        .toList();

    return Column(
      children: [
        _buildTimelineHeader(),
        Expanded(
          child: SfCalendar(
            controller: _controller,
            view: _currentView,
            dataSource: ConstructionTimelineDataSource(projectTasks),
            timeSlotViewSettings: const TimeSlotViewSettings(
              timelineAppointmentHeight: 80,
              timeInterval: Duration(hours: 6),
              timeFormat: 'HH:mm',
              dateFormat: 'dd MMM',
              dayFormat: 'EEE',
            ),
            resourceViewSettings: ResourceViewSettings(
              size: 150,
              displayNameTextStyle: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            appointmentBuilder: _buildTimelineAppointment,
            onTap: _onTimelineTapped,
            headerStyle: CalendarHeaderStyle(
              textAlign: TextAlign.center,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              textStyle: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            todayHighlightColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        _buildTimelineLegend(),
      ],
    );
  }

  Widget _buildTimelineHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timeline,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Construction Timeline - ${widget.projectId}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          PopupMenuButton<CalendarView>(
            icon: Icon(
              Icons.view_module,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            onSelected: (view) {
              setState(() {
                _currentView = view;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarView.timelineDay,
                child: Text('Timeline Day'),
              ),
              const PopupMenuItem(
                value: CalendarView.timelineWeek,
                child: Text('Timeline Week'),
              ),
              const PopupMenuItem(
                value: CalendarView.timelineMonth,
                child: Text('Timeline Month'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineAppointment(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final task = details.appointments.first as ConstructionTask;
    final statusColor = _parseColor(task.statusColor);
    final priorityColor = _parseColor(task.priorityColor);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.9), statusColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: priorityColor,
          width: task.priority == TaskPriority.critical ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task header
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (task.isOverdue)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 4),

            // Progress bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: task.progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // Task details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(task.progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (task.assignedTeam != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.assignedTeam!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 2),

            // Priority indicator
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  task.priority.displayName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  '${task.durationInDays}d',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('Status:', [
                _buildLegendColor('Not Started', _parseColor('#9E9E9E')),
                _buildLegendColor('In Progress', _parseColor('#2196F3')),
                _buildLegendColor('Completed', _parseColor('#4CAF50')),
                _buildLegendColor('Delayed', _parseColor('#FF9800')),
              ]),
              _buildLegendItem('Priority:', [
                _buildLegendColor('Low', _parseColor('#8BC34A')),
                _buildLegendColor('Medium', _parseColor('#FF9800')),
                _buildLegendColor('High', _parseColor('#FF5722')),
                _buildLegendColor('Critical', _parseColor('#F44336')),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Wrap(spacing: 8, children: items),
      ],
    );
  }

  Widget _buildLegendColor(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  void _onTimelineTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      final task = details.appointments!.first as ConstructionTask;
      widget.onTaskTapped?.call(task);
    } else if (details.targetElement == CalendarElement.calendarCell) {
      widget.onTaskCreated?.call(details.date!);
    }
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}

/// Data source for construction timeline view
class ConstructionTimelineDataSource extends CalendarDataSource {
  ConstructionTimelineDataSource(List<ConstructionTask> tasks) {
    appointments = tasks;
    resources = _buildResources(tasks);
  }

  List<CalendarResource> _buildResources(List<ConstructionTask> tasks) {
    final teams = tasks
        .where((task) => task.assignedTeam != null)
        .map((task) => task.assignedTeam!)
        .toSet()
        .toList();

    if (teams.isEmpty) {
      teams.add('Unassigned');
    }

    return teams.map((team) {
      return CalendarResource(
        displayName: team,
        id: team,
        color: _getTeamColor(team),
      );
    }).toList();
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startDate;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endDate.add(const Duration(hours: 18));
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  Color getColor(int index) {
    final task = appointments![index] as ConstructionTask;
    return _parseColor(task.statusColor);
  }

  @override
  List<Object> getResourceIds(int index) {
    final task = appointments![index] as ConstructionTask;
    return [task.assignedTeam ?? 'Unassigned'];
  }

  Color _getTeamColor(String team) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];
    return colors[team.hashCode % colors.length];
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }
}
