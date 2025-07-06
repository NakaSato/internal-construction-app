import '../domain/entities/calendar_event.dart';
import '../domain/repositories/calendar_management_repository.dart';

/// Mock implementation of CalendarManagementRepository for development
class MockCalendarManagementRepository implements CalendarManagementRepository {
  @override
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
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock events
    final events = [
      CalendarEvent(
        id: '1',
        title: 'Team Meeting',
        description: 'Weekly team sync meeting',
        startDateTime: DateTime.now().add(const Duration(hours: 1)),
        endDateTime: DateTime.now().add(const Duration(hours: 2)),
        eventType: CalendarEventType.meeting,
        status: CalendarEventStatus.scheduled,
        priority: CalendarEventPriority.high,
        location: 'Conference Room A',
        isAllDay: false,
        isRecurring: false,
        reminderMinutes: 15,
        isPrivate: false,
        projectName: 'Flutter Architecture App',
        createdByUserName: 'John Doe',
        assignedToUserName: 'Jane Smith',
      ),
      CalendarEvent(
        id: '2',
        title: 'Project Deadline',
        description: 'Complete project deliverables',
        startDateTime: DateTime.now().add(const Duration(days: 3)),
        endDateTime: DateTime.now().add(const Duration(days: 3, hours: 8)),
        eventType: CalendarEventType.deadline,
        status: CalendarEventStatus.scheduled,
        priority: CalendarEventPriority.critical,
        isAllDay: true,
        isRecurring: false,
        reminderMinutes: 60,
        isPrivate: false,
        projectName: 'Flutter Architecture App',
        createdByUserName: 'John Doe',
      ),
      CalendarEvent(
        id: '3',
        title: 'Client Presentation',
        description: 'Quarterly business review with client',
        startDateTime: DateTime.now().add(const Duration(days: 7, hours: 10)),
        endDateTime: DateTime.now().add(const Duration(days: 7, hours: 12)),
        eventType: CalendarEventType.meeting,
        status: CalendarEventStatus.scheduled,
        priority: CalendarEventPriority.high,
        location: 'Client Office',
        isAllDay: false,
        isRecurring: false,
        reminderMinutes: 30,
        isPrivate: false,
        projectName: 'Client Project',
        createdByUserName: 'John Doe',
        assignedToUserName: 'Jane Smith',
      ),
    ];

    return CalendarEventListResponse(
      events: events,
      totalCount: events.length,
      page: pageNumber,
      pageSize: pageSize,
      totalPages: 1,
      hasPreviousPage: false,
      hasNextPage: false,
    );
  }

  @override
  Future<CalendarEvent?> getEventById(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return CalendarEvent(
      id: eventId,
      title: 'Sample Event',
      description: 'This is a sample event',
      startDateTime: DateTime.now().add(const Duration(hours: 1)),
      endDateTime: DateTime.now().add(const Duration(hours: 2)),
      eventType: CalendarEventType.meeting,
      status: CalendarEventStatus.scheduled,
      priority: CalendarEventPriority.medium,
      isAllDay: false,
      isRecurring: false,
    );
  }

  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return event.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    await Future.delayed(const Duration(milliseconds: 400));

    return event.copyWith(updatedAt: DateTime.now());
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock deletion - no actual work needed
  }

  @override
  Future<List<CalendarEvent>> getEventsByProject(
    String projectId, {
    DateTime? startDate,
    DateTime? endDate,
    CalendarEventType? eventType,
    CalendarEventStatus? status,
  }) async {
    final response = await getAllEvents(projectId: projectId);
    return response.events
        .where((event) => event.projectId == projectId)
        .toList();
  }

  @override
  Future<List<CalendarEvent>> getEventsByTask(String taskId) async {
    final response = await getAllEvents(taskId: taskId);
    return response.events.where((event) => event.taskId == taskId).toList();
  }

  @override
  Future<List<CalendarEvent>> getEventsByUser(String userId) async {
    final response = await getAllEvents(assignedToUserId: userId);
    return response.events
        .where(
          (event) =>
              event.assignedToUserId == userId ||
              event.createdByUserId == userId,
        )
        .toList();
  }

  @override
  Future<List<CalendarEvent>> getUpcomingEvents({
    int days = 7,
    String? userId,
  }) async {
    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: days));
    final response = await getAllEvents(
      startDate: startDate,
      endDate: endDate,
      assignedToUserId: userId,
    );
    return response.events;
  }

  @override
  Future<List<CalendarEvent>> searchEvents(String query) async {
    final response = await getAllEvents();
    return response.events
        .where(
          (event) =>
              event.title.toLowerCase().contains(query.toLowerCase()) ||
              (event.description?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .toList();
  }

  @override
  Future<ConflictCheckResponse> checkEventConflicts({
    required DateTime startDateTime,
    required DateTime endDateTime,
    required String userId,
    String? excludeEventId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Mock conflict check - always return no conflicts
    return const ConflictCheckResponse(
      hasConflicts: false,
      conflictingEvents: [],
    );
  }
}
