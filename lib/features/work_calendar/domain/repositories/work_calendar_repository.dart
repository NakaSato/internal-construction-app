import '../entities/work_event.dart';

/// Repository interface for work calendar operations
abstract class WorkCalendarRepository {
  /// Get all work events for a date range
  Future<List<WorkEvent>> getEventsInRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get events for a specific date
  Future<List<WorkEvent>> getEventsForDate(DateTime date);

  /// Create a new work event
  Future<WorkEvent> createEvent(WorkEvent event);

  /// Update an existing work event
  Future<WorkEvent> updateEvent(WorkEvent event);

  /// Delete a work event
  Future<void> deleteEvent(String eventId);

  /// Get a specific event by ID
  Future<WorkEvent?> getEvent(String eventId);

  /// Search events by title or description
  Future<List<WorkEvent>> searchEvents(String query);

  /// Get upcoming events (next 7 days)
  Future<List<WorkEvent>> getUpcomingEvents();

  /// Get events by type
  Future<List<WorkEvent>> getEventsByType(WorkEventType eventType);

  /// Get today's events
  Future<List<WorkEvent>> getTodaysEvents();

  /// Get events for the current week
  Future<List<WorkEvent>> getWeekEvents(DateTime weekStart);

  /// Get events for the current month
  Future<List<WorkEvent>> getMonthEvents(DateTime monthStart);

  /// Check for event conflicts with a given time range
  Future<List<WorkEvent>> getConflictingEvents(
    DateTime startTime,
    DateTime endTime,
  );

  /// Export events to calendar format (e.g., iCal)
  Future<String> exportEvents(List<WorkEvent> events);
}
