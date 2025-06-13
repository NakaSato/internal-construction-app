import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/calendar_event.dart';
import '../../application/calendar_management_bloc.dart';
import '../../application/calendar_management_event.dart';

/// Filter criteria for calendar events
class CalendarEventFilters {
  final CalendarEventType? eventType;
  final CalendarEventStatus? status;
  final CalendarEventPriority? priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isAllDay;
  final bool? isRecurring;
  final String? projectId;
  final String? assignedToUserId;

  const CalendarEventFilters({
    this.eventType,
    this.status,
    this.priority,
    this.startDate,
    this.endDate,
    this.isAllDay,
    this.isRecurring,
    this.projectId,
    this.assignedToUserId,
  });

  bool get isEmpty =>
      eventType == null &&
      status == null &&
      priority == null &&
      startDate == null &&
      endDate == null &&
      isAllDay == null &&
      isRecurring == null &&
      projectId == null &&
      assignedToUserId == null;

  bool get isNotEmpty => !isEmpty;

  CalendarEventFilters copyWith({
    CalendarEventType? eventType,
    CalendarEventStatus? status,
    CalendarEventPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAllDay,
    bool? isRecurring,
    String? projectId,
    String? assignedToUserId,
  }) {
    return CalendarEventFilters(
      eventType: eventType ?? this.eventType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isAllDay: isAllDay ?? this.isAllDay,
      isRecurring: isRecurring ?? this.isRecurring,
      projectId: projectId ?? this.projectId,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
    );
  }

  CalendarEventFilters clearField(String field) {
    switch (field) {
      case 'eventType':
        return copyWith(eventType: null);
      case 'status':
        return copyWith(status: null);
      case 'priority':
        return copyWith(priority: null);
      case 'startDate':
        return copyWith(startDate: null);
      case 'endDate':
        return copyWith(endDate: null);
      case 'isAllDay':
        return copyWith(isAllDay: null);
      case 'isRecurring':
        return copyWith(isRecurring: null);
      case 'projectId':
        return copyWith(projectId: null);
      case 'assignedToUserId':
        return copyWith(assignedToUserId: null);
      default:
        return this;
    }
  }
}

/// Widget for filtering calendar events
class CalendarFilterWidget extends StatefulWidget {
  const CalendarFilterWidget({super.key});

  @override
  State<CalendarFilterWidget> createState() => _CalendarFilterWidgetState();
}

class _CalendarFilterWidgetState extends State<CalendarFilterWidget> {
  CalendarEventFilters _filters = const CalendarEventFilters();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filter Events',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                if (_filters.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filters = const CalendarEventFilters();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Filter options
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Type
                    _buildSectionTitle('Event Type'),
                    _buildEventTypeFilter(),
                    const SizedBox(height: 16),

                    // Status
                    _buildSectionTitle('Status'),
                    _buildStatusFilter(),
                    const SizedBox(height: 16),

                    // Priority
                    _buildSectionTitle('Priority'),
                    _buildPriorityFilter(),
                    const SizedBox(height: 16),

                    // Date Range
                    _buildSectionTitle('Date Range'),
                    _buildDateRangeFilter(),
                    const SizedBox(height: 16),

                    // Flags
                    _buildSectionTitle('Event Properties'),
                    _buildFlagsFilter(),
                  ],
                ),
              ),
            ),

            // Action buttons
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEventTypeFilter() {
    return Wrap(
      spacing: 8,
      children: CalendarEventType.values.map((type) {
        final isSelected = _filters.eventType == type;
        return FilterChip(
          label: Text(type.displayName),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _filters = _filters.copyWith(eventType: selected ? type : null);
            });
          },
          avatar: Icon(
            type.icon,
            size: 16,
            color: isSelected ? null : Theme.of(context).colorScheme.primary,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusFilter() {
    return Wrap(
      spacing: 8,
      children: CalendarEventStatus.values.map((status) {
        final isSelected = _filters.status == status;
        return FilterChip(
          label: Text(status.displayName),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _filters = _filters.copyWith(status: selected ? status : null);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildPriorityFilter() {
    return Wrap(
      spacing: 8,
      children: CalendarEventPriority.values.map((priority) {
        final isSelected = _filters.priority == priority;
        return FilterChip(
          label: Text(priority.displayName),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _filters = _filters.copyWith(
                priority: selected ? priority : null,
              );
            });
          },
          backgroundColor: isSelected
              ? null
              : priority.color.withValues(alpha: 0.1),
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                label: 'Start Date',
                value: _filters.startDate,
                onChanged: (date) {
                  setState(() {
                    _filters = _filters.copyWith(startDate: date);
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateField(
                label: 'End Date',
                value: _filters.endDate,
                onChanged: (date) {
                  setState(() {
                    _filters = _filters.copyWith(endDate: date);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        onChanged(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: value != null
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onChanged(null),
                )
              : const Icon(Icons.calendar_today),
        ),
        child: Text(
          value != null
              ? '${value!.day}/${value!.month}/${value!.year}'
              : 'Select date',
          style: value != null
              ? null
              : TextStyle(color: Theme.of(context).hintColor),
        ),
      ),
    );
  }

  Widget _buildFlagsFilter() {
    return Column(
      children: [
        _buildBooleanFilter(
          title: 'All Day Events',
          value: _filters.isAllDay,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(isAllDay: value);
            });
          },
        ),
        _buildBooleanFilter(
          title: 'Recurring Events',
          value: _filters.isRecurring,
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(isRecurring: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildBooleanFilter({
    required String title,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        SegmentedButton<bool?>(
          segments: const [
            ButtonSegment(value: null, label: Text('All')),
            ButtonSegment(value: true, label: Text('Yes')),
            ButtonSegment(value: false, label: Text('No')),
          ],
          selected: {value},
          onSelectionChanged: (Set<bool?> selected) {
            onChanged(selected.first);
          },
        ),
      ],
    );
  }

  void _applyFilters() {
    context.read<CalendarManagementBloc>().add(
      CalendarEventsRequested(
        eventType: _filters.eventType,
        status: _filters.status,
        priority: _filters.priority,
        startDate: _filters.startDate,
        endDate: _filters.endDate,
        isAllDay: _filters.isAllDay,
        isRecurring: _filters.isRecurring,
        projectId: _filters.projectId,
        assignedToUserId: _filters.assignedToUserId,
      ),
    );
    Navigator.of(context).pop();
  }
}
