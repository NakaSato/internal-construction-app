import 'package:equatable/equatable.dart';

import '../domain/entities/calendar_event.dart';

/// Base class for calendar management states
abstract class CalendarManagementState extends Equatable {
  const CalendarManagementState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CalendarManagementInitial extends CalendarManagementState {
  const CalendarManagementInitial();
}

/// Loading state
class CalendarManagementLoading extends CalendarManagementState {
  const CalendarManagementLoading();
}

/// State when calendar events are loaded
class CalendarEventsLoaded extends CalendarManagementState {
  const CalendarEventsLoaded({
    required this.events,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  final List<CalendarEvent> events;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  @override
  List<Object> get props => [
    events,
    totalCount,
    page,
    pageSize,
    totalPages,
    hasPreviousPage,
    hasNextPage,
  ];

  /// Create a copy with updated values
  CalendarEventsLoaded copyWith({
    List<CalendarEvent>? events,
    int? totalCount,
    int? page,
    int? pageSize,
    int? totalPages,
    bool? hasPreviousPage,
    bool? hasNextPage,
  }) {
    return CalendarEventsLoaded(
      events: events ?? this.events,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

/// State when a single calendar event is loaded
class CalendarEventLoaded extends CalendarManagementState {
  const CalendarEventLoaded(this.event);

  final CalendarEvent event;

  @override
  List<Object> get props => [event];
}

/// State when calendar event is created successfully
class CalendarEventCreatedSuccess extends CalendarManagementState {
  const CalendarEventCreatedSuccess(this.event);

  final CalendarEvent event;

  @override
  List<Object> get props => [event];
}

/// State when calendar event is updated successfully
class CalendarEventUpdatedSuccess extends CalendarManagementState {
  const CalendarEventUpdatedSuccess(this.event);

  final CalendarEvent event;

  @override
  List<Object> get props => [event];
}

/// State when calendar event is deleted successfully
class CalendarEventDeletedSuccess extends CalendarManagementState {
  const CalendarEventDeletedSuccess(this.eventId);

  final String eventId;

  @override
  List<Object> get props => [eventId];
}

/// State when project events are loaded
class ProjectEventsLoaded extends CalendarManagementState {
  const ProjectEventsLoaded({required this.projectId, required this.events});

  final String projectId;
  final List<CalendarEvent> events;

  @override
  List<Object> get props => [projectId, events];
}

/// State when task events are loaded
class TaskEventsLoaded extends CalendarManagementState {
  const TaskEventsLoaded({required this.taskId, required this.events});

  final String taskId;
  final List<CalendarEvent> events;

  @override
  List<Object> get props => [taskId, events];
}

/// State when user events are loaded
class UserEventsLoaded extends CalendarManagementState {
  const UserEventsLoaded({required this.userId, required this.events});

  final String userId;
  final List<CalendarEvent> events;

  @override
  List<Object> get props => [userId, events];
}

/// State when upcoming events are loaded
class UpcomingEventsLoaded extends CalendarManagementState {
  const UpcomingEventsLoaded(this.events);

  final List<CalendarEvent> events;

  @override
  List<Object> get props => [events];
}

/// State when conflict check is completed
class ConflictCheckCompleted extends CalendarManagementState {
  const ConflictCheckCompleted({
    required this.hasConflicts,
    required this.conflictingEvents,
  });

  final bool hasConflicts;
  final List<CalendarEvent> conflictingEvents;

  @override
  List<Object> get props => [hasConflicts, conflictingEvents];
}

/// State when search results are loaded
class CalendarSearchResultsLoaded extends CalendarManagementState {
  const CalendarSearchResultsLoaded({
    required this.query,
    required this.results,
  });

  final String query;
  final List<CalendarEvent> results;

  @override
  List<Object> get props => [query, results];
}

/// State when events are filtered by type
class EventsFilteredByTypeLoaded extends CalendarManagementState {
  const EventsFilteredByTypeLoaded({
    required this.eventType,
    required this.events,
  });

  final CalendarEventType eventType;
  final List<CalendarEvent> events;

  @override
  List<Object> get props => [eventType, events];
}

/// State when events are filtered by status
class EventsFilteredByStatusLoaded extends CalendarManagementState {
  const EventsFilteredByStatusLoaded({
    required this.status,
    required this.events,
  });

  final CalendarEventStatus status;
  final List<CalendarEvent> events;

  @override
  List<Object> get props => [status, events];
}

/// State when events are filtered by priority
class EventsFilteredByPriorityLoaded extends CalendarManagementState {
  const EventsFilteredByPriorityLoaded({
    required this.priority,
    required this.events,
  });

  final CalendarEventPriority priority;
  final List<CalendarEvent> events;

  @override
  List<Object> get props => [priority, events];
}

/// Error state
class CalendarManagementError extends CalendarManagementState {
  const CalendarManagementError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
