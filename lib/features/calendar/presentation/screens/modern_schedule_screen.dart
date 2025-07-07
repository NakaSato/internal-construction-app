import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/calendar_management_bloc.dart';
import '../../application/calendar_management_event.dart';
import '../../application/calendar_management_state.dart';
import '../../domain/entities/calendar_event.dart';
import '../../../../core/theme/app_theme.dart';

/// Modern schedule screen with beautiful Material Design 3 UI
///
/// Inspired by the provided calendar interface but adapted for solar project management.
/// Features a clean week view with agenda-style event listing and modern visual design.
class ModernScheduleScreen extends StatefulWidget {
  const ModernScheduleScreen({super.key});

  @override
  State<ModernScheduleScreen> createState() => _ModernScheduleScreenState();
}

class _ModernScheduleScreenState extends State<ModernScheduleScreen> {
  int _selectedBottomNavIndex = 1; // Calendar tab selected initially
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _focusedWeekStart = _getWeekStart(_selectedDate);
    _loadWeekEvents();
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _loadWeekEvents() {
    final weekEnd = _focusedWeekStart.add(const Duration(days: 6));
    context.read<CalendarManagementBloc>().add(CalendarEventsRequested(startDate: _focusedWeekStart, endDate: weekEnd));
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedBottomNavIndex = index;
    });
  }

  void _navigateWeek(bool isNext) {
    setState(() {
      _focusedWeekStart = _focusedWeekStart.add(Duration(days: isNext ? 7 : -7));
      // Update selected date to be within the new week
      if (!_isDateInWeek(_selectedDate, _focusedWeekStart)) {
        _selectedDate = _focusedWeekStart;
      }
    });
    _loadWeekEvents();
  }

  bool _isDateInWeek(DateTime date, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        date.isBefore(weekEnd.add(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendarView(),
            const SizedBox(height: SolarSpacing.lg),
            _buildScheduleContent(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.colorScheme.surface,
      elevation: 0,
      leadingWidth: 180,
      leading: Padding(
        padding: const EdgeInsets.only(left: SolarSpacing.md),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _getMonthName(DateTime.now()),
            style: context.textTheme.displayHeading.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: context.colorScheme.onSurface, size: 28),
          onPressed: () {
            // TODO: Show search dialog
          },
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined, color: context.colorScheme.onSurface, size: 28),
          onPressed: () {
            // TODO: Show settings
          },
        ),
      ],
    );
  }

  Widget _buildCalendarView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SolarSpacing.md, vertical: SolarSpacing.sm),
      child: Column(
        children: [
          // Week navigation
          _buildWeekNavigation(),
          const SizedBox(height: SolarSpacing.md),
          // Calendar days
          _buildWeekDaysRow(),
        ],
      ),
    );
  }

  Widget _buildWeekNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _navigateWeek(false),
          icon: Icon(Icons.chevron_left, color: context.colorScheme.primary),
        ),
        Text(
          _getWeekRangeText(_focusedWeekStart),
          style: context.textTheme.cardTitle.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: () => _navigateWeek(true),
          icon: Icon(Icons.chevron_right, color: context.colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildWeekDaysRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final day = _focusedWeekStart.add(Duration(days: index));
        return _buildCalendarDay(day);
      }),
    );
  }

  Widget _buildCalendarDay(DateTime day) {
    final isSelected = _isSameDay(day, _selectedDate);
    final isToday = _isSameDay(day, DateTime.now());

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = day;
        });
      },
      child: Column(
        children: [
          Text(
            _getDayLetter(day),
            style: TextStyle(
              color: isSelected ? context.colorScheme.onSurface : context.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: SolarSpacing.sm),
          Container(
            padding: const EdgeInsets.all(SolarSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected ? context.colorScheme.solarBlue : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isSelected ? Border.all(color: context.colorScheme.solarBlue, width: 2) : null,
            ),
            child: Text(
              day.day.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : context.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: SolarSpacing.xs),
          // Event indicators (dots)
          _buildEventIndicators(day),
        ],
      ),
    );
  }

  Widget _buildEventIndicators(DateTime day) {
    return BlocBuilder<CalendarManagementBloc, CalendarManagementState>(
      builder: (context, state) {
        if (state is CalendarEventsLoaded) {
          final dayEvents = state.events.where((event) {
            return _isSameDay(event.startDateTime, day);
          }).toList();

          if (dayEvents.isEmpty) {
            return const SizedBox(height: 10);
          }

          // Show up to 3 colored dots for different event types
          final eventTypes = dayEvents.map((e) => e.eventType).toSet().take(3).toList();

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: eventTypes.map((type) {
              return Container(
                width: 3,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(shape: BoxShape.circle, color: _getEventTypeColor(type)),
              );
            }).toList(),
          );
        }
        return const SizedBox(height: 10);
      },
    );
  }

  Widget _buildScheduleContent() {
    return BlocBuilder<CalendarManagementBloc, CalendarManagementState>(
      builder: (context, state) {
        if (state is CalendarManagementLoading) {
          return const Center(
            child: Padding(padding: EdgeInsets.all(SolarSpacing.xl), child: CircularProgressIndicator()),
          );
        }

        if (state is CalendarEventsLoaded) {
          return _buildEventsList(state.events);
        }

        return const Center(child: Text('No events found'));
      },
    );
  }

  Widget _buildEventsList(List<CalendarEvent> allEvents) {
    // Group events by date
    final groupedEvents = <DateTime, List<CalendarEvent>>{};

    for (final event in allEvents) {
      final eventDate = DateTime(event.startDateTime.year, event.startDateTime.month, event.startDateTime.day);

      if (groupedEvents[eventDate] == null) {
        groupedEvents[eventDate] = [];
      }
      groupedEvents[eventDate]!.add(event);
    }

    // Sort events within each day by start time
    groupedEvents.forEach((date, events) {
      events.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    });

    // Get today and tomorrow for section headers
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final tomorrowDate = todayDate.add(const Duration(days: 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's events
        if (groupedEvents[todayDate]?.isNotEmpty == true) ...[
          _buildSectionHeader("Today · ${_getDayName(todayDate)}, ${_formatDateHeader(todayDate)}"),
          ...groupedEvents[todayDate]!.map((event) => _buildScheduleItem(event)),
        ],

        // Due today items (sample - could be from tasks)
        _buildDueTodayItem(),

        // Tomorrow's events
        if (groupedEvents[tomorrowDate]?.isNotEmpty == true) ...[
          const Divider(height: 30, indent: 20, endIndent: 20),
          _buildSectionHeader("Tomorrow · ${_getDayName(tomorrowDate)}, ${_formatDateHeader(tomorrowDate)}"),
          ...groupedEvents[tomorrowDate]!.map((event) => _buildScheduleItem(event)),
        ],

        // Other days in the week
        ...groupedEvents.entries
            .where((entry) => !_isSameDay(entry.key, todayDate) && !_isSameDay(entry.key, tomorrowDate))
            .map(
              (entry) => [
                const Divider(height: 30, indent: 20, endIndent: 20),
                _buildSectionHeader("${_getDayName(entry.key)}, ${_formatDateHeader(entry.key)}"),
                ...entry.value.map((event) => _buildScheduleItem(event)),
              ],
            )
            .expand((widgets) => widgets),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SolarSpacing.md, vertical: SolarSpacing.sm),
      child: Text(
        title,
        style: context.textTheme.cardTitle.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildDueTodayItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SolarSpacing.md, vertical: SolarSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                "DUE",
                style: TextStyle(color: context.colorScheme.energyLow, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                "TODAY",
                style: TextStyle(color: context.colorScheme.energyLow, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Icon(Icons.schedule_outlined, color: context.colorScheme.onSurfaceVariant, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Solar Panel Inspection Report",
                  style: context.textTheme.body.copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  "Residential Solar Project #2024-003",
                  style: context.textTheme.body.copyWith(color: context.colorScheme.onSurfaceVariant, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(CalendarEvent event) {
    final eventColor = _getEventTypeColor(event.eventType);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Color indicator
            Container(width: 6, color: eventColor),
            const SizedBox(width: 10),

            // Time column
            SizedBox(
              width: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(event.startDateTime),
                      style: context.textTheme.body.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(event.endDateTime),
                      style: context.textTheme.body.copyWith(color: context.colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            // Event content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: SolarSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_getEventTypeIcon(event.eventType), color: context.colorScheme.onSurfaceVariant, size: 20),
                        const SizedBox(width: SolarSpacing.sm),
                        Text(
                          event.title,
                          style: context.textTheme.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),

                    if (event.projectName != null) ...[
                      const SizedBox(height: SolarSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.only(left: 28.0),
                        child: Text(event.projectName!, style: context.textTheme.body.copyWith(fontSize: 14)),
                      ),
                    ],

                    if (event.location != null && event.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 28.0),
                        child: Text(event.location!, style: context.textTheme.body.copyWith(fontSize: 14)),
                      ),
                    ],

                    // Status indicator for completed events
                    if (event.status == CalendarEventStatus.completed) ...[
                      const SizedBox(height: SolarSpacing.md),
                      Padding(
                        padding: const EdgeInsets.only(left: 28.0),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: context.colorScheme.energyHigh, size: 20),
                            const SizedBox(width: SolarSpacing.sm),
                            Text(
                              "Result: Completed",
                              style: context.textTheme.body.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: SolarSpacing.sm),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.solar_power_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
      ],
      currentIndex: _selectedBottomNavIndex,
      selectedItemColor: context.colorScheme.solarBlue,
      unselectedItemColor: context.colorScheme.onSurfaceVariant,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      backgroundColor: context.colorScheme.surface,
      elevation: 4.0,
      onTap: _onBottomNavTapped,
    );
  }

  // Helper methods
  String _getMonthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[date.month - 1];
  }

  String _getWeekRangeText(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    if (weekStart.month == weekEnd.month) {
      return "${_getMonthName(weekStart)} ${weekStart.day}-${weekEnd.day}, ${weekStart.year}";
    } else {
      return "${_getMonthName(weekStart)} ${weekStart.day} - ${_getMonthName(weekEnd)} ${weekEnd.day}, ${weekStart.year}";
    }
  }

  String _getDayLetter(DateTime date) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[date.weekday - 1];
  }

  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  String _formatDateHeader(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return "${months[date.month - 1]} ${date.day}";
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _getEventTypeColor(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.meeting:
        return const Color(0xFF2563EB); // solarBlue
      case CalendarEventType.maintenance:
        return const Color(0xFF059669); // solarGreen
      case CalendarEventType.installation:
        return const Color(0xFFEA580C); // solarOrange
      case CalendarEventType.training:
        return const Color(0xFFF59E0B); // solarGold
      case CalendarEventType.deadline:
        return const Color(0xFFDC2626); // energyLow
      default:
        return const Color(0xFF6B7280); // statusDraft
    }
  }

  IconData _getEventTypeIcon(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.meeting:
        return Icons.people_outline;
      case CalendarEventType.maintenance:
        return Icons.search_outlined;
      case CalendarEventType.installation:
        return Icons.construction_outlined;
      case CalendarEventType.training:
        return Icons.build_outlined;
      case CalendarEventType.deadline:
        return Icons.schedule_outlined;
      default:
        return Icons.event_outlined;
    }
  }
}
