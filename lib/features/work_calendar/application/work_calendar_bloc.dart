import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../domain/repositories/work_calendar_repository.dart';
import 'work_calendar_event.dart';
import 'work_calendar_state.dart';

/// BLoC for managing work calendar state and business logic
@injectable
class WorkCalendarBloc extends Bloc<WorkCalendarEvent, WorkCalendarState> {
  WorkCalendarBloc(this._repository) : super(const WorkCalendarInitial()) {
    on<CalendarEventsRequested>(_onCalendarEventsRequested);
    on<DayEventsRequested>(_onDayEventsRequested);
    on<WorkEventCreated>(_onWorkEventCreated);
    on<WorkEventUpdated>(_onWorkEventUpdated);
    on<WorkEventDeleted>(_onWorkEventDeleted);
    on<CalendarEventsSearched>(_onCalendarEventsSearched);
    on<UpcomingEventsRequested>(_onUpcomingEventsRequested);
    on<TodaysEventsRequested>(_onTodaysEventsRequested);
    on<EventsFilteredByType>(_onEventsFilteredByType);
    on<CalendarEventsExported>(_onCalendarEventsExported);
    on<CalendarViewChanged>(_onCalendarViewChanged);
    on<CalendarDateChanged>(_onCalendarDateChanged);
  }

  final WorkCalendarRepository _repository;

  /// Handle loading calendar events for a date range
  Future<void> _onCalendarEventsRequested(
    CalendarEventsRequested event,
    Emitter<WorkCalendarState> emit,
  ) async {
    emit(const WorkCalendarLoading());

    try {
      final events = await _repository.getEventsInRange(
        event.startDate,
        event.endDate,
      );

      emit(
        CalendarEventsLoaded(
          events: events,
          currentDate: event.startDate,
          viewType: CalendarViewType.month,
        ),
      );
    } catch (e) {
      emit(WorkCalendarError('Failed to load calendar events: $e'));
    }
  }

  /// Handle loading events for a specific day
  Future<void> _onDayEventsRequested(
    DayEventsRequested event,
    Emitter<WorkCalendarState> emit,
  ) async {
    emit(const WorkCalendarLoading());

    try {
      final events = await _repository.getEventsForDate(event.date);

      emit(DayEventsLoaded(date: event.date, events: events));
    } catch (e) {
      emit(WorkCalendarError('Failed to load day events: $e'));
    }
  }

  /// Handle creating a new work event
  Future<void> _onWorkEventCreated(
    WorkEventCreated event,
    Emitter<WorkCalendarState> emit,
  ) async {
    try {
      final createdEvent = await _repository.createEvent(event.event);

      emit(WorkEventCreatedSuccess(createdEvent));

      // Reload current events if in calendar view
      if (state is CalendarEventsLoaded) {
        final currentState = state as CalendarEventsLoaded;
        add(
          CalendarEventsRequested(
            startDate: currentState.currentDate,
            endDate: currentState.currentDate.add(const Duration(days: 30)),
          ),
        );
      }
    } catch (e) {
      emit(WorkCalendarError('Failed to create event: $e'));
    }
  }

  /// Handle updating an existing work event
  Future<void> _onWorkEventUpdated(
    WorkEventUpdated event,
    Emitter<WorkCalendarState> emit,
  ) async {
    try {
      final updatedEvent = await _repository.updateEvent(event.event);

      emit(WorkEventUpdatedSuccess(updatedEvent));

      // Reload current events if in calendar view
      if (state is CalendarEventsLoaded) {
        final currentState = state as CalendarEventsLoaded;
        add(
          CalendarEventsRequested(
            startDate: currentState.currentDate,
            endDate: currentState.currentDate.add(const Duration(days: 30)),
          ),
        );
      }
    } catch (e) {
      emit(WorkCalendarError('Failed to update event: $e'));
    }
  }

  /// Handle deleting a work event
  Future<void> _onWorkEventDeleted(
    WorkEventDeleted event,
    Emitter<WorkCalendarState> emit,
  ) async {
    try {
      await _repository.deleteEvent(event.eventId);

      emit(WorkEventDeletedSuccess(event.eventId));

      // Reload current events if in calendar view
      if (state is CalendarEventsLoaded) {
        final currentState = state as CalendarEventsLoaded;
        add(
          CalendarEventsRequested(
            startDate: currentState.currentDate,
            endDate: currentState.currentDate.add(const Duration(days: 30)),
          ),
        );
      }
    } catch (e) {
      emit(WorkCalendarError('Failed to delete event: $e'));
    }
  }

  /// Handle searching calendar events
  Future<void> _onCalendarEventsSearched(
    CalendarEventsSearched event,
    Emitter<WorkCalendarState> emit,
  ) async {
    emit(const WorkCalendarLoading());

    try {
      final results = await _repository.searchEvents(event.query);

      emit(CalendarSearchResultsLoaded(query: event.query, results: results));
    } catch (e) {
      emit(WorkCalendarError('Failed to search events: $e'));
    }
  }

  /// Handle loading upcoming events
  Future<void> _onUpcomingEventsRequested(
    UpcomingEventsRequested event,
    Emitter<WorkCalendarState> emit,
  ) async {
    emit(const WorkCalendarLoading());

    try {
      final events = await _repository.getUpcomingEvents();

      emit(UpcomingEventsLoaded(events));
    } catch (e) {
      emit(WorkCalendarError('Failed to load upcoming events: $e'));
    }
  }

  /// Handle loading today's events
  Future<void> _onTodaysEventsRequested(
    TodaysEventsRequested event,
    Emitter<WorkCalendarState> emit,
  ) async {
    emit(const WorkCalendarLoading());

    try {
      final events = await _repository.getTodaysEvents();

      emit(TodaysEventsLoaded(events));
    } catch (e) {
      emit(WorkCalendarError('Failed to load today\'s events: $e'));
    }
  }

  /// Handle filtering events by type
  Future<void> _onEventsFilteredByType(
    EventsFilteredByType event,
    Emitter<WorkCalendarState> emit,
  ) async {
    emit(const WorkCalendarLoading());

    try {
      final events = await _repository.getEventsByType(event.eventType);

      emit(
        EventsFilteredByTypeLoaded(eventType: event.eventType, events: events),
      );
    } catch (e) {
      emit(WorkCalendarError('Failed to filter events: $e'));
    }
  }

  /// Handle exporting calendar events
  Future<void> _onCalendarEventsExported(
    CalendarEventsExported event,
    Emitter<WorkCalendarState> emit,
  ) async {
    try {
      final exportedData = await _repository.exportEvents(event.events);

      emit(CalendarExportSuccess(exportedData));
    } catch (e) {
      emit(WorkCalendarError('Failed to export events: $e'));
    }
  }

  /// Handle changing calendar view
  Future<void> _onCalendarViewChanged(
    CalendarViewChanged event,
    Emitter<WorkCalendarState> emit,
  ) async {
    if (state is CalendarEventsLoaded) {
      final currentState = state as CalendarEventsLoaded;

      emit(currentState.copyWith(viewType: event.viewType));
    }
  }

  /// Handle changing calendar date
  Future<void> _onCalendarDateChanged(
    CalendarDateChanged event,
    Emitter<WorkCalendarState> emit,
  ) async {
    if (state is CalendarEventsLoaded) {
      // Load events for the new date range
      add(
        CalendarEventsRequested(
          startDate: event.date,
          endDate: event.date.add(const Duration(days: 30)),
        ),
      );
    }
  }
}
