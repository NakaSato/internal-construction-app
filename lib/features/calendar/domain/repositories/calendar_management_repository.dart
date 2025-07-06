import '../entities/calendar_event.dart';

/// Repository interface for calendar management operations
abstract class CalendarManagementRepository {
  /// Get all calendar events with filtering and pagination
  Future<CalendarEventListResponse> getAllEvents({
    DateTime? startDate,
    DateTime? endDate,
    CalendarEventType? eventType,
    CalendarEventStatus? status,
    CalendarEventPriority? priority,
    bool? isAllDay,
    bool? isRecurring,
    String? projectId,
    String? taskId,
    String? createdByUserId,
    String? assignedToUserId,
    int pageNumber = 1,
    int pageSize = 10,
  });

  /// Get calendar event by ID
  Future<CalendarEvent?> getEventById(String eventId);

  /// Create a new calendar event
  Future<CalendarEvent> createEvent(CalendarEvent event);

  /// Update an existing calendar event
  Future<CalendarEvent> updateEvent(CalendarEvent event);

  /// Delete a calendar event
  Future<void> deleteEvent(String eventId);

  /// Get events by project
  Future<List<CalendarEvent>> getEventsByProject(
    String projectId, {
    DateTime? startDate,
    DateTime? endDate,
    CalendarEventType? eventType,
    CalendarEventStatus? status,
  });

  /// Get events by task
  Future<List<CalendarEvent>> getEventsByTask(String taskId);

  /// Get events by user
  Future<List<CalendarEvent>> getEventsByUser(String userId);

  /// Get upcoming events
  Future<List<CalendarEvent>> getUpcomingEvents({int days = 7, String? userId});

  /// Check for event conflicts
  Future<ConflictCheckResponse> checkEventConflicts({
    required DateTime startDateTime,
    required DateTime endDateTime,
    required String userId,
    String? excludeEventId,
  });

  /// Search events
  Future<List<CalendarEvent>> searchEvents(String query);
}

/// Response model for calendar event list with pagination
class CalendarEventListResponse {
  const CalendarEventListResponse({
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
}

/// Response model for conflict checking
class ConflictCheckResponse {
  const ConflictCheckResponse({
    required this.hasConflicts,
    required this.conflictingEvents,
  });

  final bool hasConflicts;
  final List<CalendarEvent> conflictingEvents;
}
