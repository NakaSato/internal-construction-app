import 'package:dio/dio.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/api_response.dart';
import 'package:equatable/equatable.dart';

/// Data transfer object for calendar event information
class CalendarEventDto extends Equatable {
  const CalendarEventDto({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.eventType,
    required this.projectId,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.participants,
    this.isAllDay,
    this.reminders,
    this.recurrence,
    this.priority,
    this.status,
  });

  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String eventType;
  final String projectId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? location;
  final List<String>? participants;
  final bool? isAllDay;
  final List<int>? reminders; // Minutes before event
  final String? recurrence; // RRULE format
  final String? priority;
  final String? status;

  factory CalendarEventDto.fromJson(Map<String, dynamic> json) {
    return CalendarEventDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      eventType: json['event_type'] as String,
      projectId: json['project_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      location: json['location'] as String?,
      participants: (json['participants'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isAllDay: json['is_all_day'] as bool?,
      reminders: (json['reminders'] as List<dynamic>?)?.map((e) => e as int).toList(),
      recurrence: json['recurrence'] as String?,
      priority: json['priority'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'event_type': eventType,
      'project_id': projectId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (location != null) 'location': location,
      if (participants != null) 'participants': participants,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (reminders != null) 'reminders': reminders,
      if (recurrence != null) 'recurrence': recurrence,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
    };
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    startDate,
    endDate,
    eventType,
    projectId,
    createdAt,
    updatedAt,
    location,
    participants,
    isAllDay,
    reminders,
    recurrence,
    priority,
    status,
  ];
}

/// Request model for creating a new calendar event
class CreateCalendarEventRequest extends Equatable {
  const CreateCalendarEventRequest({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.eventType,
    required this.projectId,
    this.location,
    this.participants,
    this.isAllDay,
    this.reminders,
    this.recurrence,
    this.priority,
  });

  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String eventType;
  final String projectId;
  final String? location;
  final List<String>? participants;
  final bool? isAllDay;
  final List<int>? reminders;
  final String? recurrence;
  final String? priority;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'event_type': eventType,
      'project_id': projectId,
      if (location != null) 'location': location,
      if (participants != null) 'participants': participants,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (reminders != null) 'reminders': reminders,
      if (recurrence != null) 'recurrence': recurrence,
      if (priority != null) 'priority': priority,
    };
  }

  @override
  List<Object?> get props => [
    title,
    description,
    startDate,
    endDate,
    eventType,
    projectId,
    location,
    participants,
    isAllDay,
    reminders,
    recurrence,
    priority,
  ];
}

/// Request model for updating a calendar event
class UpdateCalendarEventRequest extends Equatable {
  const UpdateCalendarEventRequest({
    this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.eventType,
    this.location,
    this.participants,
    this.isAllDay,
    this.reminders,
    this.recurrence,
    this.priority,
    this.status,
  });

  final String? title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? eventType;
  final String? location;
  final List<String>? participants;
  final bool? isAllDay;
  final List<int>? reminders;
  final String? recurrence;
  final String? priority;
  final String? status;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (startDate != null) json['start_date'] = startDate!.toIso8601String();
    if (endDate != null) json['end_date'] = endDate!.toIso8601String();
    if (eventType != null) json['event_type'] = eventType;
    if (location != null) json['location'] = location;
    if (participants != null) json['participants'] = participants;
    if (isAllDay != null) json['is_all_day'] = isAllDay;
    if (reminders != null) json['reminders'] = reminders;
    if (recurrence != null) json['recurrence'] = recurrence;
    if (priority != null) json['priority'] = priority;
    if (status != null) json['status'] = status;
    return json;
  }

  @override
  List<Object?> get props => [
    title,
    description,
    startDate,
    endDate,
    eventType,
    location,
    participants,
    isAllDay,
    reminders,
    recurrence,
    priority,
    status,
  ];
}

/// API service class for calendar operations
class CalendarApiService {
  const CalendarApiService(this._apiClient);

  final ApiClient _apiClient;

