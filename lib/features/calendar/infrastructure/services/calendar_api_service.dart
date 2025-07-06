import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/calendar_event_model.dart';

part 'calendar_api_service.g.dart';

/// API service for calendar management operations
@RestApi()
@injectable
abstract class CalendarApiService {
  @factoryMethod
  factory CalendarApiService(Dio dio, {String baseUrl}) = _CalendarApiService;

  /// Get all calendar events with filtering and pagination
  @GET('/api/v1/calendar')
  Future<CalendarEventListApiResponse> getAllEvents({
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
    @Query('eventType') String? eventType,
    @Query('status') String? status,
    @Query('priority') String? priority,
    @Query('isAllDay') bool? isAllDay,
    @Query('isRecurring') bool? isRecurring,
    @Query('projectId') String? projectId,
    @Query('taskId') String? taskId,
    @Query('createdByUserId') String? createdByUserId,
    @Query('assignedToUserId') String? assignedToUserId,
    @Query('pageNumber') int? pageNumber,
    @Query('pageSize') int? pageSize,
  });

  /// Get calendar event by ID
  @GET('/api/v1/calendar/{eventId}')
  Future<CalendarEventApiResponse> getEventById(
    @Path('eventId') String eventId,
  );

  /// Create a new calendar event
  @POST('/api/v1/calendar')
  Future<CalendarEventApiResponse> createEvent(
    @Body() CreateCalendarEventRequest request,
  );

  /// Update an existing calendar event
  @PUT('/api/v1/calendar/{eventId}')
  Future<CalendarEventApiResponse> updateEvent(
    @Path('eventId') String eventId,
    @Body() UpdateCalendarEventRequest request,
  );

  /// Delete a calendar event
  @DELETE('/api/v1/calendar/{eventId}')
  Future<CalendarEventApiResponse> deleteEvent(@Path('eventId') String eventId);

  /// Get events by project
  @GET('/api/v1/calendar/project/{projectId}')
  Future<CalendarEventListApiResponse> getEventsByProject(
    @Path('projectId') String projectId, {
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
    @Query('eventType') String? eventType,
    @Query('status') String? status,
  });

  /// Get events by task
  @GET('/api/v1/calendar/task/{taskId}')
  Future<CalendarEventListApiResponse> getEventsByTask(
    @Path('taskId') String taskId,
  );

  /// Get events by user
  @GET('/api/v1/calendar/user/{userId}')
  Future<CalendarEventListApiResponse> getEventsByUser(
    @Path('userId') String userId,
  );

  /// Get upcoming events
  @GET('/api/v1/calendar/upcoming')
  Future<CalendarEventListApiResponse> getUpcomingEvents({
    @Query('days') int? days,
    @Query('userId') String? userId,
  });

  /// Check event conflicts
  @POST('/api/v1/calendar/conflicts')
  Future<ConflictCheckApiResponse> checkEventConflicts(
    @Body() ConflictCheckRequest request,
  );
}
