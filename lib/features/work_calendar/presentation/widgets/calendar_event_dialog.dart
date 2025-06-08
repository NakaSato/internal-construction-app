import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/work_event.dart';
import '../../application/work_calendar_bloc.dart';
import '../../application/work_calendar_event.dart';

/// Dialog for creating and editing work events
class CalendarEventDialog extends StatefulWidget {
  final WorkEvent? event;
  final DateTime selectedDate;
  final bool isEditing;

  const CalendarEventDialog({
    super.key,
    this.event,
    required this.selectedDate,
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
  late DateTime _startTime;
  late DateTime _endTime;
  late WorkEventType _eventType;
  late bool _isAllDay;
  String? _selectedColor;

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
      _startTime = widget.event!.startTime;
      _endTime = widget.event!.endTime;
      _eventType = widget.event!.eventType;
      _isAllDay = widget.event!.isAllDay;
      _selectedColor = widget.event!.color;
    } else {
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _locationController = TextEditingController();
      _startTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        DateTime.now().hour,
        0,
      );
      _endTime = _startTime.add(const Duration(hours: 1));
      _eventType = WorkEventType.meeting;
      _isAllDay = false;
      _selectedColor = null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
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
                      _buildEventTypeField(),
                      const SizedBox(height: 16),
                      _buildAllDaySwitch(),
                      const SizedBox(height: 16),
                      if (!_isAllDay) ...[
                        _buildTimeFields(),
                        const SizedBox(height: 16),
                      ],
                      _buildColorPicker(),
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
    return DropdownButtonFormField<WorkEventType>(
      value: _eventType,
      decoration: const InputDecoration(
        labelText: 'Event Type',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category),
      ),
      items: WorkEventType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              Icon(
                _getEventTypeIcon(type),
                size: 16,
                color: _getEventTypeColor(type),
              ),
              const SizedBox(width: 8),
              Text(_getEventTypeDisplayName(type)),
            ],
          ),
        );
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

  Widget _buildAllDaySwitch() {
    return SwitchListTile(
      title: const Text('All Day Event'),
      subtitle: const Text('Event lasts the entire day'),
      value: _isAllDay,
      onChanged: (value) {
        setState(() {
          _isAllDay = value;
          if (value) {
            _startTime = DateTime(
              _startTime.year,
              _startTime.month,
              _startTime.day,
            );
            _endTime = _startTime.add(const Duration(hours: 24));
          }
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
                dateTime: _startTime,
                onChanged: (newDateTime) {
                  setState(() {
                    _startTime = newDateTime;
                    // Ensure end time is after start time
                    if (_endTime.isBefore(_startTime)) {
                      _endTime = _startTime.add(const Duration(hours: 1));
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateTimeField(
                label: 'End',
                dateTime: _endTime,
                onChanged: (newDateTime) {
                  setState(() {
                    _endTime = newDateTime;
                  });
                },
              ),
            ),
          ],
        ),
        if (_endTime.isBefore(_startTime))
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
                Text(
                  '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
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
            final colorHex = '#${color.value.toRadixString(16).substring(2)}';
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

    if (!_isAllDay && _endTime.isBefore(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final event = WorkEvent(
      id: widget.event?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      eventType: _eventType,
      isAllDay: _isAllDay,
      color: _selectedColor,
      attendees: widget.event?.attendees ?? [],
    );

    if (widget.isEditing) {
      context.read<WorkCalendarBloc>().add(WorkEventUpdated(event));
    } else {
      context.read<WorkCalendarBloc>().add(WorkEventCreated(event));
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
                context.read<WorkCalendarBloc>().add(
                  WorkEventDeleted(widget.event!.id),
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

  String _getEventTypeDisplayName(WorkEventType type) {
    switch (type) {
      case WorkEventType.meeting:
        return 'Meeting';
      case WorkEventType.appointment:
        return 'Appointment';
      case WorkEventType.task:
        return 'Task';
      case WorkEventType.reminder:
        return 'Reminder';
      case WorkEventType.break_:
        return 'Break';
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
}
