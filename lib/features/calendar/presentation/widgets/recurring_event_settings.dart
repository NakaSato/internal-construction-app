import 'package:flutter/material.dart';

import '../../domain/entities/calendar_event.dart';

/// Widget for configuring recurring event pattern
class RecurringEventSettings extends StatefulWidget {
  const RecurringEventSettings({
    super.key,
    this.initialPattern,
    this.initialEndDate,
    this.onPatternChanged,
    this.onEndDateChanged,
    this.frequency,
    this.interval,
    this.selectedDays,
    this.onFrequencyChanged,
    this.onIntervalChanged,
    this.onDaysChanged,
  });

  final String? initialPattern;
  final DateTime? initialEndDate;
  final Function(String pattern)? onPatternChanged;
  final Function(DateTime? endDate)? onEndDateChanged;

  // New properties for advanced recurrence
  final dynamic frequency;
  final int? interval;
  final List<int>? selectedDays;
  final Function(dynamic value)? onFrequencyChanged;
  final Function(int value)? onIntervalChanged;
  final Function(List<int> value)? onDaysChanged;

  @override
  State<RecurringEventSettings> createState() => _RecurringEventSettingsState();
}

class _RecurringEventSettingsState extends State<RecurringEventSettings> {
  late String _selectedPattern;
  DateTime? _endDate;

  // Options for recurring patterns
  final List<String> _patternOptions = [
    'daily',
    'weekdays',
    'weekly',
    'biweekly',
    'monthly',
    'yearly',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPattern = widget.initialPattern ?? 'weekly';
    _endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recurring Pattern',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Pattern dropdown
            DropdownButtonFormField<String>(
              value: _selectedPattern,
              decoration: const InputDecoration(
                labelText: 'Repeats',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              items: _patternOptions.map((pattern) {
                return DropdownMenuItem<String>(
                  value: pattern,
                  child: Text(_formatPattern(pattern)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPattern = value;
                  });
                  widget.onPatternChanged?.call(value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Frequency settings (if provided)
            if (widget.frequency != null &&
                widget.onFrequencyChanged != null) ...[
              Text('Frequency', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              // We use dynamic for frequency - interface will depend on the type
              _buildFrequencySelector(),
              const SizedBox(height: 16),
            ],

            // Interval settings (if provided)
            if (widget.interval != null &&
                widget.onIntervalChanged != null) ...[
              Text(
                'Repeat every',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _buildIntervalSelector(),
              const SizedBox(height: 16),
            ],

            // Days selection (if provided)
            if (widget.selectedDays != null &&
                widget.onDaysChanged != null) ...[
              Text(
                'Select days',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _buildDaysSelector(),
              const SizedBox(height: 16),
            ],

            // End date picker
            Row(
              children: [
                const Text('Ends On:'),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _endDate != null ? _formatDate(_endDate!) : 'Never',
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_endDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _endDate = null;
                      });
                      widget.onEndDateChanged?.call(null);
                    },
                    tooltip: 'Clear end date',
                  ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              _getRecurringDescription(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPattern(String pattern) {
    return pattern.substring(0, 1).toUpperCase() + pattern.substring(1);
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      widget.onEndDateChanged?.call(picked);
    }
  }

  // Helper methods for new components
  Widget _buildFrequencySelector() {
    // If frequency is an enum, we can build a dropdown
    if (widget.frequency != null &&
        widget.frequency.runtimeType.toString().contains('Enum')) {
      return DropdownButtonFormField<dynamic>(
        value: widget.frequency,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        items:
            widget.frequency.runtimeType.toString().contains(
              'RecurrenceFrequency',
            )
            ? RecurrenceFrequency.values.map((freq) {
                return DropdownMenuItem<dynamic>(
                  value: freq,
                  child: Text(freq.displayName),
                );
              }).toList()
            : [],
        onChanged: (value) {
          if (value != null) {
            widget.onFrequencyChanged?.call(value);
          }
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildIntervalSelector() {
    return Row(
      children: [
        Expanded(
          child: Slider(
            value: widget.interval!.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: widget.interval.toString(),
            onChanged: (value) {
              widget.onIntervalChanged?.call(value.round());
            },
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            widget.interval.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildDaysSelector() {
    return Wrap(
      spacing: 8,
      children: [
        for (int i = 0; i < 7; i++)
          FilterChip(
            label: Text(_getDayName(i)),
            selected: widget.selectedDays!.contains(i),
            onSelected: (selected) {
              final newSelectedDays = List<int>.from(widget.selectedDays!);
              if (selected) {
                if (!newSelectedDays.contains(i)) {
                  newSelectedDays.add(i);
                }
              } else {
                newSelectedDays.remove(i);
              }
              widget.onDaysChanged?.call(newSelectedDays);
            },
          ),
      ],
    );
  }

  String _getDayName(int dayIndex) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[dayIndex % 7];
  }

  String _getRecurringDescription() {
    final now = DateTime.now();
    String endDescription = _endDate == null
        ? 'with no end date'
        : 'until ${_formatDate(_endDate!)}';

    switch (_selectedPattern) {
      case 'daily':
        return 'This event will repeat every day $endDescription';
      case 'weekdays':
        return 'This event will repeat every weekday (Monday to Friday) $endDescription';
      case 'weekly':
        return 'This event will repeat every week on ${_getDayName(now.weekday)} $endDescription';
      case 'biweekly':
        return 'This event will repeat every two weeks on ${_getDayName(now.weekday)} $endDescription';
      case 'monthly':
        return 'This event will repeat on the ${_getOrdinal(now.day)} of each month $endDescription';
      case 'yearly':
        return 'This event will repeat annually on ${_formatDate(now, includeYear: false)} $endDescription';
      default:
        return 'This event will repeat $endDescription';
    }
  }

  String _getOrdinal(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1:
        return '${day}st';
      case 2:
        return '${day}nd';
      case 3:
        return '${day}rd';
      default:
        return '${day}th';
    }
  }

  String _formatDate(DateTime date, {bool includeYear = true}) {
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

    return includeYear
        ? '${months[date.month - 1]} ${date.day}, ${date.year}'
        : '${months[date.month - 1]} ${date.day}';
  }
}
