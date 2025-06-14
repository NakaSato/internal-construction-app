import 'package:flutter/material.dart';

import '../../domain/entities/work_event.dart';

/// Widget for displaying a list of work events
class EventListWidget extends StatelessWidget {
  final List<WorkEvent> events;
  final Function(WorkEvent)? onEventTap;
  final bool showDate;

  const EventListWidget({
    super.key,
    required this.events,
    this.onEventTap,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(context, event);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No events found for this period',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, WorkEvent event) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () => onEventTap?.call(event),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildEventTypeIcon(event.eventType),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (showDate) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatEventDateTime(event),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (event.color != null)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _parseColor(event.color!),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              if (event.description != null &&
                  event.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  event.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (event.location != null && event.location!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (event.attendees.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${event.attendees.length} attendee${event.attendees.length == 1 ? '' : 's'}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypeIcon(WorkEventType type) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getEventTypeColor(type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getEventTypeIcon(type),
        size: 20,
        color: _getEventTypeColor(type),
      ),
    );
  }

  String _formatEventDateTime(WorkEvent event) {
    if (event.isAllDay) {
      return 'All day - ${_formatDate(event.startTime)}';
    }

    final startDate = _formatDate(event.startTime);
    final endDate = _formatDate(event.endTime);
    final startTime = _formatTime(event.startTime);
    final endTime = _formatTime(event.endTime);

    if (startDate == endDate) {
      return '$startDate, $startTime - $endTime';
    } else {
      return '$startDate $startTime - $endDate $endTime';
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

  String _formatTime(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Color _parseColor(String colorHex) {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
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
}
