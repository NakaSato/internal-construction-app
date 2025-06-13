import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/calendar_event.dart';

part 'calendar_event_model.freezed.dart';
part 'calendar_event_model.g.dart';

/// Data model for CalendarEvent entity
@freezed
class CalendarEventModel with _$CalendarEventModel {
  const factory CalendarEventModel({
    required String id,
    required String title,
    String? description,
    required DateTime startDateTime,
    required DateTime endDateTime,
    @Default(false) bool isAllDay,
    required int eventType,
    String? eventTypeName,
    required int status,
    String? statusName,
    required int priority,
    String? priorityName,
    String? location,
    String? projectId,
    String? projectName,
    String? taskId,
    String? taskName,
    String? createdByUserId,
    String? createdByUserName,
    String? assignedToUserId,
    String? assignedToUserName,
    @Default(false) bool isRecurring,
    String? recurrencePattern,
    DateTime? recurrenceEndDate,
    @Default(15) int reminderMinutes,
    @Default(false) bool isPrivate,
    String? meetingUrl,
    String? attendees,
    String? notes,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CalendarEventModel;

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventModelFromJson(json);

  /// Create model from domain entity
  factory CalendarEventModel.fromEntity(CalendarEvent entity) {
    return CalendarEventModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      startDateTime: entity.startDateTime,
      endDateTime: entity.endDateTime,
      isAllDay: entity.isAllDay,
      eventType: entity.eventType.value,
      eventTypeName: entity.eventType.displayName,
      status: entity.status.value,
      statusName: entity.status.displayName,
      priority: entity.priority.value,
      priorityName: entity.priority.displayName,
      location: entity.location,
      projectId: entity.projectId,
      projectName: entity.projectName,
      taskId: entity.taskId,
      taskName: entity.taskName,
      createdByUserId: entity.createdByUserId,
      createdByUserName: entity.createdByUserName,
      assignedToUserId: entity.assignedToUserId,
      assignedToUserName: entity.assignedToUserName,
      isRecurring: entity.isRecurring,
      recurrencePattern: entity.recurrencePattern,
      recurrenceEndDate: entity.recurrenceEndDate,
      reminderMinutes: entity.reminderMinutes,
      isPrivate: entity.isPrivate,
      meetingUrl: entity.meetingUrl,
      attendees: entity.attendees,
      notes: entity.notes,
      color: entity.color,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

/// Extension to convert between model and entity
extension CalendarEventModelX on CalendarEventModel {
  /// Convert model to domain entity
  CalendarEvent toEntity() {
    return CalendarEvent(
      id: id,
      title: title,
      description: description,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
      isAllDay: isAllDay,
      eventType: CalendarEventType.fromValue(eventType),
      status: CalendarEventStatus.fromValue(status),
      priority: CalendarEventPriority.fromValue(priority),
      location: location,
      projectId: projectId,
      projectName: projectName,
      taskId: taskId,
      taskName: taskName,
      createdByUserId: createdByUserId,
      createdByUserName: createdByUserName,
      assignedToUserId: assignedToUserId,
      assignedToUserName: assignedToUserName,
      isRecurring: isRecurring,
      recurrencePattern: recurrencePattern,
      recurrenceEndDate: recurrenceEndDate,
      reminderMinutes: reminderMinutes,
      isPrivate: isPrivate,
      meetingUrl: meetingUrl,
      attendees: attendees,
      notes: notes,
      color: color,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Extension to convert from entity to model
extension CalendarEventX on CalendarEvent {
  /// Convert domain entity to model
  CalendarEventModel toModel() {
    return CalendarEventModel.fromEntity(this);
  }
}

/// API Response models
@freezed
class CalendarEventApiResponse with _$CalendarEventApiResponse {
  const factory CalendarEventApiResponse({
    required bool success,
    required String message,
    CalendarEventModel? data,
    @Default([]) List<String> errors,
    String? error,
  }) = _CalendarEventApiResponse;

  factory CalendarEventApiResponse.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventApiResponseFromJson(json);
}

@freezed
class CalendarEventListApiResponse with _$CalendarEventListApiResponse {
  const factory CalendarEventListApiResponse({
    required bool success,
    required String message,
    CalendarEventListData? data,
    @Default([]) List<String> errors,
    String? error,
  }) = _CalendarEventListApiResponse;

  factory CalendarEventListApiResponse.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventListApiResponseFromJson(json);
}

@freezed
class CalendarEventListData with _$CalendarEventListData {
  const factory CalendarEventListData({
    required List<CalendarEventModel> events,
    required int totalCount,
    required int page,
    required int pageSize,
    required int totalPages,
    required bool hasPreviousPage,
    required bool hasNextPage,
  }) = _CalendarEventListData;

  factory CalendarEventListData.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventListDataFromJson(json);
}

@freezed
class ConflictCheckApiResponse with _$ConflictCheckApiResponse {
  const factory ConflictCheckApiResponse({
    required bool success,
    required String message,
    ConflictCheckData? data,
    @Default([]) List<String> errors,
  }) = _ConflictCheckApiResponse;

  factory ConflictCheckApiResponse.fromJson(Map<String, dynamic> json) =>
      _$ConflictCheckApiResponseFromJson(json);
}

@freezed
class ConflictCheckData with _$ConflictCheckData {
  const factory ConflictCheckData({
    required bool hasConflicts,
    required List<CalendarEventModel> conflictingEvents,
  }) = _ConflictCheckData;

  factory ConflictCheckData.fromJson(Map<String, dynamic> json) =>
      _$ConflictCheckDataFromJson(json);
}

/// Request models
@freezed
class CreateCalendarEventRequest with _$CreateCalendarEventRequest {
  const factory CreateCalendarEventRequest({
    required String title,
    String? description,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required String eventType,
    required String status,
    required String priority,
    String? location,
    @Default(false) bool isAllDay,
    @Default(false) bool isRecurring,
    String? notes,
    @Default(15) int reminderMinutes,
    String? projectId,
    String? taskId,
    String? assignedToUserId,
    String? color,
    @Default(false) bool isPrivate,
    String? attendees,
  }) = _CreateCalendarEventRequest;

  factory CreateCalendarEventRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCalendarEventRequestFromJson(json);

  /// Create request from domain entity
  factory CreateCalendarEventRequest.fromEntity(CalendarEvent entity) {
    return CreateCalendarEventRequest(
      title: entity.title,
      description: entity.description,
      startDateTime: entity.startDateTime,
      endDateTime: entity.endDateTime,
      eventType: entity.eventType.name.toLowerCase(),
      status: entity.status.name.toLowerCase(),
      priority: entity.priority.name.toLowerCase(),
      location: entity.location,
      isAllDay: entity.isAllDay,
      isRecurring: entity.isRecurring,
      notes: entity.notes,
      reminderMinutes: entity.reminderMinutes,
      projectId: entity.projectId,
      taskId: entity.taskId,
      assignedToUserId: entity.assignedToUserId,
      color: entity.color,
      isPrivate: entity.isPrivate,
      attendees: entity.attendees,
    );
  }
}

@freezed
class UpdateCalendarEventRequest with _$UpdateCalendarEventRequest {
  const factory UpdateCalendarEventRequest({
    String? title,
    String? description,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? status,
    String? priority,
    String? location,
    String? notes,
    int? reminderMinutes,
    String? color,
  }) = _UpdateCalendarEventRequest;

  factory UpdateCalendarEventRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCalendarEventRequestFromJson(json);
}

@freezed
class ConflictCheckRequest with _$ConflictCheckRequest {
  const factory ConflictCheckRequest({
    required DateTime startDateTime,
    required DateTime endDateTime,
    required String userId,
    String? excludeEventId,
  }) = _ConflictCheckRequest;

  factory ConflictCheckRequest.fromJson(Map<String, dynamic> json) =>
      _$ConflictCheckRequestFromJson(json);
}
