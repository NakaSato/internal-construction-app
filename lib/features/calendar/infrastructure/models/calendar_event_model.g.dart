// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CalendarEventModelImpl _$$CalendarEventModelImplFromJson(
  Map<String, dynamic> json,
) => _$CalendarEventModelImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  startDateTime: DateTime.parse(json['startDateTime'] as String),
  endDateTime: DateTime.parse(json['endDateTime'] as String),
  isAllDay: json['isAllDay'] as bool? ?? false,
  eventType: (json['eventType'] as num).toInt(),
  eventTypeName: json['eventTypeName'] as String?,
  status: (json['status'] as num).toInt(),
  statusName: json['statusName'] as String?,
  priority: (json['priority'] as num).toInt(),
  priorityName: json['priorityName'] as String?,
  location: json['location'] as String?,
  projectId: json['projectId'] as String?,
  projectName: json['projectName'] as String?,
  taskId: json['taskId'] as String?,
  taskName: json['taskName'] as String?,
  createdByUserId: json['createdByUserId'] as String?,
  createdByUserName: json['createdByUserName'] as String?,
  assignedToUserId: json['assignedToUserId'] as String?,
  assignedToUserName: json['assignedToUserName'] as String?,
  isRecurring: json['isRecurring'] as bool? ?? false,
  recurrencePattern: json['recurrencePattern'] as String?,
  recurrenceEndDate: json['recurrenceEndDate'] == null
      ? null
      : DateTime.parse(json['recurrenceEndDate'] as String),
  reminderMinutes: (json['reminderMinutes'] as num?)?.toInt() ?? 15,
  isPrivate: json['isPrivate'] as bool? ?? false,
  meetingUrl: json['meetingUrl'] as String?,
  attendees: (json['attendees'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  notes: json['notes'] as String?,
  color: json['color'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$CalendarEventModelImplToJson(
  _$CalendarEventModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'startDateTime': instance.startDateTime.toIso8601String(),
  'endDateTime': instance.endDateTime.toIso8601String(),
  'isAllDay': instance.isAllDay,
  'eventType': instance.eventType,
  'eventTypeName': instance.eventTypeName,
  'status': instance.status,
  'statusName': instance.statusName,
  'priority': instance.priority,
  'priorityName': instance.priorityName,
  'location': instance.location,
  'projectId': instance.projectId,
  'projectName': instance.projectName,
  'taskId': instance.taskId,
  'taskName': instance.taskName,
  'createdByUserId': instance.createdByUserId,
  'createdByUserName': instance.createdByUserName,
  'assignedToUserId': instance.assignedToUserId,
  'assignedToUserName': instance.assignedToUserName,
  'isRecurring': instance.isRecurring,
  'recurrencePattern': instance.recurrencePattern,
  'recurrenceEndDate': instance.recurrenceEndDate?.toIso8601String(),
  'reminderMinutes': instance.reminderMinutes,
  'isPrivate': instance.isPrivate,
  'meetingUrl': instance.meetingUrl,
  'attendees': instance.attendees,
  'notes': instance.notes,
  'color': instance.color,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_$CalendarEventApiResponseImpl _$$CalendarEventApiResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CalendarEventApiResponseImpl(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : CalendarEventModel.fromJson(json['data'] as Map<String, dynamic>),
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  error: json['error'] as String?,
);

Map<String, dynamic> _$$CalendarEventApiResponseImplToJson(
  _$CalendarEventApiResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
  'error': instance.error,
};

_$CalendarEventListApiResponseImpl _$$CalendarEventListApiResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CalendarEventListApiResponseImpl(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : CalendarEventListData.fromJson(json['data'] as Map<String, dynamic>),
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  error: json['error'] as String?,
);

Map<String, dynamic> _$$CalendarEventListApiResponseImplToJson(
  _$CalendarEventListApiResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
  'error': instance.error,
};

_$CalendarEventListDataImpl _$$CalendarEventListDataImplFromJson(
  Map<String, dynamic> json,
) => _$CalendarEventListDataImpl(
  events: (json['events'] as List<dynamic>)
      .map((e) => CalendarEventModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalCount: (json['totalCount'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  pageSize: (json['pageSize'] as num).toInt(),
  totalPages: (json['totalPages'] as num).toInt(),
  hasPreviousPage: json['hasPreviousPage'] as bool,
  hasNextPage: json['hasNextPage'] as bool,
);

Map<String, dynamic> _$$CalendarEventListDataImplToJson(
  _$CalendarEventListDataImpl instance,
) => <String, dynamic>{
  'events': instance.events,
  'totalCount': instance.totalCount,
  'page': instance.page,
  'pageSize': instance.pageSize,
  'totalPages': instance.totalPages,
  'hasPreviousPage': instance.hasPreviousPage,
  'hasNextPage': instance.hasNextPage,
};

_$ConflictCheckApiResponseImpl _$$ConflictCheckApiResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ConflictCheckApiResponseImpl(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : ConflictCheckData.fromJson(json['data'] as Map<String, dynamic>),
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$ConflictCheckApiResponseImplToJson(
  _$ConflictCheckApiResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
};

_$ConflictCheckDataImpl _$$ConflictCheckDataImplFromJson(
  Map<String, dynamic> json,
) => _$ConflictCheckDataImpl(
  hasConflicts: json['hasConflicts'] as bool,
  conflictingEvents: (json['conflictingEvents'] as List<dynamic>)
      .map((e) => CalendarEventModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$ConflictCheckDataImplToJson(
  _$ConflictCheckDataImpl instance,
) => <String, dynamic>{
  'hasConflicts': instance.hasConflicts,
  'conflictingEvents': instance.conflictingEvents,
};

_$CreateCalendarEventRequestImpl _$$CreateCalendarEventRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateCalendarEventRequestImpl(
  title: json['title'] as String,
  description: json['description'] as String?,
  startDateTime: DateTime.parse(json['startDateTime'] as String),
  endDateTime: DateTime.parse(json['endDateTime'] as String),
  eventType: json['eventType'] as String,
  status: json['status'] as String,
  priority: json['priority'] as String,
  location: json['location'] as String?,
  isAllDay: json['isAllDay'] as bool? ?? false,
  isRecurring: json['isRecurring'] as bool? ?? false,
  notes: json['notes'] as String?,
  reminderMinutes: (json['reminderMinutes'] as num?)?.toInt() ?? 15,
  projectId: json['projectId'] as String?,
  taskId: json['taskId'] as String?,
  assignedToUserId: json['assignedToUserId'] as String?,
  color: json['color'] as String?,
  isPrivate: json['isPrivate'] as bool? ?? false,
  attendees: (json['attendees'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$$CreateCalendarEventRequestImplToJson(
  _$CreateCalendarEventRequestImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'startDateTime': instance.startDateTime.toIso8601String(),
  'endDateTime': instance.endDateTime.toIso8601String(),
  'eventType': instance.eventType,
  'status': instance.status,
  'priority': instance.priority,
  'location': instance.location,
  'isAllDay': instance.isAllDay,
  'isRecurring': instance.isRecurring,
  'notes': instance.notes,
  'reminderMinutes': instance.reminderMinutes,
  'projectId': instance.projectId,
  'taskId': instance.taskId,
  'assignedToUserId': instance.assignedToUserId,
  'color': instance.color,
  'isPrivate': instance.isPrivate,
  'attendees': instance.attendees,
};

_$UpdateCalendarEventRequestImpl _$$UpdateCalendarEventRequestImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateCalendarEventRequestImpl(
  title: json['title'] as String?,
  description: json['description'] as String?,
  startDateTime: json['startDateTime'] == null
      ? null
      : DateTime.parse(json['startDateTime'] as String),
  endDateTime: json['endDateTime'] == null
      ? null
      : DateTime.parse(json['endDateTime'] as String),
  status: json['status'] as String?,
  priority: json['priority'] as String?,
  location: json['location'] as String?,
  notes: json['notes'] as String?,
  reminderMinutes: (json['reminderMinutes'] as num?)?.toInt(),
  color: json['color'] as String?,
);

Map<String, dynamic> _$$UpdateCalendarEventRequestImplToJson(
  _$UpdateCalendarEventRequestImpl instance,
) => <String, dynamic>{
  'title': instance.title,
  'description': instance.description,
  'startDateTime': instance.startDateTime?.toIso8601String(),
  'endDateTime': instance.endDateTime?.toIso8601String(),
  'status': instance.status,
  'priority': instance.priority,
  'location': instance.location,
  'notes': instance.notes,
  'reminderMinutes': instance.reminderMinutes,
  'color': instance.color,
};

_$ConflictCheckRequestImpl _$$ConflictCheckRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ConflictCheckRequestImpl(
  startDateTime: DateTime.parse(json['startDateTime'] as String),
  endDateTime: DateTime.parse(json['endDateTime'] as String),
  userId: json['userId'] as String,
  excludeEventId: json['excludeEventId'] as String?,
);

Map<String, dynamic> _$$ConflictCheckRequestImplToJson(
  _$ConflictCheckRequestImpl instance,
) => <String, dynamic>{
  'startDateTime': instance.startDateTime.toIso8601String(),
  'endDateTime': instance.endDateTime.toIso8601String(),
  'userId': instance.userId,
  'excludeEventId': instance.excludeEventId,
};
