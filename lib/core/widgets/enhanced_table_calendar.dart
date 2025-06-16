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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
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
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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

              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: theme.colorScheme.primary,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.primary,
                ),
              ),

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
                    isTodayHighlighted: true,
                    weekendTextStyle: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                    holidayTextStyle: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                    selectedDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.85),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 0.5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    selectedTextStyle: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    todayDecoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    todayTextStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    defaultDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    weekendDecoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    holidayDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    outsideDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    markerDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.tertiary,
                          theme.colorScheme.tertiaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    markerSize: 6,
                    markerMargin: const EdgeInsets.symmetric(horizontal: 0.5),
                    markersMaxCount: 3,
                    canMarkersOverflow: true,
                    cellMargin: const EdgeInsets.all(4),
                  ),

              daysOfWeekStyle:
                  widget.daysOfWeekStyle ??
                  DaysOfWeekStyle(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    weekdayStyle: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                    weekendStyle: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 0.5,
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Month navigation
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: theme.colorScheme.primary,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                });
              },
              tooltip: 'Previous month',
            ),
          ),

          // Month and year display
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _getMonthYearString(_focusedDay),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Month navigation
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.primary,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                });
              },
              tooltip: 'Next month',
            ),
          ),

        const SizedBox(width: 8),

        // Format toggle button
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: PopupMenuButton<CalendarFormat>(
            padding: EdgeInsets.zero,
            tooltip: 'Calendar view',
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
                      Icon(
                        _getFormatIcon(entry.key),
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDayInfo(BuildContext context) {
    final theme = Theme.of(context);
    final events = widget.eventLoader?.call(_selectedDay) ?? [];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.3),
            theme.colorScheme.primaryContainer.withOpacity(0.15),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.tertiary,
                    theme.colorScheme.tertiary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.tertiary.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_note,
                    color: theme.colorScheme.onTertiary,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${events.length} event${events.length == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onTertiary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
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
