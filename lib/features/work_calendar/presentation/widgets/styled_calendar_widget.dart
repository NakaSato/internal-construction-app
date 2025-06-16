import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../domain/entities/construction_task.dart';
import '../../domain/entities/work_event.dart';

/// A modern styled calendar widget following Material Design 3 principles
/// for construction project management.
class StyledCalendarWidget extends StatefulWidget {
  /// Creates a styled calendar widget with modern Material Design 3 aesthetics.
  const StyledCalendarWidget({
    super.key,
    required this.tasks,
    required this.events,
    this.onTaskTapped,
    this.onTaskCreated,
    this.onEventTapped,
    this.controller,
    this.view = CalendarView.month,
    this.showNavigationArrows = true,
    this.showDatePickerButton = true,
    this.initialSelectedDate,
  });

  /// Construction tasks to display on the calendar
  final List<ConstructionTask> tasks;

  /// Work events to display on the calendar
  final List<WorkEvent> events;

  /// Callback when a task is tapped
  final Function(ConstructionTask)? onTaskTapped;

  /// Callback when a new task is created
  final Function(DateTime)? onTaskCreated;

  /// Callback when an event is tapped
  final Function(WorkEvent)? onEventTapped;

  /// Optional calendar controller
  final CalendarController? controller;

  /// Calendar view type (month, week, day, schedule)
  final CalendarView view;

  /// Whether to show navigation arrows
  final bool showNavigationArrows;

  /// Whether to show the date picker button
  final bool showDatePickerButton;

  /// Initial selected date
  final DateTime? initialSelectedDate;

  @override
  State<StyledCalendarWidget> createState() => _StyledCalendarWidgetState();
}

class _StyledCalendarWidgetState extends State<StyledCalendarWidget> {
  late CalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? CalendarController();
    _controller.view = widget.view;

