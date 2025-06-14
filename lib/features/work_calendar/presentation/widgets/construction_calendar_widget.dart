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
    return SfCalendar(
      controller: _controller,
      view: widget.view,
      dataSource: ConstructionDataSource(
        tasks: widget.tasks,
        events: widget.events,
      ),
      monthViewSettings: MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        showAgenda: true,
        agendaStyle: AgendaStyle(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appointmentTextStyle: Theme.of(context).textTheme.bodyMedium,
          dayTextStyle: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          dateTextStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        monthCellStyle: MonthCellStyle(
          backgroundColor: Theme.of(context).colorScheme.surface,
          todayBackgroundColor: Theme.of(context).colorScheme.primaryContainer,
          leadingDatesBackgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceVariant,
          trailingDatesBackgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceVariant,
          textStyle: Theme.of(context).textTheme.bodyMedium,
          todayTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
      appointmentBuilder: _buildAppointment,
      onTap: _onCalendarTapped,
      todayHighlightColor: Theme.of(context).colorScheme.primary,
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
        border: Border.all(
          color: priorityColor,
          width: task.priority == TaskPriority.critical ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (task.isOverdue)
                  const Icon(Icons.warning, color: Colors.white, size: 14),
              ],
            ),
          ),

          // Progress bar
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.progress > 0) ...[
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: task.progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],

                  // Progress percentage and status
                  Text(
                    '${(task.progress * 100).toInt()}% • ${task.status.displayName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (task.assignedTeam != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      task.assignedTeam!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventAppointment(
    BuildContext context,
    WorkEvent event,
    CalendarAppointmentDetails details,
  ) {
    final eventColor = _getEventTypeColor(event.eventType);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: eventColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: eventColor.withOpacity(0.8), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getEventTypeIcon(event.eventType),
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (event.location != null) ...[
              const SizedBox(height: 2),
              Text(
                event.location!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 9,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      final appointment = details.appointments!.first;

      if (appointment is ConstructionTask) {
        widget.onTaskTapped?.call(appointment);
      } else if (appointment is WorkEvent) {
        // Handle work event tap if needed
      }
    } else if (details.targetElement == CalendarElement.calendarCell) {
      widget.onTaskCreated?.call(details.date!);
    }
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue; // Fallback color
    }
  }

  Color _getEventTypeColor(WorkEventType type) {
    switch (type) {
      case WorkEventType.meeting:
        return Colors.blue;
      case WorkEventType.task:
        return Colors.green;
      case WorkEventType.reminder:
        return Colors.orange;
      case WorkEventType.appointment:
        return Colors.purple;
      case WorkEventType.break_:
        return Colors.red;
      case WorkEventType.travel:
        return Colors.brown;
      case WorkEventType.training:
        return Colors.indigo;
      case WorkEventType.conference:
        return Colors.pink;
      case WorkEventType.other:
        return Colors.teal;
    }
  }

  IconData _getEventTypeIcon(WorkEventType type) {
    switch (type) {
      case WorkEventType.meeting:
        return Icons.people;
      case WorkEventType.task:
        return Icons.task;
      case WorkEventType.reminder:
        return Icons.notifications;
      case WorkEventType.appointment:
        return Icons.event;
      case WorkEventType.break_:
        return Icons.coffee;
      case WorkEventType.travel:
        return Icons.directions_car;
      case WorkEventType.training:
        return Icons.school;
      case WorkEventType.conference:
        return Icons.video_call;
      case WorkEventType.other:
        return Icons.circle;
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
      id: task.id,
      subject: task.title,
      startTime: task.startDate,
      endTime: task.endDate.add(const Duration(hours: 23, minutes: 59)),
      color: _parseColor(task.statusColor),
      notes: task.description,
      isAllDay: task.durationInDays > 1,
    );
  }

  Appointment _eventToAppointment(WorkEvent event) {
    return Appointment(
      id: event.id,
      subject: event.title,
      startTime: event.startTime,
      endTime: event.endTime,
      color: _getEventTypeColor(event.eventType),
      notes: event.description,
      location: event.location,
      isAllDay: event.isAllDay,
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  Color _getEventTypeColor(WorkEventType type) {
    switch (type) {
      case WorkEventType.meeting:
        return Colors.blue;
      case WorkEventType.task:
        return Colors.green;
      case WorkEventType.reminder:
        return Colors.orange;
      case WorkEventType.appointment:
        return Colors.purple;
      case WorkEventType.break_:
        return Colors.red;
      case WorkEventType.travel:
        return Colors.brown;
      case WorkEventType.training:
        return Colors.indigo;
      case WorkEventType.conference:
        return Colors.pink;
      case WorkEventType.other:
        return Colors.teal;
    }
  }
}
