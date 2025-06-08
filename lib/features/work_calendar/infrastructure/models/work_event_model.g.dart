// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkEventModelImpl _$$WorkEventModelImplFromJson(Map<String, dynamic> json) =>
    _$WorkEventModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      description: json['description'] as String?,
      location: json['location'] as String?,
      color: json['color'] as String?,
      isAllDay: json['isAllDay'] as bool? ?? false,
      eventType:
          $enumDecodeNullable(_$WorkEventTypeEnumMap, json['eventType']) ??
          WorkEventType.meeting,
      attendees:
          (json['attendees'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$WorkEventModelImplToJson(
  _$WorkEventModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'description': instance.description,
  'location': instance.location,
  'color': instance.color,
  'isAllDay': instance.isAllDay,
  'eventType': _$WorkEventTypeEnumMap[instance.eventType]!,
  'attendees': instance.attendees,
};

const _$WorkEventTypeEnumMap = {
  WorkEventType.meeting: 'meeting',
  WorkEventType.appointment: 'appointment',
  WorkEventType.task: 'task',
  WorkEventType.reminder: 'reminder',
  WorkEventType.break_: 'break_',
  WorkEventType.travel: 'travel',
  WorkEventType.training: 'training',
  WorkEventType.conference: 'conference',
  WorkEventType.other: 'other',
};
