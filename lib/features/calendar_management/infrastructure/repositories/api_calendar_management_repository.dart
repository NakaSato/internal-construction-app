import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_management_repository.dart';
import '../models/calendar_event_model.dart';
import '../services/calendar_api_service.dart';

/// API-based implementation of CalendarManagementRepository
@LazySingleton(as: CalendarManagementRepository)
class ApiCalendarManagementRepository implements CalendarManagementRepository {
  ApiCalendarManagementRepository(this._apiService);

  final CalendarApiService _apiService;

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
    try {
      final response = await _apiService.getAllEvents(
        startDate: startDate?.toIso8601String(),
        endDate: endDate?.toIso8601String(),
        eventType: eventType?.name,
        status: status?.name,
        priority: priority?.name,
        isAllDay: isAllDay,
        isRecurring: isRecurring,
        projectId: projectId,
        taskId: taskId,
        createdByUserId: createdByUserId,
        assignedToUserId: assignedToUserId,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message);
      }

      return CalendarEventListResponse(
        events: response.data!.events.map((e) => e.toEntity()).toList(),
        totalCount: response.data!.totalCount,
        page: response.data!.page,
        pageSize: response.data!.pageSize,
        totalPages: response.data!.totalPages,
        hasPreviousPage: response.data!.hasPreviousPage,
        hasNextPage: response.data!.hasNextPage,
      );
    } on DioException catch (e) {
      throw Exception('Failed to get calendar events: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get calendar events: $e');
    }
  }

  @override
  Future<CalendarEvent?> getEventById(String eventId) async {
    try {
      final response = await _apiService.getEventById(eventId);

      if (!response.success) {
        if (response.errors.isNotEmpty) {
          throw Exception(response.errors.first);
        }
        throw Exception(response.message);
      }

      return response.data?.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to get calendar event: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get calendar event: $e');
    }
  }

  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    try {
      final request = CreateCalendarEventRequest.fromEntity(event);
      final response = await _apiService.createEvent(request);

      if (!response.success || response.data == null) {
        if (response.errors.isNotEmpty) {
          throw Exception(response.errors.first);
        }
        throw Exception(response.message);
      }

      return response.data!.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid event data');
      }
      throw Exception('Failed to create calendar event: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create calendar event: $e');
    }
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    try {
      final request = UpdateCalendarEventRequest(
        title: event.title,
        description: event.description,
        startDateTime: event.startDateTime,
        endDateTime: event.endDateTime,
        status: event.status.name,
        priority: event.priority.name,
        location: event.location,
        notes: event.notes,
        reminderMinutes: event.reminderMinutes,
        color: event.color,
      );

      final response = await _apiService.updateEvent(event.id, request);

      if (!response.success || response.data == null) {
        if (response.errors.isNotEmpty) {
          throw Exception(response.errors.first);
        }
        throw Exception(response.message);
      }

      return response.data!.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Calendar event not found');
      }
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid event data');
      }
      throw Exception('Failed to update calendar event: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update calendar event: $e');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      final response = await _apiService.deleteEvent(eventId);

      if (!response.success) {
        if (response.errors.isNotEmpty) {
          throw Exception(response.errors.first);
        }
        throw Exception(response.message);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Calendar event not found');
      }
      throw Exception('Failed to delete calendar event: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete calendar event: $e');
    }
  }

  @override
  Future<List<CalendarEvent>> getEventsByProject(
    String projectId, {
    DateTime? startDate,
    DateTime? endDate,
    CalendarEventType? eventType,
    CalendarEventStatus? status,
  }) async {
    try {
      final response = await _apiService.getEventsByProject(
        projectId,
        startDate: startDate?.toIso8601String(),
        endDate: endDate?.toIso8601String(),
        eventType: eventType?.name,
        status: status?.name,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message);
      }

      return response.data!.events.map((e) => e.toEntity()).toList();
    } on DioException catch (e) {
      throw Exception('Failed to get project events: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get project events: $e');
    }
  }

  @override
  Future<List<CalendarEvent>> getEventsByTask(String taskId) async {
    try {
      final response = await _apiService.getEventsByTask(taskId);

      if (!response.success || response.data == null) {
        throw Exception(response.message);
      }

      return response.data!.events.map((e) => e.toEntity()).toList();
    } on DioException catch (e) {
      throw Exception('Failed to get task events: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get task events: $e');
    }
  }

  @override
  Future<List<CalendarEvent>> getEventsByUser(String userId) async {
    try {
      final response = await _apiService.getEventsByUser(userId);

      if (!response.success || response.data == null) {
        throw Exception(response.message);
      }

      return response.data!.events.map((e) => e.toEntity()).toList();
    } on DioException catch (e) {
      throw Exception('Failed to get user events: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get user events: $e');
    }
  }

  @override
  Future<List<CalendarEvent>> getUpcomingEvents({
    int days = 7,
    String? userId,
  }) async {
    try {
      final response = await _apiService.getUpcomingEvents(
        days: days,
        userId: userId,
      );

      if (!response.success || response.data == null) {
        throw Exception(response.message);
      }

      return response.data!.events.map((e) => e.toEntity()).toList();
    } on DioException catch (e) {
      throw Exception('Failed to get upcoming events: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get upcoming events: $e');
    }
  }

  @override
  Future<ConflictCheckResponse> checkEventConflicts({
    required DateTime startDateTime,
    required DateTime endDateTime,
    required String userId,
    String? excludeEventId,
  }) async {
    try {
      final request = ConflictCheckRequest(
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        userId: userId,
        excludeEventId: excludeEventId,
      );

      final response = await _apiService.checkEventConflicts(request);

      if (!response.success || response.data == null) {
        throw Exception(response.message);
      }

      return ConflictCheckResponse(
        hasConflicts: response.data!.hasConflicts,
        conflictingEvents: response.data!.conflictingEvents
            .map((e) => e.toEntity())
            .toList(),
      );
    } on DioException catch (e) {
      throw Exception('Failed to check event conflicts: ${e.message}');
    } catch (e) {
      throw Exception('Failed to check event conflicts: $e');
    }
  }

  @override
  Future<List<CalendarEvent>> searchEvents(String query) async {
    try {
      // Use getAllEvents with search query (assuming API supports search in description/title)
      final response = await getAllEvents(pageSize: 100);

      // Filter events by query in title, description, or location
      final filtered = response.events.where((event) {
        final searchText = query.toLowerCase();
        return event.title.toLowerCase().contains(searchText) ||
            (event.description?.toLowerCase().contains(searchText) ?? false) ||
            (event.location?.toLowerCase().contains(searchText) ?? false);
      }).toList();

      return filtered;
    } catch (e) {
      throw Exception('Failed to search events: $e');
    }
  }
}
