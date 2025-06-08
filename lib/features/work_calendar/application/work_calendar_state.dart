import 'package:equatable/equatable.dart';

import '../domain/entities/work_event.dart';
import 'work_calendar_event.dart';

/// Base class for work calendar states
abstract class WorkCalendarState extends Equatable {
  const WorkCalendarState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class WorkCalendarInitial extends WorkCalendarState {
  const WorkCalendarInitial();
}

/// Loading state
class WorkCalendarLoading extends WorkCalendarState {
  const WorkCalendarLoading({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Calendar events loaded state
class CalendarEventsLoaded extends WorkCalendarState {
  const CalendarEventsLoaded({
    required this.events,
    required this.currentDate,
    required this.viewType,
  });

  final List<WorkEvent> events;
  final DateTime currentDate;
  final CalendarViewType viewType;

  @override
  List<Object> get props => [events, currentDate, viewType];

  /// Copy with method for immutable updates
  CalendarEventsLoaded copyWith({
    List<WorkEvent>? events,
    DateTime? currentDate,
    CalendarViewType? viewType,
  }) {
    return CalendarEventsLoaded(
      events: events ?? this.events,
      currentDate: currentDate ?? this.currentDate,
      viewType: viewType ?? this.viewType,
    );
  }
}

/// Day events loaded state
class DayEventsLoaded extends WorkCalendarState {
  const DayEventsLoaded({required this.date, required this.events});

  final DateTime date;
  final List<WorkEvent> events;

  @override
  List<Object> get props => [date, events];
}

/// Event created successfully state
class WorkEventCreatedSuccess extends WorkCalendarState {
  const WorkEventCreatedSuccess(this.event);

  final WorkEvent event;

  @override
  List<Object> get props => [event];
}

/// Event updated successfully state
class WorkEventUpdatedSuccess extends WorkCalendarState {
  const WorkEventUpdatedSuccess(this.event);

  final WorkEvent event;

  @override
  List<Object> get props => [event];
}

/// Event deleted successfully state
class WorkEventDeletedSuccess extends WorkCalendarState {
  const WorkEventDeletedSuccess(this.eventId);

  final String eventId;

  @override
  List<Object> get props => [eventId];
}

/// Search results loaded state
class CalendarSearchResultsLoaded extends WorkCalendarState {
  const CalendarSearchResultsLoaded({
    required this.query,
    required this.results,
  });

  final String query;
  final List<WorkEvent> results;

  @override
  List<Object> get props => [query, results];
}

/// Upcoming events loaded state
class UpcomingEventsLoaded extends WorkCalendarState {
  const UpcomingEventsLoaded(this.events);

  final List<WorkEvent> events;

  @override
  List<Object> get props => [events];
}

/// Today's events loaded state
class TodaysEventsLoaded extends WorkCalendarState {
  const TodaysEventsLoaded(this.events);

  final List<WorkEvent> events;

  @override
  List<Object> get props => [events];
}

/// Events filtered by type state
class EventsFilteredByTypeLoaded extends WorkCalendarState {
  const EventsFilteredByTypeLoaded({
    required this.eventType,
    required this.events,
  });

  final WorkEventType eventType;
  final List<WorkEvent> events;

  @override
  List<Object> get props => [eventType, events];
}

/// Calendar export success state
class CalendarExportSuccess extends WorkCalendarState {
  const CalendarExportSuccess(this.exportedData);

  final String exportedData;

  @override
  List<Object> get props => [exportedData];
}

/// Error state
class WorkCalendarError extends WorkCalendarState {
  const WorkCalendarError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
