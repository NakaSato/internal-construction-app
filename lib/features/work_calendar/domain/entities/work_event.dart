import 'package:equatable/equatable.dart';

/// Work calendar event entity
class WorkEvent extends Equatable {
  const WorkEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description,
    this.location,
    this.color,
    this.isAllDay = false,
    this.eventType = WorkEventType.meeting,
    this.attendees = const [],
  });

  /// Unique event identifier
  final String id;

  /// Event title
  final String title;

  /// Event start time
  final DateTime startTime;

  /// Event end time
  final DateTime endTime;

  /// Optional event description
  final String? description;

  /// Optional event location
  final String? location;

  /// Event color (hex string)
  final String? color;

  /// Whether this is an all-day event
  final bool isAllDay;

  /// Type of work event
  final WorkEventType eventType;

  /// List of attendee email addresses
  final List<String> attendees;

  /// Event duration
  Duration get duration => endTime.difference(startTime);

  /// Whether event is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Whether event is in the past
  bool get isPast => DateTime.now().isAfter(endTime);

  /// Whether event is in the future
  bool get isFuture => DateTime.now().isBefore(startTime);

  /// Format duration as string
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Copy with method for immutable updates
  WorkEvent copyWith({
    String? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    String? description,
    String? location,
    String? color,
    bool? isAllDay,
    WorkEventType? eventType,
    List<String>? attendees,
  }) {
    return WorkEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      location: location ?? this.location,
      color: color ?? this.color,
      isAllDay: isAllDay ?? this.isAllDay,
      eventType: eventType ?? this.eventType,
      attendees: attendees ?? this.attendees,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    startTime,
    endTime,
    description,
    location,
    color,
    isAllDay,
    eventType,
    attendees,
  ];

  @override
  String toString() =>
      'WorkEvent(id: $id, title: $title, start: $startTime, end: $endTime)';
}

/// Types of work events
enum WorkEventType {
  meeting,
  appointment,
  task,
  reminder,
  break_,
  travel,
  training,
  conference,
  other,
}

/// Extension for WorkEventType
extension WorkEventTypeX on WorkEventType {
  /// Display name for the event type
  String get displayName {
    switch (this) {
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

  /// Default color for the event type
  String get defaultColor {
    switch (this) {
      case WorkEventType.meeting:
        return '#2196F3'; // Blue
      case WorkEventType.appointment:
        return '#4CAF50'; // Green
      case WorkEventType.task:
        return '#FF9800'; // Orange
      case WorkEventType.reminder:
        return '#9C27B0'; // Purple
      case WorkEventType.break_:
        return '#8BC34A'; // Light Green
      case WorkEventType.travel:
        return '#795548'; // Brown
      case WorkEventType.training:
        return '#3F51B5'; // Indigo
      case WorkEventType.conference:
        return '#E91E63'; // Pink
      case WorkEventType.other:
        return '#607D8B'; // Blue Grey
    }
  }
}