  /// Get all calendar events with optional filtering
  Future<ApiResponse<List<CalendarEventDto>>> getCalendarEvents({
    String? projectId,
    DateTime? startDate,
    DateTime? endDate,
    String? eventType,
    String? status,
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (projectId != null) queryParams['project_id'] = projectId;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (eventType != null) queryParams['event_type'] = eventType;
      if (status != null) queryParams['status'] = status;
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _apiClient.get(ApiConfig.calendarEvents, queryParameters: queryParams);

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) =>
            (json as List<dynamic>).map((item) => CalendarEventDto.fromJson(item as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return _handleError<List<CalendarEventDto>>(e);
    }
  }

  /// Get a specific calendar event by ID
  Future<ApiResponse<CalendarEventDto>> getCalendarEvent(String eventId) async {
    try {
      final response = await _apiClient.get('${ApiConfig.calendarEvents}/$eventId');

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CalendarEventDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError<CalendarEventDto>(e);
    }
  }

  /// Create a new calendar event
  Future<ApiResponse<CalendarEventDto>> createCalendarEvent(CreateCalendarEventRequest request) async {
    try {
      final response = await _apiClient.post(ApiConfig.calendarEvents, data: request.toJson());

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CalendarEventDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError<CalendarEventDto>(e);
    }
  }

  /// Update an existing calendar event
  Future<ApiResponse<CalendarEventDto>> updateCalendarEvent(String eventId, UpdateCalendarEventRequest request) async {
    try {
      final response = await _apiClient.put('${ApiConfig.calendarEvents}/$eventId', data: request.toJson());

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CalendarEventDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError<CalendarEventDto>(e);
    }
  }

  /// Delete a calendar event
  Future<ApiResponse<void>> deleteCalendarEvent(String eventId) async {
    try {
      await _apiClient.delete('${ApiConfig.calendarEvents}/$eventId');
      return const ApiResponse(success: true, data: null);
    } catch (e) {
      return _handleError<void>(e);
    }
  }

  /// Get calendar events by project
  Future<ApiResponse<List<CalendarEventDto>>> getCalendarEventsByProject(
    String projectId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final response = await _apiClient.get('${ApiConfig.projects}/$projectId/calendar', queryParameters: queryParams);

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) =>
            (json as List<dynamic>).map((item) => CalendarEventDto.fromJson(item as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return _handleError<List<CalendarEventDto>>(e);
    }
  }

  /// Get today's calendar events
  Future<ApiResponse<List<CalendarEventDto>>> getTodayEvents() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return getCalendarEvents(startDate: startOfDay, endDate: endOfDay);
    } catch (e) {
      return _handleError<List<CalendarEventDto>>(e);
    }
  }

  /// Get upcoming calendar events
  Future<ApiResponse<List<CalendarEventDto>>> getUpcomingEvents({int days = 7}) async {
    try {
      final now = DateTime.now();
      final futureDate = now.add(Duration(days: days));

      return getCalendarEvents(startDate: now, endDate: futureDate);
    } catch (e) {
      return _handleError<List<CalendarEventDto>>(e);
    }
  }

  /// Update event status
  Future<ApiResponse<CalendarEventDto>> updateEventStatus(String eventId, String status) async {
    try {
      final response = await _apiClient.patch('${ApiConfig.calendarEvents}/$eventId/status', data: {'status': status});

      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CalendarEventDto.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      return _handleError<CalendarEventDto>(e);
    }
  }

  /// Generic error handler
  ApiResponse<T> _handleError<T>(dynamic error) {
    String message = 'An unexpected error occurred';

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Connection timeout. Please check your internet connection.';
          break;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;

          if (statusCode == 401) {
            message = 'Authentication required. Please log in again.';
          } else if (statusCode == 403) {
            message = 'Access denied. You don\'t have permission to perform this action.';
          } else if (statusCode == 404) {
            message = 'Calendar event not found.';
          } else if (statusCode == 422) {
            message = 'Invalid event data provided.';
          } else if (responseData is Map && responseData.containsKey('message')) {
            message = responseData['message'].toString();
          } else {
            message = 'Server error (${statusCode ?? 'unknown'})';
          }
          break;
        case DioExceptionType.cancel:
          message = 'Request was cancelled';
          break;
        case DioExceptionType.connectionError:
          message = 'Network error. Please check your internet connection.';
          break;
        case DioExceptionType.unknown:
          message = error.message ?? 'Unknown network error occurred';
          break;
        case DioExceptionType.badCertificate:
          message = 'Security certificate error';
          break;
      }
    }

    return ApiResponse<T>(success: false, message: message, data: null);
  }
}
