import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../domain/entities/work_event.dart';
import '../../domain/entities/construction_task.dart';
import '../../application/work_calendar_bloc.dart';
import '../../application/work_calendar_event.dart';
import '../../application/work_calendar_state.dart';
import '../widgets/calendar_event_dialog.dart';
import '../widgets/calendar_search_bar.dart';
import '../widgets/event_list_widget.dart';
import '../widgets/construction_calendar_widget.dart';
import '../widgets/construction_task_dialog.dart';
import '../widgets/construction_progress_overview.dart';
import '../widgets/construction_timeline_view.dart';

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

  // Sample construction tasks for demonstration
  List<ConstructionTask> _constructionTasks = [];
  final String _currentProjectId = 'solar_project_2024_001';

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _tabController = TabController(
      length: 5,
      vsync: this,
    ); // Added construction tab

    // Load initial events and demo data
    _loadEventsForCurrentMonth();
    _loadSampleConstructionTasks();
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

  void _loadSampleConstructionTasks() {
    // Sample construction tasks for solar panel installation
    _constructionTasks = [
      ConstructionTask(
        id: 'task_001',
        title: 'Site Survey & Assessment',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 2)),
        projectId: _currentProjectId,
        description: 'Initial site survey and structural assessment',
        status: TaskStatus.completed,
        progress: 1.0,
        priority: TaskPriority.high,
        assignedTeam: 'Survey Team',
        estimatedHours: 16.0,
        actualHours: 14.5,
        materials: const ['Measuring tools', 'Safety equipment'],
      ),
      ConstructionTask(
        id: 'task_002',
        title: 'Roof Preparation',
        startDate: DateTime.now().add(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        projectId: _currentProjectId,
        description: 'Clean and prepare roof surface for panel installation',
        status: TaskStatus.inProgress,
        progress: 0.7,
        priority: TaskPriority.medium,
        assignedTeam: 'Installation Team A',
        estimatedHours: 24.0,
        actualHours: 18.0,
        materials: const [
          'Cleaning supplies',
          'Roof sealant',
          'Safety harnesses',
        ],
      ),
      ConstructionTask(
        id: 'task_003',
        title: 'Panel Mounting System',
        startDate: DateTime.now().add(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        projectId: _currentProjectId,
        description: 'Install mounting rails and hardware',
        status: TaskStatus.notStarted,
        progress: 0.0,
        priority: TaskPriority.high,
        assignedTeam: 'Installation Team B',
        estimatedHours: 32.0,
        materials: const ['Mounting rails', 'Bolts', 'Flashing', 'Drill bits'],
      ),
      ConstructionTask(
        id: 'task_004',
        title: 'Solar Panel Installation',
        startDate: DateTime.now().add(const Duration(days: 8)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        projectId: _currentProjectId,
        description: 'Mount solar panels to the racking system',
        status: TaskStatus.notStarted,
        progress: 0.0,
        priority: TaskPriority.critical,
        assignedTeam: 'Installation Team A & B',
        estimatedHours: 40.0,
        materials: const ['Solar panels', 'Clamps', 'MC4 connectors'],
      ),
      ConstructionTask(
        id: 'task_005',
        title: 'Electrical Wiring',
        startDate: DateTime.now().add(const Duration(days: 11)),
        endDate: DateTime.now().add(const Duration(days: 13)),
        projectId: _currentProjectId,
        description: 'Connect panels and run DC/AC wiring',
        status: TaskStatus.notStarted,
        progress: 0.0,
        priority: TaskPriority.critical,
        assignedTeam: 'Electrical Team',
        estimatedHours: 28.0,
        materials: const ['DC cables', 'AC cables', 'Conduit', 'Wire nuts'],
      ),
      ConstructionTask(
        id: 'task_006',
        title: 'Inverter Installation',
        startDate: DateTime.now().add(const Duration(days: 12)),
        endDate: DateTime.now().add(const Duration(days: 13)),
        projectId: _currentProjectId,
        description: 'Install and configure power inverters',
        status: TaskStatus.notStarted,
        progress: 0.0,
        priority: TaskPriority.high,
        assignedTeam: 'Electrical Team',
        estimatedHours: 12.0,
        materials: const [
          'String inverters',
          'Mounting brackets',
          'Disconnect switches',
        ],
      ),
      ConstructionTask(
        id: 'task_007',
        title: 'System Testing',
        startDate: DateTime.now().add(const Duration(days: 14)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        projectId: _currentProjectId,
        description: 'Test system performance and safety',
        status: TaskStatus.notStarted,
        progress: 0.0,
        priority: TaskPriority.high,
        assignedTeam: 'QA Team',
        estimatedHours: 16.0,
        materials: const ['Testing equipment', 'Multimeter', 'Safety gear'],
      ),
      ConstructionTask(
        id: 'task_008',
        title: 'Final Inspection',
        startDate: DateTime.now().add(const Duration(days: 16)),
        endDate: DateTime.now().add(const Duration(days: 16)),
        projectId: _currentProjectId,
        description: 'Local authority inspection and sign-off',
        status: TaskStatus.notStarted,
        progress: 0.0,
        priority: TaskPriority.critical,
        assignedTeam: 'Project Manager',
        estimatedHours: 4.0,
        materials: const ['Documentation', 'Inspection forms'],
      ),
    ];
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
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendar'),
            Tab(icon: Icon(Icons.construction), text: 'Construction'),
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
            _buildConstructionView(),
            _buildUpcomingEventsView(),
            _buildTodayEventsView(),
            _buildCategoriesView(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate available height with safe minimums
                    final availableHeight = constraints.maxHeight;
                    final minCalendarHeight = 300.0;
                    final maxCalendarHeight = availableHeight * 0.95;

                    // Ensure we have positive constraints
                    final calendarHeight = availableHeight > minCalendarHeight
                        ? (availableHeight < maxCalendarHeight
                              ? availableHeight
                              : maxCalendarHeight)
                        : minCalendarHeight;

                    return Container(
                      height: calendarHeight,
                      width: constraints.maxWidth,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: SfCalendar(
                        controller: _calendarController,
                        view: _currentView,
                        dataSource: WorkEventDataSource(events),
                        monthViewSettings: MonthViewSettings(
                          appointmentDisplayMode:
                              MonthAppointmentDisplayMode.appointment,
                          showAgenda: _currentView == CalendarView.month,
                          agendaItemHeight: 50,
                          agendaViewHeight: _currentView == CalendarView.month
                              ? (calendarHeight * 0.3).clamp(100, 200)
                              : 0,
                        ),
                        timeSlotViewSettings: const TimeSlotViewSettings(
                          startHour: 6,
                          endHour: 22,
                          timeInterval: Duration(minutes: 30),
                          timeIntervalHeight: 60,
                        ),
                        scheduleViewSettings: const ScheduleViewSettings(
                          appointmentItemHeight: 60,
                          hideEmptyScheduleWeek: true,
                        ),
                        onTap: _onCalendarTapped,
                        onViewChanged: _onViewChanged,
                        headerStyle: CalendarHeaderStyle(
                          textAlign: TextAlign.center,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          textStyle: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        todayHighlightColor: Theme.of(
                          context,
                        ).colorScheme.primary,
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
                      ),
                    );
                  },
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

  Widget _buildConstructionView() {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Progress Overview with safe height constraints
            Container(
              constraints: const BoxConstraints(minHeight: 120, maxHeight: 180),
              child: ConstructionProgressOverview(
                tasks: _constructionTasks,
                projectId: _currentProjectId,
                onTaskStatusTapped: (status) {
                  _showTasksByStatus(status);
                },
              ),
            ),
            // Sub-tabs for different construction views
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.calendar_view_month), text: 'Calendar'),
                  Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
                ],
              ),
            ),
            // Construction views with proper constraints
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  final minViewHeight = 250.0;

                  return Container(
                    height: availableHeight > minViewHeight
                        ? availableHeight
                        : minViewHeight,
                    child: TabBarView(
                      children: [
                        // Calendar View with safe constraints
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: ConstructionCalendarWidget(
                            tasks: _constructionTasks,
                            events: const [],
                            view: _currentView,
                            controller: _calendarController,
                            onTaskTapped: (task) {
                              _showTaskDetailsDialog(task);
                            },
                            onTaskCreated: (date) {
                              _showCreateTaskDialog(selectedDate: date);
                            },
                          ),
                        ),
                        // Timeline View with safe constraints
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          child: ConstructionTimelineView(
                            tasks: _constructionTasks,
                            projectId: _currentProjectId,
                            onTaskTapped: (task) {
                              _showTaskDetailsDialog(task);
                            },
                            onTaskCreated: (date) {
                              _showCreateTaskDialog(selectedDate: date);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetailsDialog(ConstructionTask task) {
    showDialog(
      context: context,
      builder: (context) => ConstructionTaskDialog(
        task: task,
        projectId: _currentProjectId,
        onTaskUpdated: (updatedTask) {
          setState(() {
            final index = _constructionTasks.indexWhere(
              (t) => t.id == updatedTask.id,
            );
            if (index != -1) {
              _constructionTasks[index] = updatedTask;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        onTaskDeleted: (taskId) {
          setState(() {
            _constructionTasks.removeWhere((task) => task.id == taskId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task deleted successfully!'),
              backgroundColor: Colors.orange,
            ),
          );
        },
      ),
    );
  }

  void _showCreateTaskDialog({DateTime? selectedDate}) {
    showDialog(
      context: context,
      builder: (context) => ConstructionTaskDialog(
        projectId: _currentProjectId,
        onTaskCreated: (newTask) {
          setState(() {
            _constructionTasks.add(newTask);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showTasksByStatus(TaskStatus status) {
    final filteredTasks = _constructionTasks
        .where((task) => task.status == status)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${status.displayName} Tasks'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: filteredTasks.isEmpty
              ? const Center(child: Text('No tasks found with this status.'))
              : ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Text(
                          '${task.progress * 100}% • ${task.assignedTeam ?? 'Unassigned'}',
                        ),
                        trailing: Text(
                          '${task.startDate.day}/${task.startDate.month}',
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          _showTaskDetailsDialog(task);
                        },
                      ),
                    );
                  },
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

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_tabController.index == 1) // Construction tab
          FloatingActionButton(
            heroTag: "construction_task",
            onPressed: () => _showCreateTaskDialog(),
            tooltip: 'Create Construction Task',
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: const Icon(Icons.construction),
          ),
        if (_tabController.index == 1) const SizedBox(height: 16),
        FloatingActionButton(
          heroTag: "work_event",
          onPressed: () => _showCreateEventDialog(),
          tooltip: _tabController.index == 1
              ? 'Create Work Event'
              : 'Create Event',
          child: const Icon(Icons.add),
        ),
      ],
    );
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
