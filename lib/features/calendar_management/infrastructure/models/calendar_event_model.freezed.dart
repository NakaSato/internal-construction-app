// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calendar_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CalendarEventModel _$CalendarEventModelFromJson(Map<String, dynamic> json) {
  return _CalendarEventModel.fromJson(json);
}

/// @nodoc
mixin _$CalendarEventModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime get startDateTime => throw _privateConstructorUsedError;
  DateTime get endDateTime => throw _privateConstructorUsedError;
  bool get isAllDay => throw _privateConstructorUsedError;
  int get eventType => throw _privateConstructorUsedError;
  String? get eventTypeName => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;
  String? get statusName => throw _privateConstructorUsedError;
  int get priority => throw _privateConstructorUsedError;
  String? get priorityName => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get projectId => throw _privateConstructorUsedError;
  String? get projectName => throw _privateConstructorUsedError;
  String? get taskId => throw _privateConstructorUsedError;
  String? get taskName => throw _privateConstructorUsedError;
  String? get createdByUserId => throw _privateConstructorUsedError;
  String? get createdByUserName => throw _privateConstructorUsedError;
  String? get assignedToUserId => throw _privateConstructorUsedError;
  String? get assignedToUserName => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;
  String? get recurrencePattern => throw _privateConstructorUsedError;
  DateTime? get recurrenceEndDate => throw _privateConstructorUsedError;
  int get reminderMinutes => throw _privateConstructorUsedError;
  bool get isPrivate => throw _privateConstructorUsedError;
  String? get meetingUrl => throw _privateConstructorUsedError;
  String? get attendees => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CalendarEventModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalendarEventModelCopyWith<CalendarEventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEventModelCopyWith<$Res> {
  factory $CalendarEventModelCopyWith(
    CalendarEventModel value,
    $Res Function(CalendarEventModel) then,
  ) = _$CalendarEventModelCopyWithImpl<$Res, CalendarEventModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    DateTime startDateTime,
    DateTime endDateTime,
    bool isAllDay,
    int eventType,
    String? eventTypeName,
    int status,
    String? statusName,
    int priority,
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
    bool isRecurring,
    String? recurrencePattern,
    DateTime? recurrenceEndDate,
    int reminderMinutes,
    bool isPrivate,
    String? meetingUrl,
    String? attendees,
    String? notes,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$CalendarEventModelCopyWithImpl<$Res, $Val extends CalendarEventModel>
    implements $CalendarEventModelCopyWith<$Res> {
  _$CalendarEventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? startDateTime = null,
    Object? endDateTime = null,
    Object? isAllDay = null,
    Object? eventType = null,
    Object? eventTypeName = freezed,
    Object? status = null,
    Object? statusName = freezed,
    Object? priority = null,
    Object? priorityName = freezed,
    Object? location = freezed,
    Object? projectId = freezed,
    Object? projectName = freezed,
    Object? taskId = freezed,
    Object? taskName = freezed,
    Object? createdByUserId = freezed,
    Object? createdByUserName = freezed,
    Object? assignedToUserId = freezed,
    Object? assignedToUserName = freezed,
    Object? isRecurring = null,
    Object? recurrencePattern = freezed,
    Object? recurrenceEndDate = freezed,
    Object? reminderMinutes = null,
    Object? isPrivate = null,
    Object? meetingUrl = freezed,
    Object? attendees = freezed,
    Object? notes = freezed,
    Object? color = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            startDateTime: null == startDateTime
                ? _value.startDateTime
                : startDateTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDateTime: null == endDateTime
                ? _value.endDateTime
                : endDateTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isAllDay: null == isAllDay
                ? _value.isAllDay
                : isAllDay // ignore: cast_nullable_to_non_nullable
                      as bool,
            eventType: null == eventType
                ? _value.eventType
                : eventType // ignore: cast_nullable_to_non_nullable
                      as int,
            eventTypeName: freezed == eventTypeName
                ? _value.eventTypeName
                : eventTypeName // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as int,
            statusName: freezed == statusName
                ? _value.statusName
                : statusName // ignore: cast_nullable_to_non_nullable
                      as String?,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as int,
            priorityName: freezed == priorityName
                ? _value.priorityName
                : priorityName // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            projectId: freezed == projectId
                ? _value.projectId
                : projectId // ignore: cast_nullable_to_non_nullable
                      as String?,
            projectName: freezed == projectName
                ? _value.projectName
                : projectName // ignore: cast_nullable_to_non_nullable
                      as String?,
            taskId: freezed == taskId
                ? _value.taskId
                : taskId // ignore: cast_nullable_to_non_nullable
                      as String?,
            taskName: freezed == taskName
                ? _value.taskName
                : taskName // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdByUserId: freezed == createdByUserId
                ? _value.createdByUserId
                : createdByUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdByUserName: freezed == createdByUserName
                ? _value.createdByUserName
                : createdByUserName // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedToUserId: freezed == assignedToUserId
                ? _value.assignedToUserId
                : assignedToUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedToUserName: freezed == assignedToUserName
                ? _value.assignedToUserName
                : assignedToUserName // ignore: cast_nullable_to_non_nullable
                      as String?,
            isRecurring: null == isRecurring
                ? _value.isRecurring
                : isRecurring // ignore: cast_nullable_to_non_nullable
                      as bool,
            recurrencePattern: freezed == recurrencePattern
                ? _value.recurrencePattern
                : recurrencePattern // ignore: cast_nullable_to_non_nullable
                      as String?,
            recurrenceEndDate: freezed == recurrenceEndDate
                ? _value.recurrenceEndDate
                : recurrenceEndDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            reminderMinutes: null == reminderMinutes
                ? _value.reminderMinutes
                : reminderMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            isPrivate: null == isPrivate
                ? _value.isPrivate
                : isPrivate // ignore: cast_nullable_to_non_nullable
                      as bool,
            meetingUrl: freezed == meetingUrl
                ? _value.meetingUrl
                : meetingUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            attendees: freezed == attendees
                ? _value.attendees
                : attendees // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CalendarEventModelImplCopyWith<$Res>
    implements $CalendarEventModelCopyWith<$Res> {
  factory _$$CalendarEventModelImplCopyWith(
    _$CalendarEventModelImpl value,
    $Res Function(_$CalendarEventModelImpl) then,
  ) = __$$CalendarEventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    DateTime startDateTime,
    DateTime endDateTime,
    bool isAllDay,
    int eventType,
    String? eventTypeName,
    int status,
    String? statusName,
    int priority,
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
    bool isRecurring,
    String? recurrencePattern,
    DateTime? recurrenceEndDate,
    int reminderMinutes,
    bool isPrivate,
    String? meetingUrl,
    String? attendees,
    String? notes,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$CalendarEventModelImplCopyWithImpl<$Res>
    extends _$CalendarEventModelCopyWithImpl<$Res, _$CalendarEventModelImpl>
    implements _$$CalendarEventModelImplCopyWith<$Res> {
  __$$CalendarEventModelImplCopyWithImpl(
    _$CalendarEventModelImpl _value,
    $Res Function(_$CalendarEventModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? startDateTime = null,
    Object? endDateTime = null,
    Object? isAllDay = null,
    Object? eventType = null,
    Object? eventTypeName = freezed,
    Object? status = null,
    Object? statusName = freezed,
    Object? priority = null,
    Object? priorityName = freezed,
    Object? location = freezed,
    Object? projectId = freezed,
    Object? projectName = freezed,
    Object? taskId = freezed,
    Object? taskName = freezed,
    Object? createdByUserId = freezed,
    Object? createdByUserName = freezed,
    Object? assignedToUserId = freezed,
    Object? assignedToUserName = freezed,
    Object? isRecurring = null,
    Object? recurrencePattern = freezed,
    Object? recurrenceEndDate = freezed,
    Object? reminderMinutes = null,
    Object? isPrivate = null,
    Object? meetingUrl = freezed,
    Object? attendees = freezed,
    Object? notes = freezed,
    Object? color = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$CalendarEventModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDateTime: null == startDateTime
            ? _value.startDateTime
            : startDateTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDateTime: null == endDateTime
            ? _value.endDateTime
            : endDateTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isAllDay: null == isAllDay
            ? _value.isAllDay
            : isAllDay // ignore: cast_nullable_to_non_nullable
                  as bool,
        eventType: null == eventType
            ? _value.eventType
            : eventType // ignore: cast_nullable_to_non_nullable
                  as int,
        eventTypeName: freezed == eventTypeName
            ? _value.eventTypeName
            : eventTypeName // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as int,
        statusName: freezed == statusName
            ? _value.statusName
            : statusName // ignore: cast_nullable_to_non_nullable
                  as String?,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as int,
        priorityName: freezed == priorityName
            ? _value.priorityName
            : priorityName // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        projectId: freezed == projectId
            ? _value.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as String?,
        projectName: freezed == projectName
            ? _value.projectName
            : projectName // ignore: cast_nullable_to_non_nullable
                  as String?,
        taskId: freezed == taskId
            ? _value.taskId
            : taskId // ignore: cast_nullable_to_non_nullable
                  as String?,
        taskName: freezed == taskName
            ? _value.taskName
            : taskName // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdByUserId: freezed == createdByUserId
            ? _value.createdByUserId
            : createdByUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdByUserName: freezed == createdByUserName
            ? _value.createdByUserName
            : createdByUserName // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedToUserId: freezed == assignedToUserId
            ? _value.assignedToUserId
            : assignedToUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedToUserName: freezed == assignedToUserName
            ? _value.assignedToUserName
            : assignedToUserName // ignore: cast_nullable_to_non_nullable
                  as String?,
        isRecurring: null == isRecurring
            ? _value.isRecurring
            : isRecurring // ignore: cast_nullable_to_non_nullable
                  as bool,
        recurrencePattern: freezed == recurrencePattern
            ? _value.recurrencePattern
            : recurrencePattern // ignore: cast_nullable_to_non_nullable
                  as String?,
        recurrenceEndDate: freezed == recurrenceEndDate
            ? _value.recurrenceEndDate
            : recurrenceEndDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        reminderMinutes: null == reminderMinutes
            ? _value.reminderMinutes
            : reminderMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        isPrivate: null == isPrivate
            ? _value.isPrivate
            : isPrivate // ignore: cast_nullable_to_non_nullable
                  as bool,
        meetingUrl: freezed == meetingUrl
            ? _value.meetingUrl
            : meetingUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        attendees: freezed == attendees
            ? _value.attendees
            : attendees // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarEventModelImpl implements _CalendarEventModel {
  const _$CalendarEventModelImpl({
    required this.id,
    required this.title,
    this.description,
    required this.startDateTime,
    required this.endDateTime,
    this.isAllDay = false,
    required this.eventType,
    this.eventTypeName,
    required this.status,
    this.statusName,
    required this.priority,
    this.priorityName,
    this.location,
    this.projectId,
    this.projectName,
    this.taskId,
    this.taskName,
    this.createdByUserId,
    this.createdByUserName,
    this.assignedToUserId,
    this.assignedToUserName,
    this.isRecurring = false,
    this.recurrencePattern,
    this.recurrenceEndDate,
    this.reminderMinutes = 15,
    this.isPrivate = false,
    this.meetingUrl,
    this.attendees,
    this.notes,
    this.color,
    this.createdAt,
    this.updatedAt,
  });

  factory _$CalendarEventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarEventModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final DateTime startDateTime;
  @override
  final DateTime endDateTime;
  @override
  @JsonKey()
  final bool isAllDay;
  @override
  final int eventType;
  @override
  final String? eventTypeName;
  @override
  final int status;
  @override
  final String? statusName;
  @override
  final int priority;
  @override
  final String? priorityName;
  @override
  final String? location;
  @override
  final String? projectId;
  @override
  final String? projectName;
  @override
  final String? taskId;
  @override
  final String? taskName;
  @override
  final String? createdByUserId;
  @override
  final String? createdByUserName;
  @override
  final String? assignedToUserId;
  @override
  final String? assignedToUserName;
  @override
  @JsonKey()
  final bool isRecurring;
  @override
  final String? recurrencePattern;
  @override
  final DateTime? recurrenceEndDate;
  @override
  @JsonKey()
  final int reminderMinutes;
  @override
  @JsonKey()
  final bool isPrivate;
  @override
  final String? meetingUrl;
  @override
  final String? attendees;
  @override
  final String? notes;
  @override
  final String? color;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'CalendarEventModel(id: $id, title: $title, description: $description, startDateTime: $startDateTime, endDateTime: $endDateTime, isAllDay: $isAllDay, eventType: $eventType, eventTypeName: $eventTypeName, status: $status, statusName: $statusName, priority: $priority, priorityName: $priorityName, location: $location, projectId: $projectId, projectName: $projectName, taskId: $taskId, taskName: $taskName, createdByUserId: $createdByUserId, createdByUserName: $createdByUserName, assignedToUserId: $assignedToUserId, assignedToUserName: $assignedToUserName, isRecurring: $isRecurring, recurrencePattern: $recurrencePattern, recurrenceEndDate: $recurrenceEndDate, reminderMinutes: $reminderMinutes, isPrivate: $isPrivate, meetingUrl: $meetingUrl, attendees: $attendees, notes: $notes, color: $color, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarEventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startDateTime, startDateTime) ||
                other.startDateTime == startDateTime) &&
            (identical(other.endDateTime, endDateTime) ||
                other.endDateTime == endDateTime) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.eventTypeName, eventTypeName) ||
                other.eventTypeName == eventTypeName) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusName, statusName) ||
                other.statusName == statusName) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.priorityName, priorityName) ||
                other.priorityName == priorityName) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.projectName, projectName) ||
                other.projectName == projectName) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.taskName, taskName) ||
                other.taskName == taskName) &&
            (identical(other.createdByUserId, createdByUserId) ||
                other.createdByUserId == createdByUserId) &&
            (identical(other.createdByUserName, createdByUserName) ||
                other.createdByUserName == createdByUserName) &&
            (identical(other.assignedToUserId, assignedToUserId) ||
                other.assignedToUserId == assignedToUserId) &&
            (identical(other.assignedToUserName, assignedToUserName) ||
                other.assignedToUserName == assignedToUserName) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.recurrencePattern, recurrencePattern) ||
                other.recurrencePattern == recurrencePattern) &&
            (identical(other.recurrenceEndDate, recurrenceEndDate) ||
                other.recurrenceEndDate == recurrenceEndDate) &&
            (identical(other.reminderMinutes, reminderMinutes) ||
                other.reminderMinutes == reminderMinutes) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(other.meetingUrl, meetingUrl) ||
                other.meetingUrl == meetingUrl) &&
            (identical(other.attendees, attendees) ||
                other.attendees == attendees) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    description,
    startDateTime,
    endDateTime,
    isAllDay,
    eventType,
    eventTypeName,
    status,
    statusName,
    priority,
    priorityName,
    location,
    projectId,
    projectName,
    taskId,
    taskName,
    createdByUserId,
    createdByUserName,
    assignedToUserId,
    assignedToUserName,
    isRecurring,
    recurrencePattern,
    recurrenceEndDate,
    reminderMinutes,
    isPrivate,
    meetingUrl,
    attendees,
    notes,
    color,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarEventModelImplCopyWith<_$CalendarEventModelImpl> get copyWith =>
      __$$CalendarEventModelImplCopyWithImpl<_$CalendarEventModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarEventModelImplToJson(this);
  }
}

