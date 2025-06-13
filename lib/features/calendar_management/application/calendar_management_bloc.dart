import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../domain/repositories/calendar_management_repository.dart';
import 'calendar_management_event.dart';
import 'calendar_management_state.dart';

/// BLoC for managing calendar management state and business logic
@injectable
class CalendarManagementBloc
    extends Bloc<CalendarManagementEvent, CalendarManagementState> {
  CalendarManagementBloc(this._repository)
    : super(const CalendarManagementInitial()) {
    on<CalendarEventsRequested>(_onCalendarEventsRequested);
    on<CalendarEventRequested>(_onCalendarEventRequested);
    on<CalendarEventCreated>(_onCalendarEventCreated);
    on<CalendarEventUpdated>(_onCalendarEventUpdated);
    on<CalendarEventDeleted>(_onCalendarEventDeleted);
    on<ProjectEventsRequested>(_onProjectEventsRequested);
    on<TaskEventsRequested>(_onTaskEventsRequested);
    on<UserEventsRequested>(_onUserEventsRequested);
    on<UpcomingEventsRequested>(_onUpcomingEventsRequested);
    on<ConflictCheckRequested>(_onConflictCheckRequested);
    on<CalendarEventsSearched>(_onCalendarEventsSearched);
    on<EventsFilteredByType>(_onEventsFilteredByType);
    on<EventsFilteredByStatus>(_onEventsFilteredByStatus);
    on<EventsFilteredByPriority>(_onEventsFilteredByPriority);
    on<CalendarManagementRefreshed>(_onCalendarManagementRefreshed);
  }

  final CalendarManagementRepository _repository;

  /// Handle loading calendar events with filtering and pagination
  Future<void> _onCalendarEventsRequested(
    CalendarEventsRequested event,
    Emitter<CalendarManagementState> emit,
  ) async {
    emit(const CalendarManagementLoading());

    try {
      final response = await _repository.getAllEvents(
        startDate: event.startDate,
        endDate: event.endDate,
        eventType: event.eventType,
        status: event.status,
        priority: event.priority,
        isAllDay: event.isAllDay,
        isRecurring: event.isRecurring,
        projectId: event.projectId,
        taskId: event.taskId,
        createdByUserId: event.createdByUserId,
        assignedToUserId: event.assignedToUserId,
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
      );

      emit(
        CalendarEventsLoaded(
          events: response.events,
          totalCount: response.totalCount,
          page: response.page,
          pageSize: response.pageSize,
          totalPages: response.totalPages,
          hasPreviousPage: response.hasPreviousPage,
          hasNextPage: response.hasNextPage,
        ),
      );
    } catch (e) {
      emit(CalendarManagementError('Failed to load calendar events: $e'));
    }
  }

  /// Handle loading a specific calendar event by ID
  Future<void> _onCalendarEventRequested(
    CalendarEventRequested event,
    Emitter<CalendarManagementState> emit,
  ) async {
    emit(const CalendarManagementLoading());

    try {
      final calendarEvent = await _repository.getEventById(event.eventId);

      if (calendarEvent != null) {
        emit(CalendarEventLoaded(calendarEvent));
      } else {
        emit(const CalendarManagementError('Calendar event not found'));
      }
    } catch (e) {
      emit(CalendarManagementError('Failed to load calendar event: $e'));
    }
  }

  /// Handle creating a new calendar event
  Future<void> _onCalendarEventCreated(
    CalendarEventCreated event,
    Emitter<CalendarManagementState> emit,
  ) async {
    try {
      final createdEvent = await _repository.createEvent(event.event);
      emit(CalendarEventCreatedSuccess(createdEvent));

      // Reload current events if in events view
      if (state is CalendarEventsLoaded) {
        add(const CalendarEventsRequested());
      }
    } catch (e) {
      emit(CalendarManagementError('Failed to create calendar event: $e'));
    }
  }

  /// Handle updating an existing calendar event
  Future<void> _onCalendarEventUpdated(
    CalendarEventUpdated event,
    Emitter<CalendarManagementState> emit,
  ) async {
    try {
      final updatedEvent = await _repository.updateEvent(event.event);
      emit(CalendarEventUpdatedSuccess(updatedEvent));

      // Reload current events if in events view
      if (state is CalendarEventsLoaded) {
        add(const CalendarEventsRequested());
      }
    } catch (e) {
      emit(CalendarManagementError('Failed to update calendar event: $e'));
    }
  }

  /// Handle deleting a calendar event
  Future<void> _onCalendarEventDeleted(
    CalendarEventDeleted event,
    Emitter<CalendarManagementState> emit,
  ) async {
    try {
      await _repository.deleteEvent(event.eventId);
      emit(CalendarEventDeletedSuccess(event.eventId));

      // Reload current events if in events view
      if (state is CalendarEventsLoaded) {
        add(const CalendarEventsRequested());
      }
    } catch (e) {
      emit(CalendarManagementError('Failed to delete calendar event: $e'));
    }
  }

  /// Handle loading events by project
  Future<void> _onProjectEventsRequested(
    ProjectEventsRequested event,
    Emitter<CalendarManagementState> emit,
  ) async {
    emit(const CalendarManagementLoading());

    try {
      final events = await _repository.getEventsByProject(
        event.projectId,
        startDate: event.startDate,
        endDate: event.endDate,
        eventType: event.eventType,
        status: event.status,
      );

      emit(ProjectEventsLoaded(projectId: event.projectId, events: events));
    } catch (e) {
      emit(CalendarManagementError('Failed to load project events: $e'));
    }
  }

  /// Handle loading events by task
  Future<void> _onTaskEventsRequested(
    TaskEventsRequested event,
    Emitter<CalendarManagementState> emit,
  ) async {
    emit(const CalendarManagementLoading());

    try {
      final events = await _repository.getEventsByTask(event.taskId);

      emit(TaskEventsLoaded(taskId: event.taskId, events: events));
    } catch (e) {
      emit(CalendarManagementError('Failed to load task events: $e'));
    }
  }

  /// Handle loading events by user
  Future<void> _onUserEventsRequested(
    UserEventsRequested event,
    Emitter<CalendarManagementState> emit,
  ) async {
    emit(const CalendarManagementLoading());

    try {
      final events = await _repository.getEventsByUser(event.userId);

      emit(UserEventsLoaded(userId: event.userId, events: events));
    } catch (e) {
      emit(CalendarManagementError('Failed to load user events: $e'));
    }
  }

  /// Handle loading upcoming events
  Future<void> _onUpcomingEventsRequested(
    UpcomingEventsRequested event,
    Emitter<CalendarManagementState> emit,
  ) async {
    emit(const CalendarManagementLoading());

    try {
      final events = await _repository.getUpcomingEvents(
        days: event.days,
        userId: event.userId,
      );

      emit(UpcomingEventsLoaded(events));
    } catch (e) {
      emit(CalendarManagementError('Failed to load upcoming events: $e'));
    }
  }

  /// Handle checking for event conflicts
  Future<void> _onConflictCheckRequested(
    ConflictCheckRequested event,
    Emitter<CalendarManagementState> emit,
  ) async {
    try {
      final response = await _repository.checkEventConflicts(
        startDateTime: event.startDateTime,
        endDateTime: event.endDateTime,
        userId: event.userId,
        excludeEventId: event.excludeEventId,
      );

      emit(
        ConflictCheckCompleted(
          hasConflicts: response.hasConflicts,
          conflictingEvents: response.conflictingEvents,
        ),
      );
    } catch (e) {
      emit(CalendarManagementError('Failed to check conflicts: $e'));
    }
  }

  /// Handle searching calendar events
  Future<void> _onCalendarEventsSearched(
    CalendarEventsSearched event,
    Emitter<CalendarManagementState> emit,
  ) async {
    emit(const CalendarManagementLoading());

    try {
      final results = await _repository.searchEvents(event.query);

      emit(CalendarSearchResultsLoaded(query: event.query, results: results));
    } catch (e) {
      emit(CalendarManagementError('Failed to search events: $e'));
    }
  }

  /// Handle filtering events by type
  Future<void> _onEventsFilteredByType(
    EventsFilteredByType event,
    Emitter<CalendarManagementState> emit,
  ) async {
    emit(const CalendarManagementLoading());

    try {
      final response = await _repository.getAllEvents(
        eventType: event.eventType,
        pageSize: 100,
      );

      emit(
        EventsFilteredByTypeLoaded(
          eventType: event.eventType,
          events: response.events,
        ),
      );
    } catch (e) {
      emit(CalendarManagementError('Failed to filter events by type: $e'));
    }
  }

  /// Handle filtering events by status
  Future<void> _onEventsFilteredByStatus(
    EventsFilteredByStatus event,
    Emitter<CalendarManagementState> emit,
  ) async {
    emit(const CalendarManagementLoading());

    try {
      final response = await _repository.getAllEvents(
        status: event.status,
        pageSize: 100,
      );

      emit(
        EventsFilteredByStatusLoaded(
          status: event.status,
          events: response.events,
        ),
      );
    } catch (e) {
      emit(CalendarManagementError('Failed to filter events by status: $e'));
    }
  }

  /// Handle filtering events by priority
  Future<void> _onEventsFilteredByPriority(
    EventsFilteredByPriority event,
    Emitter<CalendarManagementState> emit,
  ) async {
    emit(const CalendarManagementLoading());

    try {
      final response = await _repository.getAllEvents(
        priority: event.priority,
        pageSize: 100,
      );

      emit(
        EventsFilteredByPriorityLoaded(
          priority: event.priority,
          events: response.events,
        ),
      );
    } catch (e) {
      emit(CalendarManagementError('Failed to filter events by priority: $e'));
    }
  }

  /// Handle refreshing current view
  Future<void> _onCalendarManagementRefreshed(
    CalendarManagementRefreshed event,
    Emitter<CalendarManagementState> emit,
  ) async {
    if (state is CalendarEventsLoaded) {
      add(const CalendarEventsRequested());
    } else if (state is UpcomingEventsLoaded) {
      add(const UpcomingEventsRequested());
    }
  }
}
