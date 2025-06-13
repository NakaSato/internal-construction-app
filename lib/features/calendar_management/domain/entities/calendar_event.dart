import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Calendar event entity for API-based calendar management
class CalendarEvent extends Equatable {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.startDateTime,
    required this.endDateTime,
    required this.eventType,
    required this.status,
    required this.priority,
    this.description,
    this.location,
    this.projectId,
    this.projectName,
    this.taskId,
    this.taskName,
    this.createdByUserId,
    this.createdByUserName,
    this.assignedToUserId,
    this.assignedToUserName,
    this.isAllDay = false,
    this.isRecurring = false,
    this.recurrencePattern,
    this.recurrenceEndDate,
    this.reminderMinutes = 15,
    this.isPrivate = false,
    this.meetingUrl,
    this.attendees,
    this.notes,
    this.color,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique event identifier
  final String id;

  /// Event title
  final String title;

  /// Event description
  final String? description;

  /// Event start date and time
  final DateTime startDateTime;

  /// Event end date and time
  final DateTime endDateTime;

  /// Whether this is an all-day event
  final bool isAllDay;

  /// Type of event
  final CalendarEventType eventType;

  /// Event status
  final CalendarEventStatus status;

  /// Event priority
  final CalendarEventPriority priority;

  /// Event location
  final String? location;

  /// Associated project ID
  final String? projectId;

  /// Associated project name
  final String? projectName;

  /// Associated task ID
  final String? taskId;

  /// Associated task name
  final String? taskName;

  /// User who created the event
  final String? createdByUserId;

  /// Name of user who created the event
  final String? createdByUserName;

  /// User assigned to the event
  final String? assignedToUserId;

  /// Name of user assigned to the event
  final String? assignedToUserName;

  /// Whether event is recurring
  final bool isRecurring;

  /// Recurrence pattern (e.g., "weekly", "monthly")
  final String? recurrencePattern;

  /// End date for recurring events
  final DateTime? recurrenceEndDate;

  /// Reminder minutes before event
  final int reminderMinutes;

  /// Whether event is private
  final bool isPrivate;

  /// Meeting URL (Teams, Zoom, etc.)
  final String? meetingUrl;

  /// Attendee email addresses
  final String? attendees;

  /// Additional notes
  final String? notes;

  /// Event color (hex string)
  final String? color;

  /// When event was created
  final DateTime? createdAt;

  /// When event was last updated
  final DateTime? updatedAt;

  /// Event duration
  Duration get duration => endDateTime.difference(startDateTime);

  /// Whether event is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }

  /// Whether event is in the past
  bool get isPast => DateTime.now().isAfter(endDateTime);

  /// Whether event is in the future
  bool get isFuture => DateTime.now().isBefore(startDateTime);

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
  CalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    bool? isAllDay,
    CalendarEventType? eventType,
    CalendarEventStatus? status,
    CalendarEventPriority? priority,
    String? location,
    String? projectId,
    String? projectName,
    String? taskId,
    String? taskName,
    String? createdByUserId,
    String? createdByUserName,
    String? assignedToUserId,
    String? assignedToUserName,
    bool? isRecurring,
    String? recurrencePattern,
    DateTime? recurrenceEndDate,
    int? reminderMinutes,
    bool? isPrivate,
    String? meetingUrl,
    String? attendees,
    String? notes,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      isAllDay: isAllDay ?? this.isAllDay,
      eventType: eventType ?? this.eventType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      location: location ?? this.location,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdByUserName: createdByUserName ?? this.createdByUserName,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      assignedToUserName: assignedToUserName ?? this.assignedToUserName,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrencePattern: recurrencePattern ?? this.recurrencePattern,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      isPrivate: isPrivate ?? this.isPrivate,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      attendees: attendees ?? this.attendees,
      notes: notes ?? this.notes,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startDateTime,
    endDateTime,
    isAllDay,
    eventType,
    status,
    priority,
    location,
    projectId,
    projectName,
    taskId,
    taskName,
    createdByUserId,
    createdByUserName,
    assignedToUserId,
    assignedToUserName,
    isRecurring,
    recurrencePattern,
    recurrenceEndDate,
    reminderMinutes,
    isPrivate,
    meetingUrl,
    attendees,
    notes,
    color,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() =>
      'CalendarEvent(id: $id, title: $title, start: $startDateTime, end: $endDateTime)';
}

