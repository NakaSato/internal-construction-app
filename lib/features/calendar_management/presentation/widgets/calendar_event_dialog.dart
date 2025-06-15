import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/calendar_event.dart';
import '../../application/calendar_management_bloc.dart';
import '../../application/calendar_management_event.dart';
import '../widgets/recurring_event_settings.dart';

/// Dialog for creating and editing calendar events
class CalendarEventDialog extends StatefulWidget {
  final CalendarEvent? event;
  final DateTime? selectedDate;
  final bool isEditing;

  const CalendarEventDialog({
    super.key,
    this.event,
    this.selectedDate,
    this.isEditing = false,
  });

  @override
  State<CalendarEventDialog> createState() => _CalendarEventDialogState();
}

class _CalendarEventDialogState extends State<CalendarEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;
  late TextEditingController _attendeesController;
  late TextEditingController _meetingUrlController;
  late DateTime _startDateTime;
  late DateTime _endDateTime;
  late CalendarEventType _eventType;
  late CalendarEventStatus _status;
  late CalendarEventPriority _priority;
  late bool _isAllDay;
  late bool _isPrivate;
  late bool _isRecurring;
  late int _reminderMinutes;
  String? _selectedColor;
  String? _recurrencePattern;
  DateTime? _recurrenceEndDate;

  // Recurring event settings
  RecurrenceFrequency _recurrenceFrequency = RecurrenceFrequency.daily;
  int _recurrenceInterval = 1;
  List<int> _selectedDays = [];

  final List<Color> _eventColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.event != null) {
      _titleController = TextEditingController(text: widget.event!.title);
      _descriptionController = TextEditingController(
        text: widget.event!.description ?? '',
      );
      _locationController = TextEditingController(
        text: widget.event!.location ?? '',
      );
      _notesController = TextEditingController(text: widget.event!.notes ?? '');
      _attendeesController = TextEditingController(
        text: widget.event!.attendees?.join(', ') ?? '',
      );
      _meetingUrlController = TextEditingController(
        text: widget.event!.meetingUrl ?? '',
      );
      _startDateTime = widget.event!.startDateTime;
      _endDateTime = widget.event!.endDateTime;
      _eventType = widget.event!.eventType;
      _status = widget.event!.status;
      _priority = widget.event!.priority;
      _isAllDay = widget.event!.isAllDay;
      _isPrivate = widget.event!.isPrivate;
      _reminderMinutes = widget.event!.reminderMinutes;
      _selectedColor = widget.event!.color;

      // Initialize recurring event settings
      _isRecurring = widget.event!.isRecurring;
      _recurrencePattern = widget.event!.recurrencePattern;
      _recurrenceEndDate = widget.event!.recurrenceEndDate;
      _selectedDays = widget.event!.selectedDays;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _locationController = TextEditingController();
      _notesController = TextEditingController();
      _attendeesController = TextEditingController();
      _meetingUrlController = TextEditingController();
      _startDateTime = widget.selectedDate ?? DateTime.now();
      _endDateTime = _startDateTime.add(const Duration(hours: 1));
      _eventType = CalendarEventType.meeting;
      _status = CalendarEventStatus.scheduled;
      _priority = CalendarEventPriority.medium;
      _isAllDay = false;
      _isPrivate = false;
      _reminderMinutes = 15;
      _selectedColor = null;

      // Default recurring event settings
      _isRecurring = false;
      _recurrenceFrequency = RecurrenceFrequency.daily;
      _recurrenceInterval = 1;
      _selectedDays = [];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _attendeesController.dispose();
    _meetingUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildLocationField(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildEventTypeField()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildStatusField()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildPriorityField()),
                          const SizedBox(width: 16),
                          Expanded(child: _buildReminderField()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildAllDaySwitch(),
                      const SizedBox(height: 16),
                      if (!_isAllDay) ...[
                        _buildTimeFields(),
                        const SizedBox(height: 16),
                      ],
                      _buildMeetingUrlField(),
                      const SizedBox(height: 16),
                      _buildAttendeesField(),
                      const SizedBox(height: 16),
                      _buildNotesField(),
                      const SizedBox(height: 16),
                      _buildPrivateSwitch(),
                      const SizedBox(height: 16),
                      _buildColorPicker(),
                      const SizedBox(height: 16),
                      _buildRecurringEventSwitch(),
                      if (_isRecurring) ...[
                        RecurringEventSettings(
                          initialPattern: _recurrencePattern,
                          initialEndDate: _recurrenceEndDate,
                          frequency: _recurrenceFrequency,
                          interval: _recurrenceInterval,
                          selectedDays: _selectedDays,
                          onPatternChanged: (pattern) {
                            setState(() {
                              _recurrencePattern = pattern;
                            });
                          },
                          onEndDateChanged: (date) {
                            setState(() {
                              _recurrenceEndDate = date;
                            });
                          },
                          onDaysChanged: (value) {
                            setState(() {
                              _selectedDays = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          widget.isEditing ? Icons.edit : Icons.add,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          widget.isEditing ? 'Edit Event' : 'Create Event',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        if (widget.isEditing)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteEvent,
            tooltip: 'Delete Event',
          ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Event Title',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an event title';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: 'Location (Optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_on),
      ),
    );
  }

  Widget _buildEventTypeField() {
    return DropdownButtonFormField<CalendarEventType>(
      value: _eventType,
      decoration: const InputDecoration(
        labelText: 'Event Type',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: CalendarEventType.values.map((type) {
        return DropdownMenuItem(value: type, child: Text(type.displayName));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _eventType = value;
          });
        }
      },
    );
  }

  Widget _buildStatusField() {
    return DropdownButtonFormField<CalendarEventStatus>(
      value: _status,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.track_changes),
      ),
      items: CalendarEventStatus.values.map((status) {
        return DropdownMenuItem(value: status, child: Text(status.displayName));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _status = value;
          });
        }
      },
    );
  }

  Widget _buildPriorityField() {
    return DropdownButtonFormField<CalendarEventPriority>(
      value: _priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.priority_high),
      ),
      items: CalendarEventPriority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Text(priority.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _priority = value;
          });
        }
      },
    );
  }

  Widget _buildReminderField() {
    return DropdownButtonFormField<int>(
      value: _reminderMinutes,
      decoration: const InputDecoration(
        labelText: 'Reminder',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.notifications),
      ),
      items: [
        const DropdownMenuItem(value: 0, child: Text('No reminder')),
        const DropdownMenuItem(value: 5, child: Text('5 minutes')),
        const DropdownMenuItem(value: 15, child: Text('15 minutes')),
        const DropdownMenuItem(value: 30, child: Text('30 minutes')),
        const DropdownMenuItem(value: 60, child: Text('1 hour')),
        const DropdownMenuItem(value: 1440, child: Text('1 day')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _reminderMinutes = value;
          });
        }
      },
    );
  }

  Widget _buildAllDaySwitch() {
    return SwitchListTile(
      title: const Text('All Day Event'),
      subtitle: const Text('Event lasts the entire day'),
      value: _isAllDay,
      onChanged: (value) {
        setState(() {
          _isAllDay = value;
          if (value) {
            _startDateTime = DateTime(
              _startDateTime.year,
              _startDateTime.month,
              _startDateTime.day,
            );
            _endDateTime = _startDateTime.add(const Duration(days: 1));
          }
        });
      },
    );
  }

  Widget _buildPrivateSwitch() {
    return SwitchListTile(
      title: const Text('Private Event'),
      subtitle: const Text('Only you can see this event'),
      value: _isPrivate,
      onChanged: (value) {
        setState(() {
          _isPrivate = value;
        });
      },
    );
  }

  Widget _buildRecurringEventSwitch() {
    return SwitchListTile(
      title: const Text('Recurring Event'),
      subtitle: const Text('Event repeats on a regular basis'),
      value: _isRecurring,
      onChanged: (value) {
        setState(() {
          _isRecurring = value;
        });
      },
    );
  }

  Widget _buildTimeFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateTimeField(
                label: 'Start',
                dateTime: _startDateTime,
                onChanged: (newDateTime) {
                  setState(() {
                    _startDateTime = newDateTime;
                    if (_endDateTime.isBefore(_startDateTime)) {
                      _endDateTime = _startDateTime.add(
                        const Duration(hours: 1),
                      );
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateTimeField(
                label: 'End',
                dateTime: _endDateTime,
                onChanged: (newDateTime) {
                  setState(() {
                    _endDateTime = newDateTime;
                  });
                },
              ),
            ),
          ],
        ),
        if (_endDateTime.isBefore(_startDateTime))
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'End time must be after start time',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime dateTime,
    required Function(DateTime) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDateTime(dateTime, onChanged),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text('${dateTime.day}/${dateTime.month}/${dateTime.year}'),
                Text(
                  '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingUrlField() {
    return TextFormField(
      controller: _meetingUrlController,
      decoration: const InputDecoration(
        labelText: 'Meeting URL (Optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.video_call),
      ),
    );
  }

  Widget _buildAttendeesField() {
    return TextFormField(
      controller: _attendeesController,
      decoration: const InputDecoration(
        labelText: 'Attendees (Optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.people),
        hintText: 'Enter email addresses separated by commas',
      ),
      maxLines: 2,
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes (Optional)',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 3,
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Color (Optional)',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _eventColors.map((color) {
            final colorValue =
                (color.a * 255).round() << 24 |
                (color.r * 255).round() << 16 |
                (color.g * 255).round() << 8 |
                (color.b * 255).round();
            final colorHex =
                '#${colorValue.toRadixString(16).padLeft(8, '0').substring(2)}';
            final isSelected = _selectedColor == colorHex;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = isSelected ? null : colorHex;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _saveEvent,
          child: Text(widget.isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _selectDateTime(
    DateTime currentDateTime,
    Function(DateTime) onChanged,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: currentDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDateTime),
      );

      if (time != null && mounted) {
        onChanged(
          DateTime(date.year, date.month, date.day, time.hour, time.minute),
        );
      }
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isAllDay && _endDateTime.isBefore(_startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final event = CalendarEvent(
      id: widget.event?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      startDateTime: _startDateTime,
      endDateTime: _endDateTime,
      eventType: _eventType,
      status: _status,
      priority: _priority,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      isAllDay: _isAllDay,
      reminderMinutes: _reminderMinutes,
      isPrivate: _isPrivate,
      meetingUrl: _meetingUrlController.text.trim().isEmpty
          ? null
          : _meetingUrlController.text.trim(),
      attendees: _attendeesController.text.trim().isEmpty
          ? null
          : _attendeesController.text.split(',').map((e) => e.trim()).toList(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      color: _selectedColor,
      isRecurring: _isRecurring,
      recurrencePattern: _recurrencePattern,
      recurrenceEndDate: _recurrenceEndDate,
      selectedDays: _selectedDays,
    );

    if (widget.isEditing) {
      context.read<CalendarManagementBloc>().add(CalendarEventUpdated(event));
    } else {
      context.read<CalendarManagementBloc>().add(CalendarEventCreated(event));
    }

    Navigator.of(context).pop();
  }

  void _deleteEvent() {
    if (widget.event?.id != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Event'),
          content: const Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<CalendarManagementBloc>().add(
                  CalendarEventDeleted(widget.event!.id),
                );
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close event dialog
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }
}
