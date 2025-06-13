import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Enhanced table calendar widget with improved UI and functionality
class EnhancedTableCalendar extends StatefulWidget {
  const EnhancedTableCalendar({
    super.key,
    this.selectedDay,
    this.onDaySelected,
    this.onPageChanged,
    this.eventLoader,
    this.calendarFormat = CalendarFormat.month,
    this.startingDayOfWeek = StartingDayOfWeek.sunday,
    this.availableCalendarFormats = const {
      CalendarFormat.month: 'Month',
      CalendarFormat.twoWeeks: '2 weeks',
      CalendarFormat.week: 'Week',
    },
    this.onFormatChanged,
    this.headerStyle,
    this.calendarStyle,
    this.daysOfWeekStyle,
  });

  final DateTime? selectedDay;
  final Function(DateTime, DateTime)? onDaySelected;
  final Function(DateTime)? onPageChanged;
  final List<dynamic> Function(DateTime)? eventLoader;
  final CalendarFormat calendarFormat;
  final StartingDayOfWeek startingDayOfWeek;
  final Map<CalendarFormat, String> availableCalendarFormats;
  final Function(CalendarFormat)? onFormatChanged;
  final HeaderStyle? headerStyle;
  final CalendarStyle? calendarStyle;
  final DaysOfWeekStyle? daysOfWeekStyle;

  @override
  State<EnhancedTableCalendar> createState() => _EnhancedTableCalendarState();
}

class _EnhancedTableCalendarState extends State<EnhancedTableCalendar> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = widget.selectedDay ?? DateTime.now();
    _calendarFormat = widget.calendarFormat;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom header with month/year and format toggle
            _buildCustomHeader(context),
            const SizedBox(height: 16),

            // Table Calendar
            TableCalendar<dynamic>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: widget.eventLoader ?? (day) => [],
              startingDayOfWeek: widget.startingDayOfWeek,

              // Selection
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

              // Callbacks
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                widget.onDaySelected?.call(selectedDay, focusedDay);
              },

              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                widget.onPageChanged?.call(focusedDay);
              },

              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
                widget.onFormatChanged?.call(format);
              },

              // Styling
              headerVisible: false, // We use custom header
              calendarStyle:
                  widget.calendarStyle ??
                  CalendarStyle(
                    outsideDaysVisible: true,
                    weekendTextStyle: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                    holidayTextStyle: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    todayDecoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: theme.colorScheme.onSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                    defaultDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    weekendDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    holidayDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    outsideDecoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    canMarkersOverflow: true,
                  ),

              daysOfWeekStyle:
                  widget.daysOfWeekStyle ??
                  DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    weekendStyle: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

              availableCalendarFormats: widget.availableCalendarFormats,
            ),

            // Selected day info
            if (widget.selectedDay != null || _selectedDay != DateTime.now())
              _buildSelectedDayInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Month navigation
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
            });
          },
        ),

        // Month and year display
        Expanded(
          child: Text(
            _getMonthYearString(_focusedDay),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Month navigation
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
            });
          },
        ),

        const SizedBox(width: 8),

        // Format toggle button
        PopupMenuButton<CalendarFormat>(
          icon: Icon(
            _getFormatIcon(_calendarFormat),
            color: theme.colorScheme.primary,
          ),
          onSelected: (format) {
            setState(() {
              _calendarFormat = format;
            });
            widget.onFormatChanged?.call(format);
          },
          itemBuilder: (context) => widget.availableCalendarFormats.entries
              .map(
                (entry) => PopupMenuItem(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(_getFormatIcon(entry.key), size: 20),
                      const SizedBox(width: 8),
                      Text(entry.value),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSelectedDayInfo(BuildContext context) {
    final theme = Theme.of(context);
    final events = widget.eventLoader?.call(_selectedDay) ?? [];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Selected: ${_formatSelectedDay(_selectedDay)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (events.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${events.length} event${events.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onTertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getMonthYearString(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }

  IconData _getFormatIcon(CalendarFormat format) {
    switch (format) {
      case CalendarFormat.month:
        return Icons.calendar_view_month;
      case CalendarFormat.twoWeeks:
        return Icons.calendar_view_week;
      case CalendarFormat.week:
        return Icons.view_week;
    }
  }

  String _formatSelectedDay(DateTime date) {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
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

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}
