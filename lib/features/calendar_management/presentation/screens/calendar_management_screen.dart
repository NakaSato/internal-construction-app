import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../application/calendar_management_bloc.dart';
import '../../application/calendar_management_event.dart';
import '../../application/calendar_management_state.dart';
import '../../domain/entities/calendar_event.dart';
import '../widgets/calendar_event_dialog.dart';
import '../widgets/calendar_event_list_widget.dart';
import '../widgets/calendar_filter_widget.dart';
import '../widgets/calendar_search_widget.dart';
import '../widgets/calendar_agenda_view.dart';
import '../widgets/find_time_widget.dart';
import '../../../../core/widgets/enhanced_table_calendar.dart';

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

class CalendarManagementView extends StatefulWidget {
  const CalendarManagementView({super.key});

  @override
  State<CalendarManagementView> createState() => _CalendarManagementViewState();
}

class _CalendarManagementViewState extends State<CalendarManagementView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedDay = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Management'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () => _showFindTimeDialog(context),
            tooltip: 'Find a Time',
          ),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Month'),
            Tab(icon: Icon(Icons.view_week), text: 'Week'),
            Tab(icon: Icon(Icons.view_day), text: 'Day'),
            Tab(icon: Icon(Icons.list), text: 'Agenda'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Month View
          _buildMonthView(),
          // Week View
          _buildWeekView(),
          // Day View
          _buildDayView(),
          // Agenda View
          BlocBuilder<CalendarManagementBloc, CalendarManagementState>(
            builder: (context, state) {
              List<CalendarEvent> events = [];
              if (state is CalendarEventsLoaded) {
                events = state.events;
              } else if (state is CalendarSearchResultsLoaded) {
                events = state.results;
              }
              return CalendarAgendaView(
                events: events,
                onEventTap: (event) => _showEventDetails(context, event),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "calendar_management_fab",
        onPressed: () => _showCreateEventDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Event'),
      ),
    );
  }

  Widget _buildMonthView() {
    return BlocBuilder<CalendarManagementBloc, CalendarManagementState>(
      builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            children: [
              EnhancedTableCalendar(
                selectedDay: _selectedDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  // Load events for selected day
                  context.read<CalendarManagementBloc>().add(
                    CalendarEventsRequested(
                      startDate: selectedDay,
                      endDate: selectedDay.add(const Duration(days: 1)),
                    ),
                  );
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  // Load events for the month
                  final monthStart = DateTime(
                    focusedDay.year,
                    focusedDay.month,
                    1,
                  );
                  final monthEnd = DateTime(
                    focusedDay.year,
                    focusedDay.month + 1,
                    0,
                  );
                  context.read<CalendarManagementBloc>().add(
                    CalendarEventsRequested(
                      startDate: monthStart,
                      endDate: monthEnd,
                    ),
                  );
                },
              ),
              SizedBox(
                height: 300, // Fixed height for events list
                child: _EventsList(
                  onEventTap: (event) => _showEventDetails(context, event),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeekView() {
    return BlocBuilder<CalendarManagementBloc, CalendarManagementState>(
      builder: (context, state) {
        return Column(
          children: [
            // Week header with navigation
            _buildWeekHeader(),

            // Week calendar display
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildWeekDaySelector(),
            ),

            // Events for selected date within this week
            Expanded(
              child: _EventsList(
                onEventTap: (event) => _showEventDetails(context, event),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeekHeader() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
              onPressed: () {
                final newSelectedDay =
                    _selectedDay?.subtract(const Duration(days: 7)) ??
                    DateTime.now().subtract(const Duration(days: 7));
                setState(() {
                  _selectedDay = newSelectedDay;
                  _focusedDay = newSelectedDay;
                });

                // Load events for the new week
                final weekStart = DateTime(
                  newSelectedDay.year,
                  newSelectedDay.month,
                  newSelectedDay.day,
                ).subtract(Duration(days: newSelectedDay.weekday - 1));
                final weekEnd = weekStart.add(const Duration(days: 6));

                context.read<CalendarManagementBloc>().add(
                  CalendarEventsRequested(
                    startDate: weekStart,
                    endDate: weekEnd,
                  ),
                );
              },
              tooltip: 'Previous week',
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Text(
                _getWeekRange(_focusedDay),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
              onPressed: () {
                final newSelectedDay =
                    _selectedDay?.add(const Duration(days: 7)) ??
                    DateTime.now().add(const Duration(days: 7));
                setState(() {
                  _selectedDay = newSelectedDay;
                  _focusedDay = newSelectedDay;
                });

                // Load events for the new week
                final weekStart = DateTime(
                  newSelectedDay.year,
                  newSelectedDay.month,
                  newSelectedDay.day,
                ).subtract(Duration(days: newSelectedDay.weekday - 1));
                final weekEnd = weekStart.add(const Duration(days: 6));

                context.read<CalendarManagementBloc>().add(
                  CalendarEventsRequested(
                    startDate: weekStart,
                    endDate: weekEnd,
                  ),
                );
              },
              tooltip: 'Next week',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDaySelector() {
    final weekStart =
        _selectedDay?.subtract(Duration(days: _selectedDay!.weekday - 1)) ??
        DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 7,
      itemBuilder: (context, index) {
        final day = weekStart.add(Duration(days: index));
        final isSelected =
            _selectedDay != null &&
            day.year == _selectedDay!.year &&
            day.month == _selectedDay!.month &&
            day.day == _selectedDay!.day;

        final today = DateTime.now();
        final isToday =
            day.year == today.year &&
            day.month == today.month &&
            day.day == today.day;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = day;
              _focusedDay = day;
            });

            // Load events for selected day
            context.read<CalendarManagementBloc>().add(
              CalendarEventsRequested(
                startDate: day,
                endDate: day.add(const Duration(days: 1)),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : isToday
                  ? Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.4)
                  : Theme.of(context).colorScheme.surface,
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.85),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isToday && !isSelected
                    ? Theme.of(context).colorScheme.primary
                    : isSelected
                    ? Colors.transparent
                    : Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withOpacity(0.5),
                width: isToday && !isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: 12,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : isToday
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  day.day.toString(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : isToday
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayView() {
    final dateToShow = _selectedDay ?? DateTime.now();
    final hours = List.generate(24, (i) => i);

    return BlocBuilder<CalendarManagementBloc, CalendarManagementState>(
      builder: (context, state) {
        // Extract events for the selected day
        List<dynamic> dayEvents = [];
        if (state is CalendarEventsLoaded) {
          dayEvents = state.events.where((event) {
            final eventStartDate = DateTime(
              event.startDateTime.year,
              event.startDateTime.month,
              event.startDateTime.day,
            );
            final selectedDate = DateTime(
              dateToShow.year,
              dateToShow.month,
              dateToShow.day,
            );
            return eventStartDate.isAtSameMomentAs(selectedDate);
          }).toList();
        }

        return Column(
          children: [
            // Day header with date info and navigation
            _buildDayHeader(dateToShow),

            // Day view with hourly timeline
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: hours.length,
                itemBuilder: (context, index) {
                  final hour = hours[index];
                  final hourString = hour < 10 ? '0$hour:00' : '$hour:00';

                  // Filter events for this hour
                  final hourEvents = dayEvents.where((event) {
                    return event.startDateTime.hour == hour;
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hour label
                      Row(
                        children: [
                          Container(
                            width: 64,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              hourString,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 1.5,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.4),
                                    Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Events for this hour
                      if (hourEvents.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 60),
                          child: Column(
                            children: hourEvents.map<Widget>((event) {
                              return _buildTimelineEvent(event);
                            }).toList(),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 24),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDayHeader(DateTime date) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
              onPressed: () {
                final newDay = date.subtract(const Duration(days: 1));
                setState(() {
                  _selectedDay = newDay;
                  _focusedDay = newDay;
                });

                // Load events for the new day
                context.read<CalendarManagementBloc>().add(
                  CalendarEventsRequested(
                    startDate: newDay,
                    endDate: newDay.add(const Duration(days: 1)),
                  ),
                );
              },
              tooltip: 'Previous day',
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${_getDayOfWeek(date)}, ${_formatDate(date)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_isToday(date))
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      'Today',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
              onPressed: () {
                final newDay = date.add(const Duration(days: 1));
                setState(() {
                  _selectedDay = newDay;
                  _focusedDay = newDay;
                });

                // Load events for the new day
                context.read<CalendarManagementBloc>().add(
                  CalendarEventsRequested(
                    startDate: newDay,
                    endDate: newDay.add(const Duration(days: 1)),
                  ),
                );
              },
              tooltip: 'Next day',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineEvent(dynamic event) {
    final startTime = event.startDateTime;
    final endTime = event.endDateTime;
    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: _getEventColor(event),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatTimeOnly(startTime)} - ${_formatTimeOnly(endTime)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                Text(
                  '${hours}h ${minutes}m',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  if (event.location != null && event.location.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayOfWeek(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatTimeOnly(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Color _getEventColor(dynamic event) {
    // Use event color if available, otherwise determine by event type
    if (event.color != null) {
      // Parse color from string or use a map
      switch (event.color) {
        case 'red':
          return Colors.red;
        case 'blue':
          return Colors.blue;
        case 'green':
          return Colors.green;
        case 'orange':
          return Colors.orange;
        case 'purple':
          return Colors.purple;
        default:
          return Theme.of(context).colorScheme.primary;
      }
    }

    // Determine by event type
    switch (event.eventType.toString().toLowerCase()) {
      case 'meeting':
        return Colors.blue;
      case 'task':
        return Colors.orange;
      case 'reminder':
        return Colors.purple;
      case 'deadline':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _getWeekRange(DateTime date) {
    final weekStart = date.subtract(Duration(days: date.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}';
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showFindTimeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CalendarManagementBloc>(),
        child: FindTimeWidget(
          attendeeIds: const ['user1', 'user2'], // Sample attendee IDs
          duration: const Duration(hours: 1), // Default meeting duration
          preferredDate: _selectedDay,
          onTimeSlotSelected: (startTime, endTime) {
            Navigator.of(dialogContext).pop();
            // Create event with selected time slot
            _showCreateEventDialog(
              context,
              startTime: startTime,
              endTime: endTime,
            );
          },
        ),
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

  void _showCreateEventDialog(
    BuildContext context, {
    DateTime? startTime,
    DateTime? endTime,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CalendarManagementBloc>(),
        child: CalendarEventDialog(
          selectedDate: startTime ?? _selectedDay ?? DateTime.now(),
        ),
      ),
    );
  }

  void _showEventDetails(BuildContext context, CalendarEvent event) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CalendarManagementBloc>(),
        child: CalendarEventDialog(event: event),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({required this.onEventTap});

  final void Function(CalendarEvent) onEventTap;

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
            onEventTap: onEventTap,
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
                  onEventTap: onEventTap,
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
}
