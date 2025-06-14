import '../domain/entities/work_event.dart';
import '../domain/repositories/work_calendar_repository.dart';

/// Mock implementation of WorkCalendarRepository for development
class MockWorkCalendarRepository implements WorkCalendarRepository {
  @override
  Future<List<WorkEvent>> getEventsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Return mock events
    return [
      WorkEvent(
        id: 'mock-1',
        title: 'Daily Standup',
        description: 'Daily team standup meeting',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 1, minutes: 30)),
        isAllDay: false,
        color: '#2196F3',
        location: 'Conference Room B',
      ),
      WorkEvent(
        id: 'mock-2',
        title: 'Code Review',
        description: 'Review pull requests',
        startTime: DateTime.now().add(const Duration(hours: 3)),
        endTime: DateTime.now().add(const Duration(hours: 4)),
        isAllDay: false,
        color: '#4CAF50',
        location: 'Online',
      ),
      WorkEvent(
        id: 'mock-3',
        title: 'Project Planning',
        description: 'Plan upcoming sprint',
        startTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
        endTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
        isAllDay: false,
        color: '#FF9800',
        location: 'Meeting Room A',
      ),
    ];
  }

  @override
  Future<List<WorkEvent>> getEventsForDate(DateTime date) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    // Return mock events for the specific date
    return [
      WorkEvent(
        id: 'daily-1',
        title: 'Morning Check-in',
        description: 'Team morning check-in',
        startTime: DateTime(date.year, date.month, date.day, 9, 0),
        endTime: DateTime(date.year, date.month, date.day, 9, 30),
        isAllDay: false,
        color: '#9C27B0',
        location: 'Team Room',
      ),
    ];
  }

  @override
  Future<WorkEvent> createEvent(WorkEvent event) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    // Return the event with a mock ID
    return event.copyWith(id: 'mock-${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Future<WorkEvent> updateEvent(WorkEvent event) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Return the updated event
    return event;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    // Mock deletion - nothing to return
  }

  @override
  Future<WorkEvent?> getEvent(String eventId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));

    // Return a mock event or null
    if (eventId == 'mock-1') {
      return WorkEvent(
        id: eventId,
        title: 'Mock Event',
        description: 'This is a mock event',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        isAllDay: false,
        color: '#607D8B',
        location: 'Mock Location',
      );
    }
    return null;
  }

  @override
  Future<List<WorkEvent>> searchEvents(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Return mock search results
    return [
      WorkEvent(
        id: 'search-1',
        title: 'Search Result: $query',
        description: 'Mock search result for: $query',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        isAllDay: false,
        color: '#E91E63',
        location: 'Search Results',
      ),
    ];
  }

  @override
  Future<List<WorkEvent>> getUpcomingEvents() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));

    // Return mock upcoming events
    return [
      WorkEvent(
        id: 'upcoming-1',
        title: 'Upcoming Meeting',
        description: 'Next important meeting',
        startTime: DateTime.now().add(const Duration(hours: 2)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        isAllDay: false,
        color: '#FF5722',
        location: 'Main Conference Room',
      ),
    ];
  }

  @override
  Future<List<WorkEvent>> getEventsByType(WorkEventType eventType) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    // Return mock events by type
    return [
      WorkEvent(
        id: 'type-1',
        title: '${eventType.name} Event',
        description: 'Mock event of type: ${eventType.name}',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        isAllDay: false,
        color: '#795548',
        location: 'Type Specific Room',
      ),
    ];
  }

  @override
  Future<List<WorkEvent>> getTodaysEvents() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    final today = DateTime.now();
    return [
      WorkEvent(
        id: 'today-1',
        title: 'Today\'s Event',
        description: 'An event happening today',
        startTime: DateTime(today.year, today.month, today.day, 14, 0),
        endTime: DateTime(today.year, today.month, today.day, 15, 0),
        isAllDay: false,
        color: '#3F51B5',
        location: 'Today\'s Room',
      ),
    ];
  }

  @override
  Future<List<WorkEvent>> getWeekEvents(DateTime weekStart) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 250));

    return [
      WorkEvent(
        id: 'week-1',
        title: 'Weekly Meeting',
        description: 'This week\'s meeting',
        startTime: weekStart.add(const Duration(days: 1, hours: 10)),
        endTime: weekStart.add(const Duration(days: 1, hours: 11)),
        isAllDay: false,
        color: '#009688',
        location: 'Weekly Room',
      ),
    ];
  }

  @override
  Future<List<WorkEvent>> getMonthEvents(DateTime monthStart) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      WorkEvent(
        id: 'month-1',
        title: 'Monthly Review',
        description: 'Monthly progress review',
        startTime: monthStart.add(const Duration(days: 15, hours: 9)),
        endTime: monthStart.add(const Duration(days: 15, hours: 10)),
        isAllDay: false,
        color: '#FF6F00',
        location: 'Monthly Room',
      ),
    ];
  }

  @override
  Future<List<WorkEvent>> getConflictingEvents(
    DateTime startTime,
    DateTime endTime,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 150));

    // Mock conflict check - return empty list (no conflicts)
    return [];
  }

  @override
  Future<String> exportEvents(List<WorkEvent> events) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock export data
    return 'Mock exported ${events.length} events in iCal format';
  }
}