abstract class _CalendarEventModel implements CalendarEventModel {
  const factory _CalendarEventModel({
    required final String id,
    required final String title,
    final String? description,
    required final DateTime startDateTime,
    required final DateTime endDateTime,
    final bool isAllDay,
    required final int eventType,
    final String? eventTypeName,
    required final int status,
    final String? statusName,
    required final int priority,
    final String? priorityName,
    final String? location,
    final String? projectId,
    final String? projectName,
    final String? taskId,
    final String? taskName,
    final String? createdByUserId,
    final String? createdByUserName,
    final String? assignedToUserId,
    final String? assignedToUserName,
    final bool isRecurring,
    final String? recurrencePattern,
    final DateTime? recurrenceEndDate,
    final int reminderMinutes,
    final bool isPrivate,
    final String? meetingUrl,
    final String? attendees,
    final String? notes,
    final String? color,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$CalendarEventModelImpl;

  factory _CalendarEventModel.fromJson(Map<String, dynamic> json) =
      _$CalendarEventModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  DateTime get startDateTime;
  @override
  DateTime get endDateTime;
  @override
  bool get isAllDay;
  @override
  int get eventType;
  @override
  String? get eventTypeName;
  @override
  int get status;
  @override
  String? get statusName;
  @override
  int get priority;
  @override
  String? get priorityName;
  @override
  String? get location;
  @override
  String? get projectId;
  @override
  String? get projectName;
  @override
  String? get taskId;
  @override
  String? get taskName;
  @override
  String? get createdByUserId;
  @override
  String? get createdByUserName;
  @override
  String? get assignedToUserId;
  @override
  String? get assignedToUserName;
  @override
  bool get isRecurring;
  @override
  String? get recurrencePattern;
  @override
  DateTime? get recurrenceEndDate;
  @override
  int get reminderMinutes;
  @override
  bool get isPrivate;
  @override
  String? get meetingUrl;
  @override
  String? get attendees;
  @override
  String? get notes;
  @override
  String? get color;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of CalendarEventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalendarEventModelImplCopyWith<_$CalendarEventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CalendarEventApiResponse _$CalendarEventApiResponseFromJson(
  Map<String, dynamic> json,
) {
  return _CalendarEventApiResponse.fromJson(json);
}

/// @nodoc
mixin _$CalendarEventApiResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  CalendarEventModel? get data => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this CalendarEventApiResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalendarEventApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalendarEventApiResponseCopyWith<CalendarEventApiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEventApiResponseCopyWith<$Res> {
  factory $CalendarEventApiResponseCopyWith(
    CalendarEventApiResponse value,
    $Res Function(CalendarEventApiResponse) then,
  ) = _$CalendarEventApiResponseCopyWithImpl<$Res, CalendarEventApiResponse>;
  @useResult
  $Res call({
    bool success,
    String message,
    CalendarEventModel? data,
    List<String> errors,
    String? error,
  });

  $CalendarEventModelCopyWith<$Res>? get data;
}

/// @nodoc
class _$CalendarEventApiResponseCopyWithImpl<
  $Res,
  $Val extends CalendarEventApiResponse
>
    implements $CalendarEventApiResponseCopyWith<$Res> {
  _$CalendarEventApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalendarEventApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = freezed,
    Object? errors = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as CalendarEventModel?,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of CalendarEventApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CalendarEventModelCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $CalendarEventModelCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CalendarEventApiResponseImplCopyWith<$Res>
    implements $CalendarEventApiResponseCopyWith<$Res> {
  factory _$$CalendarEventApiResponseImplCopyWith(
    _$CalendarEventApiResponseImpl value,
    $Res Function(_$CalendarEventApiResponseImpl) then,
  ) = __$$CalendarEventApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    String message,
    CalendarEventModel? data,
    List<String> errors,
    String? error,
  });

  @override
  $CalendarEventModelCopyWith<$Res>? get data;
}

/// @nodoc
class __$$CalendarEventApiResponseImplCopyWithImpl<$Res>
    extends
        _$CalendarEventApiResponseCopyWithImpl<
          $Res,
          _$CalendarEventApiResponseImpl
        >
    implements _$$CalendarEventApiResponseImplCopyWith<$Res> {
  __$$CalendarEventApiResponseImplCopyWithImpl(
    _$CalendarEventApiResponseImpl _value,
    $Res Function(_$CalendarEventApiResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CalendarEventApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = freezed,
    Object? errors = null,
    Object? error = freezed,
  }) {
    return _then(
      _$CalendarEventApiResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as CalendarEventModel?,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarEventApiResponseImpl implements _CalendarEventApiResponse {
  const _$CalendarEventApiResponseImpl({
    required this.success,
    required this.message,
    this.data,
    final List<String> errors = const [],
    this.error,
  }) : _errors = errors;

  factory _$CalendarEventApiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarEventApiResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final CalendarEventModel? data;
  final List<String> _errors;
  @override
  @JsonKey()
  List<String> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  @override
  final String? error;

  @override
  String toString() {
    return 'CalendarEventApiResponse(success: $success, message: $message, data: $data, errors: $errors, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarEventApiResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    message,
    data,
    const DeepCollectionEquality().hash(_errors),
    error,
  );

  /// Create a copy of CalendarEventApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarEventApiResponseImplCopyWith<_$CalendarEventApiResponseImpl>
  get copyWith =>
      __$$CalendarEventApiResponseImplCopyWithImpl<
        _$CalendarEventApiResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarEventApiResponseImplToJson(this);
  }
}

abstract class _CalendarEventApiResponse implements CalendarEventApiResponse {
  const factory _CalendarEventApiResponse({
    required final bool success,
    required final String message,
    final CalendarEventModel? data,
    final List<String> errors,
    final String? error,
  }) = _$CalendarEventApiResponseImpl;

  factory _CalendarEventApiResponse.fromJson(Map<String, dynamic> json) =
      _$CalendarEventApiResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  CalendarEventModel? get data;
  @override
  List<String> get errors;
  @override
  String? get error;

  /// Create a copy of CalendarEventApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalendarEventApiResponseImplCopyWith<_$CalendarEventApiResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CalendarEventListApiResponse _$CalendarEventListApiResponseFromJson(
  Map<String, dynamic> json,
) {
  return _CalendarEventListApiResponse.fromJson(json);
}

/// @nodoc
mixin _$CalendarEventListApiResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  CalendarEventListData? get data => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this CalendarEventListApiResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalendarEventListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalendarEventListApiResponseCopyWith<CalendarEventListApiResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEventListApiResponseCopyWith<$Res> {
  factory $CalendarEventListApiResponseCopyWith(
    CalendarEventListApiResponse value,
    $Res Function(CalendarEventListApiResponse) then,
  ) =
      _$CalendarEventListApiResponseCopyWithImpl<
        $Res,
        CalendarEventListApiResponse
      >;
  @useResult
  $Res call({
    bool success,
    String message,
    CalendarEventListData? data,
    List<String> errors,
    String? error,
  });

  $CalendarEventListDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$CalendarEventListApiResponseCopyWithImpl<
  $Res,
  $Val extends CalendarEventListApiResponse
>
    implements $CalendarEventListApiResponseCopyWith<$Res> {
  _$CalendarEventListApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalendarEventListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = freezed,
    Object? errors = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as CalendarEventListData?,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of CalendarEventListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CalendarEventListDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $CalendarEventListDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CalendarEventListApiResponseImplCopyWith<$Res>
    implements $CalendarEventListApiResponseCopyWith<$Res> {
  factory _$$CalendarEventListApiResponseImplCopyWith(
    _$CalendarEventListApiResponseImpl value,
    $Res Function(_$CalendarEventListApiResponseImpl) then,
  ) = __$$CalendarEventListApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    String message,
    CalendarEventListData? data,
    List<String> errors,
    String? error,
  });

  @override
  $CalendarEventListDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$CalendarEventListApiResponseImplCopyWithImpl<$Res>
    extends
        _$CalendarEventListApiResponseCopyWithImpl<
          $Res,
          _$CalendarEventListApiResponseImpl
        >
    implements _$$CalendarEventListApiResponseImplCopyWith<$Res> {
  __$$CalendarEventListApiResponseImplCopyWithImpl(
    _$CalendarEventListApiResponseImpl _value,
    $Res Function(_$CalendarEventListApiResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CalendarEventListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = freezed,
    Object? errors = null,
    Object? error = freezed,
  }) {
    return _then(
      _$CalendarEventListApiResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as CalendarEventListData?,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarEventListApiResponseImpl
    implements _CalendarEventListApiResponse {
  const _$CalendarEventListApiResponseImpl({
    required this.success,
    required this.message,
    this.data,
    final List<String> errors = const [],
    this.error,
  }) : _errors = errors;

  factory _$CalendarEventListApiResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CalendarEventListApiResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final CalendarEventListData? data;
  final List<String> _errors;
  @override
  @JsonKey()
  List<String> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  @override
  final String? error;

  @override
  String toString() {
    return 'CalendarEventListApiResponse(success: $success, message: $message, data: $data, errors: $errors, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarEventListApiResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data) &&
            const DeepCollectionEquality().equals(other._errors, _errors) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    message,
    data,
    const DeepCollectionEquality().hash(_errors),
    error,
  );

  /// Create a copy of CalendarEventListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarEventListApiResponseImplCopyWith<
    _$CalendarEventListApiResponseImpl
  >
  get copyWith =>
      __$$CalendarEventListApiResponseImplCopyWithImpl<
        _$CalendarEventListApiResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarEventListApiResponseImplToJson(this);
  }
}

abstract class _CalendarEventListApiResponse
    implements CalendarEventListApiResponse {
  const factory _CalendarEventListApiResponse({
    required final bool success,
    required final String message,
    final CalendarEventListData? data,
    final List<String> errors,
    final String? error,
  }) = _$CalendarEventListApiResponseImpl;

  factory _CalendarEventListApiResponse.fromJson(Map<String, dynamic> json) =
      _$CalendarEventListApiResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  CalendarEventListData? get data;
  @override
  List<String> get errors;
  @override
  String? get error;

  /// Create a copy of CalendarEventListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalendarEventListApiResponseImplCopyWith<
    _$CalendarEventListApiResponseImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CalendarEventListData _$CalendarEventListDataFromJson(
  Map<String, dynamic> json,
) {
  return _CalendarEventListData.fromJson(json);
}

/// @nodoc
mixin _$CalendarEventListData {
  List<CalendarEventModel> get events => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get pageSize => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get hasPreviousPage => throw _privateConstructorUsedError;
  bool get hasNextPage => throw _privateConstructorUsedError;

  /// Serializes this CalendarEventListData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalendarEventListData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalendarEventListDataCopyWith<CalendarEventListData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalendarEventListDataCopyWith<$Res> {
  factory $CalendarEventListDataCopyWith(
    CalendarEventListData value,
    $Res Function(CalendarEventListData) then,
  ) = _$CalendarEventListDataCopyWithImpl<$Res, CalendarEventListData>;
  @useResult
  $Res call({
    List<CalendarEventModel> events,
    int totalCount,
    int page,
    int pageSize,
    int totalPages,
    bool hasPreviousPage,
    bool hasNextPage,
  });
}

/// @nodoc
class _$CalendarEventListDataCopyWithImpl<
  $Res,
  $Val extends CalendarEventListData
>
    implements $CalendarEventListDataCopyWith<$Res> {
  _$CalendarEventListDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalendarEventListData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? events = null,
    Object? totalCount = null,
    Object? page = null,
    Object? pageSize = null,
    Object? totalPages = null,
    Object? hasPreviousPage = null,
    Object? hasNextPage = null,
  }) {
    return _then(
      _value.copyWith(
            events: null == events
                ? _value.events
                : events // ignore: cast_nullable_to_non_nullable
                      as List<CalendarEventModel>,
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            pageSize: null == pageSize
                ? _value.pageSize
                : pageSize // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
            hasPreviousPage: null == hasPreviousPage
                ? _value.hasPreviousPage
                : hasPreviousPage // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasNextPage: null == hasNextPage
                ? _value.hasNextPage
                : hasNextPage // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CalendarEventListDataImplCopyWith<$Res>
    implements $CalendarEventListDataCopyWith<$Res> {
  factory _$$CalendarEventListDataImplCopyWith(
    _$CalendarEventListDataImpl value,
    $Res Function(_$CalendarEventListDataImpl) then,
  ) = __$$CalendarEventListDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<CalendarEventModel> events,
    int totalCount,
    int page,
    int pageSize,
    int totalPages,
    bool hasPreviousPage,
    bool hasNextPage,
  });
}

/// @nodoc
class __$$CalendarEventListDataImplCopyWithImpl<$Res>
    extends
        _$CalendarEventListDataCopyWithImpl<$Res, _$CalendarEventListDataImpl>
    implements _$$CalendarEventListDataImplCopyWith<$Res> {
  __$$CalendarEventListDataImplCopyWithImpl(
    _$CalendarEventListDataImpl _value,
    $Res Function(_$CalendarEventListDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CalendarEventListData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? events = null,
    Object? totalCount = null,
    Object? page = null,
    Object? pageSize = null,
    Object? totalPages = null,
    Object? hasPreviousPage = null,
    Object? hasNextPage = null,
  }) {
    return _then(
      _$CalendarEventListDataImpl(
        events: null == events
            ? _value._events
            : events // ignore: cast_nullable_to_non_nullable
                  as List<CalendarEventModel>,
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        pageSize: null == pageSize
            ? _value.pageSize
            : pageSize // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
        hasPreviousPage: null == hasPreviousPage
            ? _value.hasPreviousPage
            : hasPreviousPage // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasNextPage: null == hasNextPage
            ? _value.hasNextPage
            : hasNextPage // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CalendarEventListDataImpl implements _CalendarEventListData {
  const _$CalendarEventListDataImpl({
    required final List<CalendarEventModel> events,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  }) : _events = events;

  factory _$CalendarEventListDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalendarEventListDataImplFromJson(json);

  final List<CalendarEventModel> _events;
  @override
  List<CalendarEventModel> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  @override
  final int totalCount;
  @override
  final int page;
  @override
  final int pageSize;
  @override
  final int totalPages;
  @override
  final bool hasPreviousPage;
  @override
  final bool hasNextPage;

  @override
  String toString() {
    return 'CalendarEventListData(events: $events, totalCount: $totalCount, page: $page, pageSize: $pageSize, totalPages: $totalPages, hasPreviousPage: $hasPreviousPage, hasNextPage: $hasNextPage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalendarEventListDataImpl &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.pageSize, pageSize) ||
                other.pageSize == pageSize) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.hasPreviousPage, hasPreviousPage) ||
                other.hasPreviousPage == hasPreviousPage) &&
            (identical(other.hasNextPage, hasNextPage) ||
                other.hasNextPage == hasNextPage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_events),
    totalCount,
    page,
    pageSize,
    totalPages,
    hasPreviousPage,
    hasNextPage,
  );

  /// Create a copy of CalendarEventListData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalendarEventListDataImplCopyWith<_$CalendarEventListDataImpl>
  get copyWith =>
      __$$CalendarEventListDataImplCopyWithImpl<_$CalendarEventListDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CalendarEventListDataImplToJson(this);
  }
}

abstract class _CalendarEventListData implements CalendarEventListData {
  const factory _CalendarEventListData({
    required final List<CalendarEventModel> events,
    required final int totalCount,
    required final int page,
    required final int pageSize,
    required final int totalPages,
    required final bool hasPreviousPage,
    required final bool hasNextPage,
  }) = _$CalendarEventListDataImpl;

  factory _CalendarEventListData.fromJson(Map<String, dynamic> json) =
      _$CalendarEventListDataImpl.fromJson;

  @override
  List<CalendarEventModel> get events;
  @override
  int get totalCount;
  @override
  int get page;
  @override
  int get pageSize;
  @override
  int get totalPages;
  @override
  bool get hasPreviousPage;
  @override
  bool get hasNextPage;

  /// Create a copy of CalendarEventListData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalendarEventListDataImplCopyWith<_$CalendarEventListDataImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ConflictCheckApiResponse _$ConflictCheckApiResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ConflictCheckApiResponse.fromJson(json);
}

/// @nodoc
mixin _$ConflictCheckApiResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  ConflictCheckData? get data => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;

  /// Serializes this ConflictCheckApiResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConflictCheckApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConflictCheckApiResponseCopyWith<ConflictCheckApiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConflictCheckApiResponseCopyWith<$Res> {
  factory $ConflictCheckApiResponseCopyWith(
    ConflictCheckApiResponse value,
    $Res Function(ConflictCheckApiResponse) then,
  ) = _$ConflictCheckApiResponseCopyWithImpl<$Res, ConflictCheckApiResponse>;
  @useResult
  $Res call({
    bool success,
    String message,
    ConflictCheckData? data,
    List<String> errors,
  });

  $ConflictCheckDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$ConflictCheckApiResponseCopyWithImpl<
  $Res,
  $Val extends ConflictCheckApiResponse
>
    implements $ConflictCheckApiResponseCopyWith<$Res> {
  _$ConflictCheckApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConflictCheckApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = freezed,
    Object? errors = null,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            data: freezed == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as ConflictCheckData?,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of ConflictCheckApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConflictCheckDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $ConflictCheckDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConflictCheckApiResponseImplCopyWith<$Res>
    implements $ConflictCheckApiResponseCopyWith<$Res> {
  factory _$$ConflictCheckApiResponseImplCopyWith(
    _$ConflictCheckApiResponseImpl value,
    $Res Function(_$ConflictCheckApiResponseImpl) then,
  ) = __$$ConflictCheckApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    String message,
    ConflictCheckData? data,
    List<String> errors,
  });

  @override
  $ConflictCheckDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$ConflictCheckApiResponseImplCopyWithImpl<$Res>
    extends
        _$ConflictCheckApiResponseCopyWithImpl<
          $Res,
          _$ConflictCheckApiResponseImpl
        >
    implements _$$ConflictCheckApiResponseImplCopyWith<$Res> {
  __$$ConflictCheckApiResponseImplCopyWithImpl(
    _$ConflictCheckApiResponseImpl _value,
    $Res Function(_$ConflictCheckApiResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConflictCheckApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = freezed,
    Object? errors = null,
  }) {
    return _then(
      _$ConflictCheckApiResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        data: freezed == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as ConflictCheckData?,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConflictCheckApiResponseImpl implements _ConflictCheckApiResponse {
  const _$ConflictCheckApiResponseImpl({
    required this.success,
    required this.message,
    this.data,
    final List<String> errors = const [],
  }) : _errors = errors;

  factory _$ConflictCheckApiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConflictCheckApiResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final ConflictCheckData? data;
  final List<String> _errors;
  @override
  @JsonKey()
  List<String> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  @override
  String toString() {
    return 'ConflictCheckApiResponse(success: $success, message: $message, data: $data, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConflictCheckApiResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.data, data) || other.data == data) &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    message,
    data,
    const DeepCollectionEquality().hash(_errors),
  );

  /// Create a copy of ConflictCheckApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConflictCheckApiResponseImplCopyWith<_$ConflictCheckApiResponseImpl>
  get copyWith =>
      __$$ConflictCheckApiResponseImplCopyWithImpl<
        _$ConflictCheckApiResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConflictCheckApiResponseImplToJson(this);
  }
}

abstract class _ConflictCheckApiResponse implements ConflictCheckApiResponse {
  const factory _ConflictCheckApiResponse({
    required final bool success,
    required final String message,
    final ConflictCheckData? data,
    final List<String> errors,
  }) = _$ConflictCheckApiResponseImpl;

  factory _ConflictCheckApiResponse.fromJson(Map<String, dynamic> json) =
      _$ConflictCheckApiResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  ConflictCheckData? get data;
  @override
  List<String> get errors;

  /// Create a copy of ConflictCheckApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConflictCheckApiResponseImplCopyWith<_$ConflictCheckApiResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ConflictCheckData _$ConflictCheckDataFromJson(Map<String, dynamic> json) {
  return _ConflictCheckData.fromJson(json);
}

/// @nodoc
mixin _$ConflictCheckData {
  bool get hasConflicts => throw _privateConstructorUsedError;
  List<CalendarEventModel> get conflictingEvents =>
      throw _privateConstructorUsedError;

  /// Serializes this ConflictCheckData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConflictCheckData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConflictCheckDataCopyWith<ConflictCheckData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConflictCheckDataCopyWith<$Res> {
  factory $ConflictCheckDataCopyWith(
    ConflictCheckData value,
    $Res Function(ConflictCheckData) then,
  ) = _$ConflictCheckDataCopyWithImpl<$Res, ConflictCheckData>;
  @useResult
  $Res call({bool hasConflicts, List<CalendarEventModel> conflictingEvents});
}

/// @nodoc
class _$ConflictCheckDataCopyWithImpl<$Res, $Val extends ConflictCheckData>
    implements $ConflictCheckDataCopyWith<$Res> {
  _$ConflictCheckDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConflictCheckData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? hasConflicts = null, Object? conflictingEvents = null}) {
    return _then(
      _value.copyWith(
            hasConflicts: null == hasConflicts
                ? _value.hasConflicts
                : hasConflicts // ignore: cast_nullable_to_non_nullable
                      as bool,
            conflictingEvents: null == conflictingEvents
                ? _value.conflictingEvents
                : conflictingEvents // ignore: cast_nullable_to_non_nullable
                      as List<CalendarEventModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConflictCheckDataImplCopyWith<$Res>
    implements $ConflictCheckDataCopyWith<$Res> {
  factory _$$ConflictCheckDataImplCopyWith(
    _$ConflictCheckDataImpl value,
    $Res Function(_$ConflictCheckDataImpl) then,
  ) = __$$ConflictCheckDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool hasConflicts, List<CalendarEventModel> conflictingEvents});
}

/// @nodoc
class __$$ConflictCheckDataImplCopyWithImpl<$Res>
    extends _$ConflictCheckDataCopyWithImpl<$Res, _$ConflictCheckDataImpl>
    implements _$$ConflictCheckDataImplCopyWith<$Res> {
  __$$ConflictCheckDataImplCopyWithImpl(
    _$ConflictCheckDataImpl _value,
    $Res Function(_$ConflictCheckDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConflictCheckData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? hasConflicts = null, Object? conflictingEvents = null}) {
    return _then(
      _$ConflictCheckDataImpl(
        hasConflicts: null == hasConflicts
            ? _value.hasConflicts
            : hasConflicts // ignore: cast_nullable_to_non_nullable
                  as bool,
        conflictingEvents: null == conflictingEvents
            ? _value._conflictingEvents
            : conflictingEvents // ignore: cast_nullable_to_non_nullable
                  as List<CalendarEventModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConflictCheckDataImpl implements _ConflictCheckData {
  const _$ConflictCheckDataImpl({
    required this.hasConflicts,
    required final List<CalendarEventModel> conflictingEvents,
  }) : _conflictingEvents = conflictingEvents;

  factory _$ConflictCheckDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConflictCheckDataImplFromJson(json);

  @override
  final bool hasConflicts;
  final List<CalendarEventModel> _conflictingEvents;
  @override
  List<CalendarEventModel> get conflictingEvents {
    if (_conflictingEvents is EqualUnmodifiableListView)
      return _conflictingEvents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_conflictingEvents);
  }

  @override
  String toString() {
    return 'ConflictCheckData(hasConflicts: $hasConflicts, conflictingEvents: $conflictingEvents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConflictCheckDataImpl &&
            (identical(other.hasConflicts, hasConflicts) ||
                other.hasConflicts == hasConflicts) &&
            const DeepCollectionEquality().equals(
              other._conflictingEvents,
              _conflictingEvents,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    hasConflicts,
    const DeepCollectionEquality().hash(_conflictingEvents),
  );

  /// Create a copy of ConflictCheckData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConflictCheckDataImplCopyWith<_$ConflictCheckDataImpl> get copyWith =>
      __$$ConflictCheckDataImplCopyWithImpl<_$ConflictCheckDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConflictCheckDataImplToJson(this);
  }
}

abstract class _ConflictCheckData implements ConflictCheckData {
  const factory _ConflictCheckData({
    required final bool hasConflicts,
    required final List<CalendarEventModel> conflictingEvents,
  }) = _$ConflictCheckDataImpl;

  factory _ConflictCheckData.fromJson(Map<String, dynamic> json) =
      _$ConflictCheckDataImpl.fromJson;

  @override
  bool get hasConflicts;
  @override
  List<CalendarEventModel> get conflictingEvents;

  /// Create a copy of ConflictCheckData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConflictCheckDataImplCopyWith<_$ConflictCheckDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateCalendarEventRequest _$CreateCalendarEventRequestFromJson(
  Map<String, dynamic> json,
) {
  return _CreateCalendarEventRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateCalendarEventRequest {
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime get startDateTime => throw _privateConstructorUsedError;
  DateTime get endDateTime => throw _privateConstructorUsedError;
  String get eventType => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get priority => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  bool get isAllDay => throw _privateConstructorUsedError;
  bool get isRecurring => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  int get reminderMinutes => throw _privateConstructorUsedError;
  String? get projectId => throw _privateConstructorUsedError;
  String? get taskId => throw _privateConstructorUsedError;
  String? get assignedToUserId => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  bool get isPrivate => throw _privateConstructorUsedError;
  String? get attendees => throw _privateConstructorUsedError;

  /// Serializes this CreateCalendarEventRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateCalendarEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateCalendarEventRequestCopyWith<CreateCalendarEventRequest>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateCalendarEventRequestCopyWith<$Res> {
  factory $CreateCalendarEventRequestCopyWith(
    CreateCalendarEventRequest value,
    $Res Function(CreateCalendarEventRequest) then,
  ) =
      _$CreateCalendarEventRequestCopyWithImpl<
        $Res,
        CreateCalendarEventRequest
      >;
  @useResult
  $Res call({
    String title,
    String? description,
    DateTime startDateTime,
    DateTime endDateTime,
    String eventType,
    String status,
    String priority,
    String? location,
    bool isAllDay,
    bool isRecurring,
    String? notes,
    int reminderMinutes,
    String? projectId,
    String? taskId,
    String? assignedToUserId,
    String? color,
    bool isPrivate,
    String? attendees,
  });
}

/// @nodoc
class _$CreateCalendarEventRequestCopyWithImpl<
  $Res,
  $Val extends CreateCalendarEventRequest
>
    implements $CreateCalendarEventRequestCopyWith<$Res> {
  _$CreateCalendarEventRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateCalendarEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = freezed,
    Object? startDateTime = null,
    Object? endDateTime = null,
    Object? eventType = null,
    Object? status = null,
    Object? priority = null,
    Object? location = freezed,
    Object? isAllDay = null,
    Object? isRecurring = null,
    Object? notes = freezed,
    Object? reminderMinutes = null,
    Object? projectId = freezed,
    Object? taskId = freezed,
    Object? assignedToUserId = freezed,
    Object? color = freezed,
    Object? isPrivate = null,
    Object? attendees = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            startDateTime: null == startDateTime
                ? _value.startDateTime
                : startDateTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDateTime: null == endDateTime
                ? _value.endDateTime
                : endDateTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            eventType: null == eventType
                ? _value.eventType
                : eventType // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as String,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            isAllDay: null == isAllDay
                ? _value.isAllDay
                : isAllDay // ignore: cast_nullable_to_non_nullable
                      as bool,
            isRecurring: null == isRecurring
                ? _value.isRecurring
                : isRecurring // ignore: cast_nullable_to_non_nullable
                      as bool,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            reminderMinutes: null == reminderMinutes
                ? _value.reminderMinutes
                : reminderMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            projectId: freezed == projectId
                ? _value.projectId
                : projectId // ignore: cast_nullable_to_non_nullable
                      as String?,
            taskId: freezed == taskId
                ? _value.taskId
                : taskId // ignore: cast_nullable_to_non_nullable
                      as String?,
            assignedToUserId: freezed == assignedToUserId
                ? _value.assignedToUserId
                : assignedToUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPrivate: null == isPrivate
                ? _value.isPrivate
                : isPrivate // ignore: cast_nullable_to_non_nullable
                      as bool,
            attendees: freezed == attendees
                ? _value.attendees
                : attendees // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateCalendarEventRequestImplCopyWith<$Res>
    implements $CreateCalendarEventRequestCopyWith<$Res> {
  factory _$$CreateCalendarEventRequestImplCopyWith(
    _$CreateCalendarEventRequestImpl value,
    $Res Function(_$CreateCalendarEventRequestImpl) then,
  ) = __$$CreateCalendarEventRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String? description,
    DateTime startDateTime,
    DateTime endDateTime,
    String eventType,
    String status,
    String priority,
    String? location,
    bool isAllDay,
    bool isRecurring,
    String? notes,
    int reminderMinutes,
    String? projectId,
    String? taskId,
    String? assignedToUserId,
    String? color,
    bool isPrivate,
    String? attendees,
  });
}

/// @nodoc
class __$$CreateCalendarEventRequestImplCopyWithImpl<$Res>
    extends
        _$CreateCalendarEventRequestCopyWithImpl<
          $Res,
          _$CreateCalendarEventRequestImpl
        >
    implements _$$CreateCalendarEventRequestImplCopyWith<$Res> {
  __$$CreateCalendarEventRequestImplCopyWithImpl(
    _$CreateCalendarEventRequestImpl _value,
    $Res Function(_$CreateCalendarEventRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateCalendarEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = freezed,
    Object? startDateTime = null,
    Object? endDateTime = null,
    Object? eventType = null,
    Object? status = null,
    Object? priority = null,
    Object? location = freezed,
    Object? isAllDay = null,
    Object? isRecurring = null,
    Object? notes = freezed,
    Object? reminderMinutes = null,
    Object? projectId = freezed,
    Object? taskId = freezed,
    Object? assignedToUserId = freezed,
    Object? color = freezed,
    Object? isPrivate = null,
    Object? attendees = freezed,
  }) {
    return _then(
      _$CreateCalendarEventRequestImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDateTime: null == startDateTime
            ? _value.startDateTime
            : startDateTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDateTime: null == endDateTime
            ? _value.endDateTime
            : endDateTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        eventType: null == eventType
            ? _value.eventType
            : eventType // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as String,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        isAllDay: null == isAllDay
            ? _value.isAllDay
            : isAllDay // ignore: cast_nullable_to_non_nullable
                  as bool,
        isRecurring: null == isRecurring
            ? _value.isRecurring
            : isRecurring // ignore: cast_nullable_to_non_nullable
                  as bool,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        reminderMinutes: null == reminderMinutes
            ? _value.reminderMinutes
            : reminderMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        projectId: freezed == projectId
            ? _value.projectId
            : projectId // ignore: cast_nullable_to_non_nullable
                  as String?,
        taskId: freezed == taskId
            ? _value.taskId
            : taskId // ignore: cast_nullable_to_non_nullable
                  as String?,
        assignedToUserId: freezed == assignedToUserId
            ? _value.assignedToUserId
            : assignedToUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPrivate: null == isPrivate
            ? _value.isPrivate
            : isPrivate // ignore: cast_nullable_to_non_nullable
                  as bool,
        attendees: freezed == attendees
            ? _value.attendees
            : attendees // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateCalendarEventRequestImpl implements _CreateCalendarEventRequest {
  const _$CreateCalendarEventRequestImpl({
    required this.title,
    this.description,
    required this.startDateTime,
    required this.endDateTime,
    required this.eventType,
    required this.status,
    required this.priority,
    this.location,
    this.isAllDay = false,
    this.isRecurring = false,
    this.notes,
    this.reminderMinutes = 15,
    this.projectId,
    this.taskId,
    this.assignedToUserId,
    this.color,
    this.isPrivate = false,
    this.attendees,
  });

  factory _$CreateCalendarEventRequestImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$CreateCalendarEventRequestImplFromJson(json);

  @override
  final String title;
  @override
  final String? description;
  @override
  final DateTime startDateTime;
  @override
  final DateTime endDateTime;
  @override
  final String eventType;
  @override
  final String status;
  @override
  final String priority;
  @override
  final String? location;
  @override
  @JsonKey()
  final bool isAllDay;
  @override
  @JsonKey()
  final bool isRecurring;
  @override
  final String? notes;
  @override
  @JsonKey()
  final int reminderMinutes;
  @override
  final String? projectId;
  @override
  final String? taskId;
  @override
  final String? assignedToUserId;
  @override
  final String? color;
  @override
  @JsonKey()
  final bool isPrivate;
  @override
  final String? attendees;

  @override
  String toString() {
    return 'CreateCalendarEventRequest(title: $title, description: $description, startDateTime: $startDateTime, endDateTime: $endDateTime, eventType: $eventType, status: $status, priority: $priority, location: $location, isAllDay: $isAllDay, isRecurring: $isRecurring, notes: $notes, reminderMinutes: $reminderMinutes, projectId: $projectId, taskId: $taskId, assignedToUserId: $assignedToUserId, color: $color, isPrivate: $isPrivate, attendees: $attendees)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateCalendarEventRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startDateTime, startDateTime) ||
                other.startDateTime == startDateTime) &&
            (identical(other.endDateTime, endDateTime) ||
                other.endDateTime == endDateTime) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.reminderMinutes, reminderMinutes) ||
                other.reminderMinutes == reminderMinutes) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.assignedToUserId, assignedToUserId) ||
                other.assignedToUserId == assignedToUserId) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(other.attendees, attendees) ||
                other.attendees == attendees));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    description,
    startDateTime,
    endDateTime,
    eventType,
    status,
    priority,
    location,
    isAllDay,
    isRecurring,
    notes,
    reminderMinutes,
    projectId,
    taskId,
    assignedToUserId,
    color,
    isPrivate,
    attendees,
  );

  /// Create a copy of CreateCalendarEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateCalendarEventRequestImplCopyWith<_$CreateCalendarEventRequestImpl>
  get copyWith =>
      __$$CreateCalendarEventRequestImplCopyWithImpl<
        _$CreateCalendarEventRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateCalendarEventRequestImplToJson(this);
  }
}

abstract class _CreateCalendarEventRequest
    implements CreateCalendarEventRequest {
  const factory _CreateCalendarEventRequest({
    required final String title,
    final String? description,
    required final DateTime startDateTime,
    required final DateTime endDateTime,
    required final String eventType,
    required final String status,
    required final String priority,
    final String? location,
    final bool isAllDay,
    final bool isRecurring,
    final String? notes,
    final int reminderMinutes,
    final String? projectId,
    final String? taskId,
    final String? assignedToUserId,
    final String? color,
    final bool isPrivate,
    final String? attendees,
  }) = _$CreateCalendarEventRequestImpl;

  factory _CreateCalendarEventRequest.fromJson(Map<String, dynamic> json) =
      _$CreateCalendarEventRequestImpl.fromJson;

  @override
  String get title;
  @override
  String? get description;
  @override
  DateTime get startDateTime;
  @override
  DateTime get endDateTime;
  @override
  String get eventType;
  @override
  String get status;
  @override
  String get priority;
  @override
  String? get location;
  @override
  bool get isAllDay;
  @override
  bool get isRecurring;
  @override
  String? get notes;
  @override
  int get reminderMinutes;
  @override
  String? get projectId;
  @override
  String? get taskId;
  @override
  String? get assignedToUserId;
  @override
  String? get color;
  @override
  bool get isPrivate;
  @override
  String? get attendees;

  /// Create a copy of CreateCalendarEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateCalendarEventRequestImplCopyWith<_$CreateCalendarEventRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

UpdateCalendarEventRequest _$UpdateCalendarEventRequestFromJson(
  Map<String, dynamic> json,
) {
  return _UpdateCalendarEventRequest.fromJson(json);
}

/// @nodoc
mixin _$UpdateCalendarEventRequest {
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DateTime? get startDateTime => throw _privateConstructorUsedError;
  DateTime? get endDateTime => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get priority => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  int? get reminderMinutes => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;

  /// Serializes this UpdateCalendarEventRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UpdateCalendarEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UpdateCalendarEventRequestCopyWith<UpdateCalendarEventRequest>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateCalendarEventRequestCopyWith<$Res> {
  factory $UpdateCalendarEventRequestCopyWith(
    UpdateCalendarEventRequest value,
    $Res Function(UpdateCalendarEventRequest) then,
  ) =
      _$UpdateCalendarEventRequestCopyWithImpl<
        $Res,
        UpdateCalendarEventRequest
      >;
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class _$UpdateCalendarEventRequestCopyWithImpl<
  $Res,
  $Val extends UpdateCalendarEventRequest
>
    implements $UpdateCalendarEventRequestCopyWith<$Res> {
  _$UpdateCalendarEventRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UpdateCalendarEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? startDateTime = freezed,
    Object? endDateTime = freezed,
    Object? status = freezed,
    Object? priority = freezed,
    Object? location = freezed,
    Object? notes = freezed,
    Object? reminderMinutes = freezed,
    Object? color = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            startDateTime: freezed == startDateTime
                ? _value.startDateTime
                : startDateTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDateTime: freezed == endDateTime
                ? _value.endDateTime
                : endDateTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            priority: freezed == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            reminderMinutes: freezed == reminderMinutes
                ? _value.reminderMinutes
                : reminderMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UpdateCalendarEventRequestImplCopyWith<$Res>
    implements $UpdateCalendarEventRequestCopyWith<$Res> {
  factory _$$UpdateCalendarEventRequestImplCopyWith(
    _$UpdateCalendarEventRequestImpl value,
    $Res Function(_$UpdateCalendarEventRequestImpl) then,
  ) = __$$UpdateCalendarEventRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
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
  });
}

/// @nodoc
class __$$UpdateCalendarEventRequestImplCopyWithImpl<$Res>
    extends
        _$UpdateCalendarEventRequestCopyWithImpl<
          $Res,
          _$UpdateCalendarEventRequestImpl
        >
    implements _$$UpdateCalendarEventRequestImplCopyWith<$Res> {
  __$$UpdateCalendarEventRequestImplCopyWithImpl(
    _$UpdateCalendarEventRequestImpl _value,
    $Res Function(_$UpdateCalendarEventRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UpdateCalendarEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? description = freezed,
    Object? startDateTime = freezed,
    Object? endDateTime = freezed,
    Object? status = freezed,
    Object? priority = freezed,
    Object? location = freezed,
    Object? notes = freezed,
    Object? reminderMinutes = freezed,
    Object? color = freezed,
  }) {
    return _then(
      _$UpdateCalendarEventRequestImpl(
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDateTime: freezed == startDateTime
            ? _value.startDateTime
            : startDateTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDateTime: freezed == endDateTime
            ? _value.endDateTime
            : endDateTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        priority: freezed == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        reminderMinutes: freezed == reminderMinutes
            ? _value.reminderMinutes
            : reminderMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UpdateCalendarEventRequestImpl implements _UpdateCalendarEventRequest {
  const _$UpdateCalendarEventRequestImpl({
    this.title,
    this.description,
    this.startDateTime,
    this.endDateTime,
    this.status,
    this.priority,
    this.location,
    this.notes,
    this.reminderMinutes,
    this.color,
  });

  factory _$UpdateCalendarEventRequestImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$UpdateCalendarEventRequestImplFromJson(json);

  @override
  final String? title;
  @override
  final String? description;
  @override
  final DateTime? startDateTime;
  @override
  final DateTime? endDateTime;
  @override
  final String? status;
  @override
  final String? priority;
  @override
  final String? location;
  @override
  final String? notes;
  @override
  final int? reminderMinutes;
  @override
  final String? color;

  @override
  String toString() {
    return 'UpdateCalendarEventRequest(title: $title, description: $description, startDateTime: $startDateTime, endDateTime: $endDateTime, status: $status, priority: $priority, location: $location, notes: $notes, reminderMinutes: $reminderMinutes, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateCalendarEventRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startDateTime, startDateTime) ||
                other.startDateTime == startDateTime) &&
            (identical(other.endDateTime, endDateTime) ||
                other.endDateTime == endDateTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.reminderMinutes, reminderMinutes) ||
                other.reminderMinutes == reminderMinutes) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    description,
    startDateTime,
    endDateTime,
    status,
    priority,
    location,
    notes,
    reminderMinutes,
    color,
  );

  /// Create a copy of UpdateCalendarEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateCalendarEventRequestImplCopyWith<_$UpdateCalendarEventRequestImpl>
  get copyWith =>
      __$$UpdateCalendarEventRequestImplCopyWithImpl<
        _$UpdateCalendarEventRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UpdateCalendarEventRequestImplToJson(this);
  }
}

abstract class _UpdateCalendarEventRequest
    implements UpdateCalendarEventRequest {
  const factory _UpdateCalendarEventRequest({
    final String? title,
    final String? description,
    final DateTime? startDateTime,
    final DateTime? endDateTime,
    final String? status,
    final String? priority,
    final String? location,
    final String? notes,
    final int? reminderMinutes,
    final String? color,
  }) = _$UpdateCalendarEventRequestImpl;

  factory _UpdateCalendarEventRequest.fromJson(Map<String, dynamic> json) =
      _$UpdateCalendarEventRequestImpl.fromJson;

  @override
  String? get title;
  @override
  String? get description;
  @override
  DateTime? get startDateTime;
  @override
  DateTime? get endDateTime;
  @override
  String? get status;
  @override
  String? get priority;
  @override
  String? get location;
  @override
  String? get notes;
  @override
  int? get reminderMinutes;
  @override
  String? get color;

  /// Create a copy of UpdateCalendarEventRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateCalendarEventRequestImplCopyWith<_$UpdateCalendarEventRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ConflictCheckRequest _$ConflictCheckRequestFromJson(Map<String, dynamic> json) {
  return _ConflictCheckRequest.fromJson(json);
}

/// @nodoc
mixin _$ConflictCheckRequest {
  DateTime get startDateTime => throw _privateConstructorUsedError;
  DateTime get endDateTime => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get excludeEventId => throw _privateConstructorUsedError;

  /// Serializes this ConflictCheckRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConflictCheckRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConflictCheckRequestCopyWith<ConflictCheckRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConflictCheckRequestCopyWith<$Res> {
  factory $ConflictCheckRequestCopyWith(
    ConflictCheckRequest value,
    $Res Function(ConflictCheckRequest) then,
  ) = _$ConflictCheckRequestCopyWithImpl<$Res, ConflictCheckRequest>;
  @useResult
  $Res call({
    DateTime startDateTime,
    DateTime endDateTime,
    String userId,
    String? excludeEventId,
  });
}

/// @nodoc
class _$ConflictCheckRequestCopyWithImpl<
  $Res,
  $Val extends ConflictCheckRequest
>
    implements $ConflictCheckRequestCopyWith<$Res> {
  _$ConflictCheckRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConflictCheckRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDateTime = null,
    Object? endDateTime = null,
    Object? userId = null,
    Object? excludeEventId = freezed,
  }) {
    return _then(
      _value.copyWith(
            startDateTime: null == startDateTime
                ? _value.startDateTime
                : startDateTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDateTime: null == endDateTime
                ? _value.endDateTime
                : endDateTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            excludeEventId: freezed == excludeEventId
                ? _value.excludeEventId
                : excludeEventId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConflictCheckRequestImplCopyWith<$Res>
    implements $ConflictCheckRequestCopyWith<$Res> {
  factory _$$ConflictCheckRequestImplCopyWith(
    _$ConflictCheckRequestImpl value,
    $Res Function(_$ConflictCheckRequestImpl) then,
  ) = __$$ConflictCheckRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime startDateTime,
    DateTime endDateTime,
    String userId,
    String? excludeEventId,
  });
}

/// @nodoc
class __$$ConflictCheckRequestImplCopyWithImpl<$Res>
    extends _$ConflictCheckRequestCopyWithImpl<$Res, _$ConflictCheckRequestImpl>
    implements _$$ConflictCheckRequestImplCopyWith<$Res> {
  __$$ConflictCheckRequestImplCopyWithImpl(
    _$ConflictCheckRequestImpl _value,
    $Res Function(_$ConflictCheckRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConflictCheckRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDateTime = null,
    Object? endDateTime = null,
    Object? userId = null,
    Object? excludeEventId = freezed,
  }) {
    return _then(
      _$ConflictCheckRequestImpl(
        startDateTime: null == startDateTime
            ? _value.startDateTime
            : startDateTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDateTime: null == endDateTime
            ? _value.endDateTime
            : endDateTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        excludeEventId: freezed == excludeEventId
            ? _value.excludeEventId
            : excludeEventId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConflictCheckRequestImpl implements _ConflictCheckRequest {
  const _$ConflictCheckRequestImpl({
    required this.startDateTime,
    required this.endDateTime,
    required this.userId,
    this.excludeEventId,
  });

  factory _$ConflictCheckRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConflictCheckRequestImplFromJson(json);

  @override
  final DateTime startDateTime;
  @override
  final DateTime endDateTime;
  @override
  final String userId;
  @override
  final String? excludeEventId;

  @override
  String toString() {
    return 'ConflictCheckRequest(startDateTime: $startDateTime, endDateTime: $endDateTime, userId: $userId, excludeEventId: $excludeEventId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConflictCheckRequestImpl &&
            (identical(other.startDateTime, startDateTime) ||
                other.startDateTime == startDateTime) &&
            (identical(other.endDateTime, endDateTime) ||
                other.endDateTime == endDateTime) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.excludeEventId, excludeEventId) ||
                other.excludeEventId == excludeEventId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    startDateTime,
    endDateTime,
    userId,
    excludeEventId,
  );

  /// Create a copy of ConflictCheckRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConflictCheckRequestImplCopyWith<_$ConflictCheckRequestImpl>
  get copyWith =>
      __$$ConflictCheckRequestImplCopyWithImpl<_$ConflictCheckRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConflictCheckRequestImplToJson(this);
  }
}

abstract class _ConflictCheckRequest implements ConflictCheckRequest {
  const factory _ConflictCheckRequest({
    required final DateTime startDateTime,
    required final DateTime endDateTime,
    required final String userId,
    final String? excludeEventId,
  }) = _$ConflictCheckRequestImpl;

  factory _ConflictCheckRequest.fromJson(Map<String, dynamic> json) =
      _$ConflictCheckRequestImpl.fromJson;

  @override
  DateTime get startDateTime;
  @override
  DateTime get endDateTime;
  @override
  String get userId;
  @override
  String? get excludeEventId;

  /// Create a copy of ConflictCheckRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConflictCheckRequestImplCopyWith<_$ConflictCheckRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
