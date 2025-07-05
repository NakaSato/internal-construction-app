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

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate safe dimensions with fallbacks
          final availableHeight = constraints.maxHeight > 0
              ? constraints.maxHeight
              : 400.0;
          final availableWidth = constraints.maxWidth > 0
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width - 32;

          final minCalendarHeight = 300.0;
          final maxCalendarHeight = availableHeight * 0.95;

          final calendarHeight = availableHeight > minCalendarHeight
              ? (availableHeight < maxCalendarHeight
                    ? availableHeight
                    : maxCalendarHeight)
              : minCalendarHeight;

          return Container(
            width: availableWidth,
            height: calendarHeight,
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
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),

                // Enhanced view header styling with subtle gradient and improved typography
                viewHeaderStyle: ViewHeaderStyle(
                  backgroundColor: colorScheme.surfaceContainerHighest
                      .withOpacity(0.7),
                  dayTextStyle: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                  dateTextStyle: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),

                // Month view settings with enhanced styling
                monthViewSettings: MonthViewSettings(
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment,
                  showAgenda: widget.view == CalendarView.month,
                  dayFormat: 'EEE',
                  agendaItemHeight: 50,
                  agendaViewHeight: widget.view == CalendarView.month
                      ? (calendarHeight * 0.25).clamp(100, 200)
                      : 0,
                  agendaStyle: AgendaStyle(
                    backgroundColor: colorScheme.surface,
                    appointmentTextStyle: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurface),
                    dayTextStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                    dateTextStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: colorScheme.secondary),
                  ),
                  monthCellStyle: MonthCellStyle(
                    backgroundColor: colorScheme.surface,
                    todayBackgroundColor: colorScheme.primaryContainer
                        .withOpacity(0.3),
                    leadingDatesBackgroundColor: colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.4),
                    trailingDatesBackgroundColor: colorScheme
                        .surfaceContainerHighest
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
                    trailingDatesTextStyle: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                          fontSize: 11,
                        ),
                    todayTextStyle: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                // Enhanced time slot view settings
                timeSlotViewSettings: TimeSlotViewSettings(
                  startHour: 6,
                  endHour: 22,
                  timeInterval: const Duration(minutes: 30),
                  timeIntervalHeight: 60,
                  timeFormat: 'h:mm a',
                  timeTextStyle: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                ),

                // Schedule view settings
                scheduleViewSettings: ScheduleViewSettings(
                  appointmentItemHeight: 60,
                  hideEmptyScheduleWeek: true,
                  appointmentTextStyle: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurface),
                  dayHeaderSettings: DayHeaderSettings(
                    dayFormat: 'EEEE',
                    width: 70,
                    dayTextStyle: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                    dateTextStyle: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  weekHeaderSettings: WeekHeaderSettings(
                    startDateFormat: 'dd MMM',
                    endDateFormat: 'dd MMM',
                    height: 50,
                    textAlign: TextAlign.center,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    weekTextStyle: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  CalendarDataSource _getCalendarDataSource() {
    return StyledCalendarDataSource(tasks: widget.tasks, events: widget.events);
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      final appointment = details.appointments?.first;
      if (appointment is ConstructionTask) {
        widget.onTaskTapped?.call(appointment);
      } else if (appointment is WorkEvent) {
        widget.onEventTapped?.call(appointment);
      }
    } else if (details.targetElement == CalendarElement.calendarCell) {
      widget.onTaskCreated?.call(details.date!);
    }
  }

  Widget _buildAppointment(
    BuildContext context,
    CalendarAppointmentDetails details,
  ) {
    final appointment = details.appointments.first;
    final colorScheme = Theme.of(context).colorScheme;

    if (appointment is ConstructionTask) {
      return _buildTaskAppointment(context, appointment, colorScheme);
    } else if (appointment is WorkEvent) {
      return _buildEventAppointment(context, appointment, colorScheme);
    }

    return Container();
  }

  Widget _buildTaskAppointment(
    BuildContext context,
    ConstructionTask task,
    ColorScheme colorScheme,
  ) {
    final statusColor = _getTaskStatusColor(task.status);
    final priorityColor = _getTaskPriorityColor(task.priority);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.9), statusColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: priorityColor, width: 2),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Task title with progress indicator
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(8),
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
            const SizedBox(height: 4),
            // Team and priority
            Row(
              children: [
                Icon(
                  Icons.group,
                  size: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 4),
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
    ColorScheme colorScheme,
  ) {
    final eventColor = _getWorkEventTypeColor(event.eventType);

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [eventColor.withOpacity(0.8), eventColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: eventColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                _getWorkEventTypeIcon(event.eventType),
                size: 10,
                color: eventColor,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                event.title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
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
        color = Colors.red.shade200;
        break;
      case TaskPriority.high:
        iconData = Icons.keyboard_arrow_up;
        color = Colors.orange.shade200;
        break;
      case TaskPriority.medium:
        iconData = Icons.remove;
        color = Colors.yellow.shade200;
        break;
      case TaskPriority.low:
        iconData = Icons.keyboard_arrow_down;
        color = Colors.green.shade200;
        break;
    }

    return Icon(iconData, size: 12, color: color);
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return Colors.grey.shade600;
      case TaskStatus.inProgress:
        return Colors.blue.shade600;
      case TaskStatus.completed:
        return Colors.green.shade600;
      case TaskStatus.onHold:
        return Colors.orange.shade600;
      case TaskStatus.cancelled:
        return Colors.red.shade600;
      case TaskStatus.delayed:
        return Colors.amber.shade600;
    }
  }

  Color _getTaskPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green.shade400;
      case TaskPriority.medium:
        return Colors.yellow.shade500;
      case TaskPriority.high:
        return Colors.orange.shade500;
      case TaskPriority.critical:
        return Colors.red.shade500;
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

/// Custom data source for the styled calendar widget
class StyledCalendarDataSource extends CalendarDataSource {
  StyledCalendarDataSource({
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
    return DateTime.now().add(const Duration(hours: 1));
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
      return _getTaskStatusColor(appointment.status);
    } else if (appointment is WorkEvent) {
      return _getWorkEventTypeColor(appointment.eventType);
    }
    return Colors.blue;
  }

  @override
  String? getNotes(int index) {
    final appointment = appointments![index];
    if (appointment is ConstructionTask) {
      return appointment.description;
    } else if (appointment is WorkEvent) {
      return appointment.description;
    }
    return null;
  }

  Color _getTaskStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.notStarted:
        return Colors.grey.shade600;
      case TaskStatus.inProgress:
        return Colors.blue.shade600;
      case TaskStatus.completed:
        return Colors.green.shade600;
      case TaskStatus.delayed:
        return Colors.red.shade700;
      case TaskStatus.onHold:
        return Colors.orange.shade600;
      case TaskStatus.cancelled:
        return Colors.red.shade600;
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