    if (widget.initialSelectedDate != null) {
      _controller.selectedDate = widget.initialSelectedDate;
      _controller.displayDate = widget.initialSelectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: SfCalendar(
          controller: _controller,
          view: widget.view,
          showNavigationArrow: widget.showNavigationArrows,
          showDatePickerButton: widget.showDatePickerButton,
          dataSource: _getCalendarDataSource(),
          onTap: _onCalendarTapped,
          todayHighlightColor: colorScheme.primary,
          cellBorderColor: colorScheme.outlineVariant.withOpacity(0.2),
          backgroundColor: colorScheme.surface,
          appointmentBuilder: _buildAppointment,

          // Enhanced selection decoration with subtle gradient and glow effect
          selectionDecoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.05),
            border: Border.all(color: colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.15),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer.withOpacity(0.1),
                colorScheme.primary.withOpacity(0.08),
              ],
            ),
          ),

          // Modern header styling with gradient and improved typography
          headerStyle: CalendarHeaderStyle(
            textAlign: TextAlign.center,
            backgroundColor: colorScheme.surfaceVariant,
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),

          // Enhanced view header styling with subtle gradient and improved typography
          viewHeaderStyle: ViewHeaderStyle(
            backgroundColor: colorScheme.surfaceVariant.withOpacity(0.7),
            dayTextStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            dateTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Month view settings with enhanced styling
          monthViewSettings: MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            showAgenda: true,
            dayFormat: 'EEE',
            agendaStyle: AgendaStyle(
              backgroundColor: colorScheme.surface,
              appointmentTextStyle: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
              dayTextStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
              dateTextStyle: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: colorScheme.secondary),
            ),
            monthCellStyle: MonthCellStyle(
              backgroundColor: colorScheme.surface,
              todayBackgroundColor: colorScheme.primaryContainer.withOpacity(
                0.3,
              ),
              leadingDatesBackgroundColor: colorScheme.surfaceVariant
                  .withOpacity(0.4),
              trailingDatesBackgroundColor: colorScheme.surfaceVariant
                  .withOpacity(0.4),
              textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              leadingDatesTextStyle: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 11,
                  ),
              trailingDatesTextStyle: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                    fontSize: 11,
                  ),
              todayTextStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            agendaViewHeight: 150,
            navigationDirection: MonthNavigationDirection.horizontal,
          ), // Enhanced time slot view settings with modern styling
          timeSlotViewSettings: TimeSlotViewSettings(
            startHour: 6,
            endHour: 22,
            timeInterval: const Duration(minutes: 30),
            timeIntervalHeight: 60,
            timeFormat: 'HH:mm',
            dateFormat: 'd',
            dayFormat: 'EEE',
            timeTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
            timeRulerSize: 64,
            nonWorkingDays: const <int>[DateTime.saturday, DateTime.sunday],
          ),
        ),
      ),
    );
  }

  CalendarDataSource _getCalendarDataSource() {
    return ConstructionDataSource(tasks: widget.tasks, events: widget.events);
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      final appointment = details.appointments?.first;
      if (appointment is ConstructionTask && widget.onTaskTapped != null) {
        widget.onTaskTapped!(appointment);
      } else if (appointment is WorkEvent && widget.onEventTapped != null) {
        widget.onEventTapped!(appointment);
      }
    } else if (details.targetElement == CalendarElement.calendarCell &&
        widget.onTaskCreated != null) {
      widget.onTaskCreated!(details.date ?? DateTime.now());
    }
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
    final isCompact = details.bounds.width < 100 || details.bounds.height < 30;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.85),
            statusColor,
            statusColor.withOpacity(0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: priorityColor,
          width: task.priority == TaskPriority.critical ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: isCompact
              ? _buildCompactTaskDisplay(context, task)
              : _buildDetailedTaskDisplay(context, task),
        ),
      ),
    );
  }

  Widget _buildCompactTaskDisplay(BuildContext context, ConstructionTask task) {
    return Center(
      child: Icon(_getTaskIcon(task.status), color: Colors.white, size: 16),
    );
  }

  Widget _buildDetailedTaskDisplay(
    BuildContext context,
    ConstructionTask task,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(_getTaskIcon(task.status), color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                task.title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (task.assignedTeam != null && task.assignedTeam!.isNotEmpty)
          Text(
            'Assigned: ${task.assignedTeam}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Widget _buildEventAppointment(
    BuildContext context,
    WorkEvent event,
    CalendarAppointmentDetails details,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final eventColor = event.color != null
        ? _parseColor(event.color!)
        : colorScheme.tertiary;
    final isCompact = details.bounds.width < 100 || details.bounds.height < 30;

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [eventColor.withOpacity(0.15), eventColor.withOpacity(0.25)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: eventColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: eventColor.withOpacity(0.15),
            blurRadius: 4,
            spreadRadius: 0.5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: isCompact
              ? Center(child: Icon(Icons.event, color: eventColor, size: 14))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.event, color: eventColor, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.title,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (event.description != null &&
                        event.description!.isNotEmpty)
                      Text(
                        event.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  IconData _getTaskIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return Icons.schedule;
      case TaskStatus.inProgress:
        return Icons.construction;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.delayed:
        return Icons.warning;
      case TaskStatus.onHold:
        return Icons.pause_circle;
      case TaskStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        String hexColor = colorString.replaceAll('#', '');
        if (hexColor.length == 6) {
          hexColor = 'FF$hexColor';
        }
        return Color(int.parse('0x$hexColor'));
      } else if (colorString.startsWith('0x')) {
        return Color(int.parse(colorString));
      }
    } catch (e) {
      // Return a default color if parsing fails
    }

    // Default color by name
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'amber':
        return Colors.amber;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }
}

/// Custom calendar data source for construction tasks and work events
class ConstructionDataSource extends CalendarDataSource {
  ConstructionDataSource({
    required List<ConstructionTask> tasks,
    required List<WorkEvent> events,
  }) {
    appointments = [...tasks, ...events];
  }

  @override
  DateTime getStartTime(int index) {
    final appointment = appointments![index];
    if (appointment is ConstructionTask) {
      return appointment.startDate;
    } else if (appointment is WorkEvent) {
      return appointment.startTime;
    }
    return DateTime.now();
  }

  @override
  DateTime getEndTime(int index) {
    final appointment = appointments![index];
    if (appointment is ConstructionTask) {
      return appointment.endDate;
    } else if (appointment is WorkEvent) {
      return appointment.endTime;
    }
    return DateTime.now();
  }

  @override
  String getSubject(int index) {
    final appointment = appointments![index];
    if (appointment is ConstructionTask) {
      return appointment.title;
    } else if (appointment is WorkEvent) {
      return appointment.title;
    }
    return '';
  }

  @override
  Color getColor(int index) {
    final appointment = appointments![index];
    if (appointment is ConstructionTask) {
      return _parseColor(appointment.statusColor);
    } else if (appointment is WorkEvent) {
      return appointment.color != null
          ? _parseColor(appointment.color!)
          : Colors.blue;
    }
    return Colors.blue;
  }

  @override
  bool isAllDay(int index) {
    final appointment = appointments![index];
    if (appointment is ConstructionTask) {
      // Construction tasks are typically all-day events
      return true;
    } else if (appointment is WorkEvent) {
      return appointment.isAllDay;
    }
    return false;
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        String hexColor = colorString.replaceAll('#', '');
        if (hexColor.length == 6) {
          hexColor = 'FF$hexColor';
        }
        return Color(int.parse('0x$hexColor'));
      } else if (colorString.startsWith('0x')) {
        return Color(int.parse(colorString));
      }
    } catch (e) {
      // Return a default color if parsing fails
    }

    // Default color by name
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'amber':
        return Colors.amber;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }
}