/// Types of calendar events
enum CalendarEventType {
  meeting(1, 'Meeting', Icons.people),
  deadline(2, 'Deadline', Icons.schedule),
  installation(3, 'Installation', Icons.build),
  maintenance(4, 'Maintenance', Icons.settings),
  training(5, 'Training', Icons.school),
  other(6, 'Other', Icons.event);

  const CalendarEventType(this.value, this.displayName, this.icon);

  final int value;
  final String displayName;
  final IconData icon;

  /// Get type by value
  static CalendarEventType fromValue(int value) {
    return CalendarEventType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => other,
    );
  }

  /// Get type by name
  static CalendarEventType fromName(String name) {
    return CalendarEventType.values.firstWhere(
      (type) => type.name == name.toLowerCase(),
      orElse: () => other,
    );
  }
}

/// Calendar event status
enum CalendarEventStatus {
  scheduled(1, 'Scheduled'),
  inProgress(2, 'In Progress'),
  completed(3, 'Completed'),
  cancelled(4, 'Cancelled'),
  postponed(5, 'Postponed');

  const CalendarEventStatus(this.value, this.displayName);

  final int value;
  final String displayName;

  /// Get status by value
  static CalendarEventStatus fromValue(int value) {
    return CalendarEventStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => scheduled,
    );
  }

  /// Get status by name
  static CalendarEventStatus fromName(String name) {
    return CalendarEventStatus.values.firstWhere(
      (status) => status.name == name.toLowerCase(),
      orElse: () => scheduled,
    );
  }
}

/// Calendar event priority
enum CalendarEventPriority {
  low(1, 'Low', Colors.green),
  medium(2, 'Medium', Colors.orange),
  high(3, 'High', Colors.red),
  critical(4, 'Critical', Colors.purple);

  const CalendarEventPriority(this.value, this.displayName, this.color);

  final int value;
  final String displayName;
  final Color color;

  /// Get priority by value
  static CalendarEventPriority fromValue(int value) {
    return CalendarEventPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => medium,
    );
  }

  /// Get priority by name
  static CalendarEventPriority fromName(String name) {
    return CalendarEventPriority.values.firstWhere(
      (priority) => priority.name == name.toLowerCase(),
      orElse: () => medium,
    );
  }
}

/// Extension for CalendarEventType
extension CalendarEventTypeX on CalendarEventType {
  /// Get color for event type
  String get defaultColor {
    switch (this) {
      case CalendarEventType.meeting:
        return '#2196F3'; // Blue
      case CalendarEventType.deadline:
        return '#F44336'; // Red
      case CalendarEventType.installation:
        return '#FF9800'; // Orange
      case CalendarEventType.maintenance:
        return '#4CAF50'; // Green
      case CalendarEventType.training:
        return '#9C27B0'; // Purple
      case CalendarEventType.other:
        return '#757575'; // Grey
    }
  }

  /// Get description for event type
  String get description {
    switch (this) {
      case CalendarEventType.meeting:
        return 'Team meetings, client calls, standup meetings';
      case CalendarEventType.deadline:
        return 'Project milestones, task due dates, deliverables';
      case CalendarEventType.installation:
        return 'On-site installation work, system commissioning';
      case CalendarEventType.maintenance:
        return 'Routine maintenance, inspections, repairs';
      case CalendarEventType.training:
        return 'Team training sessions, certification courses';
      case CalendarEventType.other:
        return 'General events not covered by other types';
    }
  }
}

/// Extension for CalendarEventStatus
extension CalendarEventStatusX on CalendarEventStatus {
  /// Get color for status
  String get color {
    switch (this) {
      case CalendarEventStatus.scheduled:
        return '#2196F3'; // Blue
      case CalendarEventStatus.inProgress:
        return '#FF9800'; // Orange
      case CalendarEventStatus.completed:
        return '#4CAF50'; // Green
      case CalendarEventStatus.cancelled:
        return '#F44336'; // Red
      case CalendarEventStatus.postponed:
        return '#9E9E9E'; // Grey
    }
  }
}

/// Extension for CalendarEventPriority
extension CalendarEventPriorityX on CalendarEventPriority {
  /// Get hex color string for priority
  String get hexColor {
    switch (this) {
      case CalendarEventPriority.low:
        return '#4CAF50'; // Green
      case CalendarEventPriority.medium:
        return '#FF9800'; // Orange
      case CalendarEventPriority.high:
        return '#F44336'; // Red
      case CalendarEventPriority.critical:
        return '#9C27B0'; // Purple
    }
  }
}
