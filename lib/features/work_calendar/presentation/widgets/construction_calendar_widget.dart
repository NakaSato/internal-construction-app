import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../domain/entities/construction_task.dart';
import '../../domain/entities/work_event.dart';

/// Custom calendar widget for construction progress visualization
class ConstructionCalendarWidget extends StatefulWidget {
  const ConstructionCalendarWidget({
    super.key,
    required this.tasks,
    required this.events,
    this.onTaskTapped,
    this.onTaskCreated,
    this.view = CalendarView.month,
    this.controller,
  });

  final List<ConstructionTask> tasks;
  final List<WorkEvent> events;
  final Function(ConstructionTask)? onTaskTapped;
  final Function(DateTime)? onTaskCreated;
  final CalendarView view;
  final CalendarController? controller;

  @override
  State<ConstructionCalendarWidget> createState() =>
      _ConstructionCalendarWidgetState();
}

class _ConstructionCalendarWidgetState
    extends State<ConstructionCalendarWidget> {
  late CalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CalendarController();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate safe dimensions with fallbacks
          final availableHeight = constraints.maxHeight > 0
              ? constraints.maxHeight
              : 300.0;
          final availableWidth = constraints.maxWidth > 0
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width;

          final minCalendarHeight = 250.0;
          final maxCalendarHeight = availableHeight * 0.9;

          final calendarHeight = availableHeight > minCalendarHeight
              ? (availableHeight < maxCalendarHeight
                    ? availableHeight
                    : maxCalendarHeight)
              : minCalendarHeight;

          return Container(
            width: availableWidth,
            height: calendarHeight,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: SfCalendar(
              controller: _controller,
              view: widget.view,
              dataSource: ConstructionDataSource(
                tasks: widget.tasks,
                events: widget.events,
              ),
              monthViewSettings: MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                showAgenda: widget.view == CalendarView.month,
                agendaItemHeight: 45,
                agendaViewHeight: widget.view == CalendarView.month
                    ? (calendarHeight * 0.25).clamp(80, 150)
                    : 0,
                agendaStyle: AgendaStyle(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  appointmentTextStyle: Theme.of(context).textTheme.bodyMedium,
                  dayTextStyle: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  dateTextStyle: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                monthCellStyle: MonthCellStyle(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  todayBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  leadingDatesBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  trailingDatesBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  textStyle: Theme.of(context).textTheme.bodyMedium,
                  todayTextStyle: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              timeSlotViewSettings: const TimeSlotViewSettings(
                startHour: 6,
                endHour: 22,
                timeInterval: Duration(minutes: 30),
                timeIntervalHeight: 60,
              ),
              scheduleViewSettings: const ScheduleViewSettings(
                appointmentItemHeight: 50,
                hideEmptyScheduleWeek: true,
              ),
              appointmentBuilder: _buildAppointment,
              onTap: _onCalendarTapped,
              todayHighlightColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              cellBorderColor: Theme.of(
                context,
              ).colorScheme.outline.withOpacity(0.1),
              selectionDecoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              headerStyle: CalendarHeaderStyle(
                textAlign: TextAlign.center,
                backgroundColor: Theme.of(context).colorScheme.surface,
                textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointment(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final appointment = details.appointments.first;

    if (appointment is ConstructionTask) {
      return _buildTaskAppointment(context, appointment, details);
    } else if (appointment is WorkEvent) {
      return _buildEventAppointment(context, appointment, details);
    }

    return Container();
  }

  Widget _buildTaskAppointment(
    BuildContext context,
    ConstructionTask task,
    CalendarAppointmentDetails details,
  ) {
    final statusColor = _parseColor(task.statusColor);
    final priorityColor = _parseColor(task.priorityColor);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.8), statusColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: priorityColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Task title with progress
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(task.progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 2),

            // Progress bar
            LinearProgressIndicator(
              value: task.progress,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 2),

            // Team and priority
            Row(
              children: [
                Icon(
                  Icons.group,
                  size: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    task.assignedTeam ?? 'Unassigned',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildPriorityIcon(task.priority),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventAppointment(
    BuildContext context,
    WorkEvent event,
    CalendarAppointmentDetails details,
  ) {
    final eventColor = _getWorkEventTypeColor(event.eventType);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: eventColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: eventColor.withOpacity(0.7), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _getWorkEventTypeIcon(event.eventType),
                size: 8,
                color: eventColor,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                event.title,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityIcon(TaskPriority priority) {
    IconData iconData;
    Color color;

    switch (priority) {
      case TaskPriority.critical:
        iconData = Icons.priority_high;
        color = Colors.red.shade300;
        break;
      case TaskPriority.high:
        iconData = Icons.keyboard_arrow_up;
        color = Colors.orange.shade300;
        break;
      case TaskPriority.medium:
        iconData = Icons.remove;
        color = Colors.yellow.shade300;
        break;
      case TaskPriority.low:
        iconData = Icons.keyboard_arrow_down;
        color = Colors.green.shade300;
        break;
    }

    return Icon(iconData, size: 12, color: color);
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      final appointment = details.appointments!.first;

      if (appointment is ConstructionTask) {
        widget.onTaskTapped?.call(appointment);
      }
    } else if (details.targetElement == CalendarElement.calendarCell) {
      widget.onTaskCreated?.call(details.date!);
    }
  }

  Color _parseColor(String colorString) {
    try {
      final hexColor = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getWorkEventTypeColor(WorkEventType eventType) {
    switch (eventType) {
      case WorkEventType.meeting:
        return Colors.blue.shade600;
      case WorkEventType.appointment:
        return Colors.orange.shade600;
      case WorkEventType.task:
        return Colors.green.shade600;
      case WorkEventType.reminder:
        return Colors.purple.shade600;
      case WorkEventType.training:
        return Colors.teal.shade600;
      case WorkEventType.conference:
        return Colors.red.shade600;
      case WorkEventType.break_:
        return Colors.cyan.shade600;
      case WorkEventType.travel:
        return Colors.brown.shade600;
      case WorkEventType.other:
        return Colors.grey.shade600;
    }
  }

  IconData _getWorkEventTypeIcon(WorkEventType eventType) {
    switch (eventType) {
      case WorkEventType.meeting:
        return Icons.group;
      case WorkEventType.appointment:
        return Icons.calendar_today;
      case WorkEventType.task:
        return Icons.task;
      case WorkEventType.reminder:
        return Icons.notifications;
      case WorkEventType.training:
        return Icons.school;
      case WorkEventType.conference:
        return Icons.video_call;
      case WorkEventType.break_:
        return Icons.coffee;
      case WorkEventType.travel:
        return Icons.directions_car;
      case WorkEventType.other:
        return Icons.event;
    }
  }
}

/// Data source for construction calendar
class ConstructionDataSource extends CalendarDataSource {
  ConstructionDataSource({
    required List<ConstructionTask> tasks,
    required List<WorkEvent> events,
  }) {
    appointments = [
      ...tasks.map(_taskToAppointment),
      ...events.map(_eventToAppointment),
    ];
  }

  Appointment _taskToAppointment(ConstructionTask task) {
    return Appointment(
      startTime: task.startDate,
      endTime: task.endDate,
      subject: task.title,
      notes: task.description,
      color: _parseColor(task.statusColor),
    );
  }

  Appointment _eventToAppointment(WorkEvent event) {
    return Appointment(
      startTime: event.startTime,
      endTime: event.endTime,
      subject: event.title,
      notes: event.description,
      color: _getWorkEventTypeColor(event.eventType),
    );
  }

  Color _parseColor(String colorString) {
    try {
      final hexColor = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }

  Color _getWorkEventTypeColor(WorkEventType eventType) {
    switch (eventType) {
      case WorkEventType.meeting:
        return Colors.blue.shade600;
      case WorkEventType.appointment:
        return Colors.orange.shade600;
      case WorkEventType.task:
        return Colors.green.shade600;
      case WorkEventType.reminder:
        return Colors.purple.shade600;
      case WorkEventType.training:
        return Colors.teal.shade600;
      case WorkEventType.conference:
        return Colors.red.shade600;
      case WorkEventType.break_:
        return Colors.cyan.shade600;
      case WorkEventType.travel:
        return Colors.brown.shade600;
      case WorkEventType.other:
        return Colors.grey.shade600;
    }
  }
}
