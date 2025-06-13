import 'package:equatable/equatable.dart';

import '../domain/entities/calendar_event.dart';

/// Base class for calendar management events
abstract class CalendarManagementEvent extends Equatable {
  const CalendarManagementEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load calendar events with filtering and pagination
class CalendarEventsRequested extends CalendarManagementEvent {
  const CalendarEventsRequested({
    this.startDate,
    this.endDate,
    this.eventType,
    this.status,
    this.priority,
    this.isAllDay,
    this.isRecurring,
    this.projectId,
    this.taskId,
    this.createdByUserId,
    this.assignedToUserId,
    this.pageNumber = 1,
    this.pageSize = 10,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final CalendarEventType? eventType;
  final CalendarEventStatus? status;
  final CalendarEventPriority? priority;
  final bool? isAllDay;
  final bool? isRecurring;
  final String? projectId;
  final String? taskId;
  final String? createdByUserId;
  final String? assignedToUserId;
  final int pageNumber;
  final int pageSize;

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    eventType,
    status,
    priority,
    isAllDay,
    isRecurring,
    projectId,
    taskId,
    createdByUserId,
    assignedToUserId,
    pageNumber,
    pageSize,
  ];
}

/// Event to load a specific calendar event by ID
class CalendarEventRequested extends CalendarManagementEvent {
  const CalendarEventRequested(this.eventId);

  final String eventId;

  @override
  List<Object> get props => [eventId];
}

/// Event to create a new calendar event
class CalendarEventCreated extends CalendarManagementEvent {
  const CalendarEventCreated(this.event);

  final CalendarEvent event;

  @override
  List<Object> get props => [event];
}

/// Event to update an existing calendar event
class CalendarEventUpdated extends CalendarManagementEvent {
  const CalendarEventUpdated(this.event);

  final CalendarEvent event;

  @override
  List<Object> get props => [event];
}

/// Event to delete a calendar event
class CalendarEventDeleted extends CalendarManagementEvent {
  const CalendarEventDeleted(this.eventId);

  final String eventId;

  @override
  List<Object> get props => [eventId];
}

/// Event to load events by project
class ProjectEventsRequested extends CalendarManagementEvent {
  const ProjectEventsRequested({
    required this.projectId,
    this.startDate,
    this.endDate,
    this.eventType,
    this.status,
  });

  final String projectId;
  final DateTime? startDate;
  final DateTime? endDate;
  final CalendarEventType? eventType;
  final CalendarEventStatus? status;

  @override
  List<Object?> get props => [projectId, startDate, endDate, eventType, status];
}

/// Event to load events by task
class TaskEventsRequested extends CalendarManagementEvent {
  const TaskEventsRequested(this.taskId);

  final String taskId;

  @override
  List<Object> get props => [taskId];
}

/// Event to load events by user
class UserEventsRequested extends CalendarManagementEvent {
  const UserEventsRequested(this.userId);

  final String userId;

  @override
  List<Object> get props => [userId];
}

/// Event to load upcoming events
class UpcomingEventsRequested extends CalendarManagementEvent {
  const UpcomingEventsRequested({this.days = 7, this.userId});

  final int days;
  final String? userId;

  @override
  List<Object?> get props => [days, userId];
}

/// Event to check for conflicts
class ConflictCheckRequested extends CalendarManagementEvent {
  const ConflictCheckRequested({
    required this.startDateTime,
    required this.endDateTime,
    required this.userId,
    this.excludeEventId,
  });

  final DateTime startDateTime;
  final DateTime endDateTime;
  final String userId;
  final String? excludeEventId;

  @override
  List<Object?> get props => [
    startDateTime,
    endDateTime,
    userId,
    excludeEventId,
  ];
}

/// Event to search calendar events
class CalendarEventsSearched extends CalendarManagementEvent {
  const CalendarEventsSearched(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

/// Event to filter events by type
class EventsFilteredByType extends CalendarManagementEvent {
  const EventsFilteredByType(this.eventType);

  final CalendarEventType eventType;

  @override
  List<Object> get props => [eventType];
}

/// Event to filter events by status
class EventsFilteredByStatus extends CalendarManagementEvent {
  const EventsFilteredByStatus(this.status);

  final CalendarEventStatus status;

  @override
  List<Object> get props => [status];
}

/// Event to filter events by priority
class EventsFilteredByPriority extends CalendarManagementEvent {
  const EventsFilteredByPriority(this.priority);

  final CalendarEventPriority priority;

  @override
  List<Object> get props => [priority];
}

/// Event to refresh current view
class CalendarManagementRefreshed extends CalendarManagementEvent {
  const CalendarManagementRefreshed();
}
