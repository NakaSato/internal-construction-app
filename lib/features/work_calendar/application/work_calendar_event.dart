import 'package:equatable/equatable.dart';

import '../domain/entities/work_event.dart';

/// Base class for work calendar events
abstract class WorkCalendarEvent extends Equatable {
  const WorkCalendarEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load calendar events for a date range
class CalendarEventsRequested extends WorkCalendarEvent {
  const CalendarEventsRequested({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object> get props => [startDate, endDate];
}

/// Event to load events for a specific date
class DayEventsRequested extends WorkCalendarEvent {
  const DayEventsRequested(this.date);

  final DateTime date;

  @override
  List<Object> get props => [date];
}

/// Event to create a new work event
class WorkEventCreated extends WorkCalendarEvent {
  const WorkEventCreated(this.event);

  final WorkEvent event;

  @override
  List<Object> get props => [event];
}

/// Event to update an existing work event
class WorkEventUpdated extends WorkCalendarEvent {
  const WorkEventUpdated(this.event);

  final WorkEvent event;

  @override
  List<Object> get props => [event];
}

/// Event to delete a work event
class WorkEventDeleted extends WorkCalendarEvent {
  const WorkEventDeleted(this.eventId);

  final String eventId;

  @override
  List<Object> get props => [eventId];
}

/// Event to search for events
class CalendarEventsSearched extends WorkCalendarEvent {
  const CalendarEventsSearched(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

/// Event to load upcoming events
class UpcomingEventsRequested extends WorkCalendarEvent {
  const UpcomingEventsRequested();
}

/// Event to load today's events
class TodaysEventsRequested extends WorkCalendarEvent {
  const TodaysEventsRequested();
}

/// Event to filter events by type
class EventsFilteredByType extends WorkCalendarEvent {
  const EventsFilteredByType(this.eventType);

  final WorkEventType eventType;

  @override
  List<Object> get props => [eventType];
}

/// Event to export calendar events
class CalendarEventsExported extends WorkCalendarEvent {
  const CalendarEventsExported(this.events);

  final List<WorkEvent> events;

  @override
  List<Object> get props => [events];
}

/// Event to change calendar view
class CalendarViewChanged extends WorkCalendarEvent {
  const CalendarViewChanged(this.viewType);

  final CalendarViewType viewType;

  @override
  List<Object> get props => [viewType];
}

/// Event to navigate to a specific date
class CalendarDateChanged extends WorkCalendarEvent {
  const CalendarDateChanged(this.date);

  final DateTime date;

  @override
  List<Object> get props => [date];
}

/// Types of calendar views
enum CalendarViewType { day, week, month, agenda }
