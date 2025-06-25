import 'package:flutter/material.dart';

/// Find a Time widget for scheduling meetings with multiple attendees
class FindTimeWidget extends StatefulWidget {
  const FindTimeWidget({
    super.key,
    required this.attendeeIds,
    required this.duration,
    this.preferredDate,
    this.onTimeSlotSelected,
  });

  final List<String> attendeeIds;
  final Duration duration;
  final DateTime? preferredDate;
  final Function(DateTime startTime, DateTime endTime)? onTimeSlotSelected;

  @override
  State<FindTimeWidget> createState() => _FindTimeWidgetState();
}

class _FindTimeWidgetState extends State<FindTimeWidget> {
  DateTime _selectedDate = DateTime.now();
  List<TimeSlot> _availableSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.preferredDate ?? DateTime.now();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Replace with actual API call
      // final availability = await CalendarApiService.getAvailability(
      //   attendeeIds: widget.attendeeIds,
      //   date: _selectedDate,
      //   duration: widget.duration,
      // );

      // Mock data for demonstration
      await Future.delayed(const Duration(milliseconds: 500));
      _availableSlots = _generateMockAvailability();
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading availability: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<TimeSlot> _generateMockAvailability() {
    final List<TimeSlot> slots = [];
    final baseDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    // Generate morning slots (9 AM - 12 PM)
    for (int hour = 9; hour < 12; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final startTime = baseDate.add(Duration(hours: hour, minutes: minute));
        final endTime = startTime.add(widget.duration);

        slots.add(
          TimeSlot(
            startTime: startTime,
            endTime: endTime,
            availability: _calculateAvailability(startTime),
          ),
        );
      }
    }

    // Generate afternoon slots (2 PM - 6 PM)
    for (int hour = 14; hour < 18; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final startTime = baseDate.add(Duration(hours: hour, minutes: minute));
        final endTime = startTime.add(widget.duration);

        slots.add(
          TimeSlot(
            startTime: startTime,
            endTime: endTime,
            availability: _calculateAvailability(startTime),
          ),
        );
      }
    }

    return slots.where((slot) => slot.availability > 0.5).toList();
  }

  double _calculateAvailability(DateTime startTime) {
    // Mock calculation - in real app, this would be based on attendee calendars
    final hour = startTime.hour;
    if (hour >= 9 && hour <= 11) return 0.9; // Morning - high availability
    if (hour >= 14 && hour <= 16) return 0.7; // Early afternoon - medium
    if (hour >= 16 && hour <= 18) return 0.5; // Late afternoon - lower
    return 0.2; // Other times - low availability
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildDateSelector(),
            const SizedBox(height: 16),
            _buildAttendeeInfo(),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTimeSlots(),
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
        Icon(Icons.schedule, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text('Find a Time', style: Theme.of(context).textTheme.headlineSmall),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 12),
            Text(
              'Date: ${_formatDate(_selectedDate)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton(onPressed: _selectDate, child: const Text('Change')),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendeeInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.group),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.attendeeIds.length} attendees',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Meeting duration: ${_formatDuration(widget.duration)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (_availableSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No available time slots',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different date or fewer attendees',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _availableSlots.length,
      itemBuilder: (context, index) {
        final slot = _availableSlots[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getAvailabilityColor(slot.availability),
              child: Text(
                '${(slot.availability * 100).toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(_formatTimeRange(slot.startTime, slot.endTime)),
            subtitle: Text(_getAvailabilityText(slot.availability)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _selectTimeSlot(slot),
          ),
        );
      },
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
      ],
    );
  }

  Color _getAvailabilityColor(double availability) {
    if (availability >= 0.8) return Colors.green;
    if (availability >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getAvailabilityText(double availability) {
    if (availability >= 0.8) return 'High availability';
    if (availability >= 0.6) return 'Medium availability';
    return 'Low availability';
  }

  void _selectTimeSlot(TimeSlot slot) {
    widget.onTimeSlotSelected?.call(slot.startTime, slot.endTime);
    Navigator.of(context).pop();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      _loadAvailability();
    }
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

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

/// Time slot model for availability
class TimeSlot {
  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.availability,
  });

  final DateTime startTime;
  final DateTime endTime;
  final double availability; // 0.0 to 1.0
}
