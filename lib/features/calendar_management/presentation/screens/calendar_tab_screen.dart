import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'calendar_management_screen.dart';
import '../../../work_calendar/presentation/screens/calendar_screen.dart';
import '../../../daily_reports/presentation/screens/daily_reports_screen.dart';
import '../../application/calendar_management_bloc.dart';
import '../../application/calendar_management_event.dart';
import '../widgets/calendar_dashboard_widget.dart';

/// Enhanced calendar screen with comprehensive tab navigation
class CalendarTabScreen extends StatefulWidget {
  const CalendarTabScreen({super.key});

  @override
  State<CalendarTabScreen> createState() => _CalendarTabScreenState();
}

class _CalendarTabScreenState extends State<CalendarTabScreen>
    with TickerProviderStateMixin {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorColor: Theme.of(context).colorScheme.primary,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendar'),
            Tab(icon: Icon(Icons.construction), text: 'Work Calendar'),
            Tab(icon: Icon(Icons.assessment), text: 'Reports'),
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Calendar Management (Events, Meetings, etc.)
          BlocProvider(
            create: (context) =>
                GetIt.instance<CalendarManagementBloc>()
                  ..add(const CalendarEventsRequested()),
            child: const CalendarManagementScreen(),
          ),

          // Tab 2: Work Calendar (Construction schedules, project timelines)
          const CalendarScreen(),

          // Tab 3: Daily Reports Calendar View
          const DailyReportsScreen(),

          // Tab 4: Calendar Dashboard/Overview
          _buildCalendarDashboard(),
        ],
      ),
    );
  }

  Widget _buildCalendarDashboard() {
    return BlocProvider(
      create: (context) =>
          GetIt.instance<CalendarManagementBloc>()
            ..add(const CalendarEventsRequested()),
      child: const CalendarDashboardWidget(),
    );
  }
}
