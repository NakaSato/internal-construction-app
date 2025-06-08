import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/work_event.dart';
import '../../domain/repositories/work_calendar_repository.dart';

/// API-based implementation of WorkCalendarRepository
@LazySingleton(as: WorkCalendarRepository)
class ApiWorkCalendarRepository implements WorkCalendarRepository {
  ApiWorkCalendarRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<WorkEvent>> getEventsInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _dio.get(
        '/api/calendar/events',
        queryParameters: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      return (response.data['events'] as List<dynamic>)
          .map((eventData) => _mapToWorkEvent(eventData))
          .toList();
    } catch (e) {
      throw Exception('Failed to get events in range: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getEventsForDate(DateTime date) async {
    try {
      final response = await _dio.get(
        '/api/calendar/events/date',
        queryParameters: {'date': date.toIso8601String()},
      );

      return (response.data['events'] as List<dynamic>)
          .map((eventData) => _mapToWorkEvent(eventData))
          .toList();
    } catch (e) {
      throw Exception('Failed to get events for date: $e');
    }
  }

  @override
  Future<WorkEvent> createEvent(WorkEvent event) async {
    try {
      final data = _mapFromWorkEvent(event);
      final response = await _dio.post('/api/calendar/events', data: data);

      return _mapToWorkEvent(response.data);
    } catch (e) {
      throw Exception('Failed to create event: $e');
    }
  }

  @override
  Future<WorkEvent> updateEvent(WorkEvent event) async {
    try {
      final data = _mapFromWorkEvent(event);
      final response = await _dio.put(
        '/api/calendar/events/${event.id}',
        data: data,
      );

      return _mapToWorkEvent(response.data);
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _dio.delete('/api/calendar/events/$eventId');
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  @override
  Future<WorkEvent?> getEvent(String eventId) async {
    try {
      final response = await _dio.get('/api/calendar/events/$eventId');

      if (response.statusCode == 404) {
        return null;
      }

      return _mapToWorkEvent(response.data);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to get event: $e');
    }
  }

  @override
  Future<List<WorkEvent>> searchEvents(String query) async {
    try {
      final response = await _dio.get(
        '/api/calendar/events/search',
        queryParameters: {'query': query},
      );

      return (response.data['events'] as List<dynamic>)
          .map((eventData) => _mapToWorkEvent(eventData))
          .toList();
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getUpcomingEvents() async {
    try {
      final response = await _dio.get('/api/calendar/events/upcoming');

      return (response.data['events'] as List<dynamic>)
          .map((eventData) => _mapToWorkEvent(eventData))
          .toList();
    } catch (e) {
      throw Exception('Failed to get upcoming events: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getEventsByType(WorkEventType eventType) async {
    try {
      final response = await _dio.get(
        '/api/calendar/events/type',
        queryParameters: {'type': eventType.name},
      );

      return (response.data['events'] as List<dynamic>)
          .map((eventData) => _mapToWorkEvent(eventData))
          .toList();
    } catch (e) {
      throw Exception('Failed to get events by type: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getTodaysEvents() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return getEventsInRange(startOfDay, endOfDay);
    } catch (e) {
      throw Exception('Failed to get today\'s events: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getWeekEvents(DateTime weekStart) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 7));
      return getEventsInRange(weekStart, weekEnd);
    } catch (e) {
      throw Exception('Failed to get week events: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getMonthEvents(DateTime monthStart) async {
    try {
      final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 1);
      return getEventsInRange(monthStart, monthEnd);
    } catch (e) {
      throw Exception('Failed to get month events: $e');
    }
  }

  @override
  Future<List<WorkEvent>> getConflictingEvents(
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final response = await _dio.get(
        '/api/calendar/events/conflicts',
        queryParameters: {
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
        },
      );

      return (response.data['events'] as List<dynamic>)
          .map((eventData) => _mapToWorkEvent(eventData))
          .toList();
    } catch (e) {
      throw Exception('Failed to get conflicting events: $e');
    }
  }

  @override
  Future<String> exportEvents(List<WorkEvent> events) async {
    try {
      final data = {
        'events': events.map((event) => _mapFromWorkEvent(event)).toList(),
      };

      final response = await _dio.post(
        '/api/calendar/events/export',
        data: data,
      );

      return response.data['exportData'] as String;
    } catch (e) {
      throw Exception('Failed to export events: $e');
    }
  }

  /// Helper method to map API data to WorkEvent
  WorkEvent _mapToWorkEvent(Map<String, dynamic> eventData) {
    return WorkEvent(
      id: eventData['id'] as String,
      title: eventData['title'] as String,
      startTime: DateTime.parse(eventData['startTime'] as String),
      endTime: DateTime.parse(eventData['endTime'] as String),
      description: eventData['description'] as String?,
      location: eventData['location'] as String?,
      color: eventData['color'] as String?,
      isAllDay: eventData['isAllDay'] as bool? ?? false,
      eventType: _parseEventType(eventData['eventType'] as String?),
      attendees:
          (eventData['attendees'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  /// Helper method to map WorkEvent to API data
  Map<String, dynamic> _mapFromWorkEvent(WorkEvent event) {
    return {
      'id': event.id,
      'title': event.title,
      'startTime': event.startTime.toIso8601String(),
      'endTime': event.endTime.toIso8601String(),
      'description': event.description,
      'location': event.location,
      'color': event.color,
      'isAllDay': event.isAllDay,
      'eventType': event.eventType.name,
      'attendees': event.attendees,
    };
  }

  /// Helper method to parse event type from string
  WorkEventType _parseEventType(String? typeString) {
    if (typeString == null) return WorkEventType.other;

    try {
      return WorkEventType.values.firstWhere(
        (type) => type.name == typeString,
        orElse: () => WorkEventType.other,
      );
    } catch (e) {
      return WorkEventType.other;
    }
  }
}
