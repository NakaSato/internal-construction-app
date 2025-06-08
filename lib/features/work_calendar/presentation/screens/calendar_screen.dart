import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../domain/entities/work_event.dart';
import '../../application/work_calendar_bloc.dart';
import '../../application/work_calendar_event.dart';
import '../../application/work_calendar_state.dart';
import '../widgets/calendar_event_dialog.dart';
import '../widgets/calendar_search_bar.dart';
import '../widgets/event_list_widget.dart';

/// Main calendar screen with comprehensive event management
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late CalendarController _calendarController;
  late TabController _tabController;
  CalendarView _currentView = CalendarView.month;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _tabController = TabController(length: 4, vsync: this);

    // Load initial events
    _loadEventsForCurrentMonth();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadEventsForCurrentMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    context.read<WorkCalendarBloc>().add(
      CalendarEventsRequested(startDate: startOfMonth, endDate: endOfMonth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Calendar'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => _goToToday(),
            tooltip: 'Today',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
            tooltip: 'Search Events',
          ),
          PopupMenuButton<CalendarView>(
            icon: const Icon(Icons.view_module),
            onSelected: (view) => _changeView(view),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CalendarView.day,
                child: Text('Day View'),
              ),
              const PopupMenuItem(
                value: CalendarView.week,
                child: Text('Week View'),
              ),
              const PopupMenuItem(
                value: CalendarView.month,
                child: Text('Month View'),
              ),
              const PopupMenuItem(
                value: CalendarView.schedule,
                child: Text('Schedule View'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendar'),
            Tab(icon: Icon(Icons.upcoming), text: 'Upcoming'),
            Tab(icon: Icon(Icons.today), text: 'Today'),
            Tab(icon: Icon(Icons.category), text: 'Categories'),
          ],
        ),
      ),
      body: BlocListener<WorkCalendarBloc, WorkCalendarState>(
        listener: (context, state) {
          if (state is WorkCalendarError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is WorkEventCreatedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is WorkEventDeletedSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event deleted successfully!'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCalendarView(),
            _buildUpcomingEventsView(),
            _buildTodayEventsView(),
            _buildCategoriesView(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateEventDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Create Event',
      ),
    );
  }

  Widget _buildCalendarView() {
    return BlocBuilder<WorkCalendarBloc, WorkCalendarState>(
      builder: (context, state) {
        List<WorkEvent> events = [];

        if (state is CalendarEventsLoaded) {
          events = state.events;
        }

        return Column(
          children: [
            if (state is WorkCalendarLoading) const LinearProgressIndicator(),
            Expanded(
              child: SfCalendar(
                controller: _calendarController,
                view: _currentView,
                dataSource: WorkEventDataSource(events),
                monthViewSettings: const MonthViewSettings(
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment,
                  showAgenda: true,
                ),
                timeSlotViewSettings: const TimeSlotViewSettings(
                  startHour: 6,
                  endHour: 22,
                  timeInterval: Duration(minutes: 30),
                ),
                onTap: _onCalendarTapped,
                onViewChanged: _onViewChanged,
                headerStyle: const CalendarHeaderStyle(
                  textAlign: TextAlign.center,
                  backgroundColor: Colors.transparent,
                ),
                todayHighlightColor: Theme.of(context).primaryColor,
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingEventsView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.upcoming, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Upcoming Events',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.read<WorkCalendarBloc>().add(
                    const UpcomingEventsRequested(),
                  );
                },
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<WorkCalendarBloc, WorkCalendarState>(
            builder: (context, state) {
              if (state is WorkCalendarLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is UpcomingEventsLoaded) {
                return EventListWidget(events: state.events);
              } else {
                // Load upcoming events if not already loaded
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<WorkCalendarBloc>().add(
                    const UpcomingEventsRequested(),
                  );
                });
                return const Center(child: Text('Loading upcoming events...'));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodayEventsView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.today, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Today\'s Events - ${_formatDate(DateTime.now())}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.read<WorkCalendarBloc>().add(
                    const TodaysEventsRequested(),
                  );
                },
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<WorkCalendarBloc, WorkCalendarState>(
            builder: (context, state) {
              if (state is WorkCalendarLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TodaysEventsLoaded) {
                return EventListWidget(events: state.events);
              } else {
                // Load today's events if not already loaded
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<WorkCalendarBloc>().add(
                    const TodaysEventsRequested(),
                  );
                });
                return const Center(child: Text('Loading today\'s events...'));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesView() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.category, color: Colors.purple),
              SizedBox(width: 8),
              Text(
                'Event Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: WorkEventType.values.map((type) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getEventTypeColor(type),
                    child: Icon(
                      _getEventTypeIcon(type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(_getEventTypeDisplayName(type)),
                  subtitle: Text(_getEventTypeDescription(type)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _filterByEventType(type),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _onCalendarTapped(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      final WorkEvent event = details.appointments!.first;
      _showEventDetailsDialog(event);
    } else if (details.targetElement == CalendarElement.calendarCell) {
      _selectedDate = details.date!;
      _showCreateEventDialog(selectedDate: _selectedDate);
    }
  }

  void _onViewChanged(ViewChangedDetails details) {
    // Load events for the visible date range
    final startDate = details.visibleDates.first;
    final endDate = details.visibleDates.last;

    context.read<WorkCalendarBloc>().add(
      CalendarEventsRequested(startDate: startDate, endDate: endDate),
    );
  }

  void _changeView(CalendarView view) {
    setState(() {
      _currentView = view;
    });
  }

  void _goToToday() {
    _calendarController.displayDate = DateTime.now();
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => const CalendarSearchDialog(),
    );
  }

  void _showCreateEventDialog({DateTime? selectedDate}) {
    showDialog(
      context: context,
      builder: (context) =>
          CalendarEventDialog(selectedDate: selectedDate ?? DateTime.now()),
    );
  }

  void _showEventDetailsDialog(WorkEvent event) {
    showDialog(
      context: context,
      builder: (context) => CalendarEventDialog(
        event: event,
        selectedDate: event.startTime,
        isEditing: true,
      ),
    );
  }

  void _filterByEventType(WorkEventType type) {
    context.read<WorkCalendarBloc>().add(EventsFilteredByType(type));
    // Switch to calendar tab to show filtered results
    _tabController.animateTo(0);
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

  Color _getEventTypeColor(WorkEventType type) {
    switch (type) {
      case WorkEventType.meeting:
        return Colors.blue;
      case WorkEventType.appointment:
        return Colors.orange;
      case WorkEventType.task:
        return Colors.green;
      case WorkEventType.reminder:
        return Colors.purple;
      case WorkEventType.break_:
        return Colors.cyan;
      case WorkEventType.travel:
        return Colors.brown;
      case WorkEventType.training:
        return Colors.teal;
      case WorkEventType.conference:
        return Colors.pink;
      case WorkEventType.other:
        return Colors.grey;
    }
  }

  IconData _getEventTypeIcon(WorkEventType type) {
    switch (type) {
      case WorkEventType.meeting:
        return Icons.group;
      case WorkEventType.appointment:
        return Icons.calendar_today;
      case WorkEventType.task:
        return Icons.task;
      case WorkEventType.reminder:
        return Icons.notifications;
      case WorkEventType.break_:
        return Icons.coffee;
      case WorkEventType.travel:
        return Icons.directions_car;
      case WorkEventType.training:
        return Icons.school;
      case WorkEventType.conference:
        return Icons.video_call;
      case WorkEventType.other:
        return Icons.event;
    }
  }

  String _getEventTypeDisplayName(WorkEventType type) {
    switch (type) {
      case WorkEventType.meeting:
        return 'Meetings';
      case WorkEventType.appointment:
        return 'Appointments';
      case WorkEventType.task:
        return 'Tasks';
      case WorkEventType.reminder:
        return 'Reminders';
      case WorkEventType.break_:
        return 'Break Time';
      case WorkEventType.travel:
        return 'Travel';
      case WorkEventType.training:
        return 'Training';
      case WorkEventType.conference:
        return 'Conference';
      case WorkEventType.other:
        return 'Other';
    }
  }

  String _getEventTypeDescription(WorkEventType type) {
    switch (type) {
      case WorkEventType.meeting:
        return 'Team meetings, client calls, video conferences';
      case WorkEventType.appointment:
        return 'Medical appointments, client meetings';
      case WorkEventType.task:
        return 'Work tasks, project deadlines';
      case WorkEventType.reminder:
        return 'Important reminders, notifications';
      case WorkEventType.break_:
        return 'Lunch breaks, coffee breaks';
      case WorkEventType.travel:
        return 'Business trips, commute planning';
      case WorkEventType.training:
        return 'Training sessions, workshops';
      case WorkEventType.conference:
        return 'Conferences, seminars, presentations';
      case WorkEventType.other:
        return 'Other miscellaneous events';
    }
  }
}

/// Data source for Syncfusion Calendar
class WorkEventDataSource extends CalendarDataSource {
  WorkEventDataSource(List<WorkEvent> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  Color getColor(int index) {
    final event = appointments![index] as WorkEvent;
    if (event.color != null) {
      // Parse hex color string
      final hexColor = event.color!.replaceAll('#', '');
      return Color(int.parse('FF$hexColor', radix: 16));
    }
    return _getDefaultEventColor(event.eventType);
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String? getNotes(int index) {
    return appointments![index].description;
  }

  @override
  String? getLocation(int index) {
    return appointments![index].location;
  }

  Color _getDefaultEventColor(WorkEventType type) {
    switch (type) {
      case WorkEventType.meeting:
        return Colors.blue;
      case WorkEventType.appointment:
        return Colors.orange;
      case WorkEventType.task:
        return Colors.green;
      case WorkEventType.reminder:
        return Colors.purple;
      case WorkEventType.break_:
        return Colors.cyan;
      case WorkEventType.travel:
        return Colors.brown;
      case WorkEventType.training:
        return Colors.teal;
      case WorkEventType.conference:
        return Colors.pink;
      case WorkEventType.other:
        return Colors.grey;
    }
  }
}
