// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'work_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkEventModel _$WorkEventModelFromJson(Map<String, dynamic> json) {
  return _WorkEventModel.fromJson(json);
}

/// @nodoc
mixin _$WorkEventModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  bool get isAllDay => throw _privateConstructorUsedError;
  WorkEventType get eventType => throw _privateConstructorUsedError;
  List<String> get attendees => throw _privateConstructorUsedError;

  /// Serializes this WorkEventModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkEventModelCopyWith<WorkEventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkEventModelCopyWith<$Res> {
  factory $WorkEventModelCopyWith(
    WorkEventModel value,
    $Res Function(WorkEventModel) then,
  ) = _$WorkEventModelCopyWithImpl<$Res, WorkEventModel>;
  @useResult
  $Res call({
    String id,
    String title,
    DateTime startTime,
    DateTime endTime,
    String? description,
    String? location,
    String? color,
    bool isAllDay,
    WorkEventType eventType,
    List<String> attendees,
  });
}

/// @nodoc
class _$WorkEventModelCopyWithImpl<$Res, $Val extends WorkEventModel>
    implements $WorkEventModelCopyWith<$Res> {
  _$WorkEventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? description = freezed,
    Object? location = freezed,
    Object? color = freezed,
    Object? isAllDay = null,
    Object? eventType = null,
    Object? attendees = null,
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
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String?,
            isAllDay: null == isAllDay
                ? _value.isAllDay
                : isAllDay // ignore: cast_nullable_to_non_nullable
                      as bool,
            eventType: null == eventType
                ? _value.eventType
                : eventType // ignore: cast_nullable_to_non_nullable
                      as WorkEventType,
            attendees: null == attendees
                ? _value.attendees
                : attendees // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkEventModelImplCopyWith<$Res>
    implements $WorkEventModelCopyWith<$Res> {
  factory _$$WorkEventModelImplCopyWith(
    _$WorkEventModelImpl value,
    $Res Function(_$WorkEventModelImpl) then,
  ) = __$$WorkEventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    DateTime startTime,
    DateTime endTime,
    String? description,
    String? location,
    String? color,
    bool isAllDay,
    WorkEventType eventType,
    List<String> attendees,
  });
}

/// @nodoc
class __$$WorkEventModelImplCopyWithImpl<$Res>
    extends _$WorkEventModelCopyWithImpl<$Res, _$WorkEventModelImpl>
    implements _$$WorkEventModelImplCopyWith<$Res> {
  __$$WorkEventModelImplCopyWithImpl(
    _$WorkEventModelImpl _value,
    $Res Function(_$WorkEventModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? description = freezed,
    Object? location = freezed,
    Object? color = freezed,
    Object? isAllDay = null,
    Object? eventType = null,
    Object? attendees = null,
  }) {
    return _then(
      _$WorkEventModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String?,
        isAllDay: null == isAllDay
            ? _value.isAllDay
            : isAllDay // ignore: cast_nullable_to_non_nullable
                  as bool,
        eventType: null == eventType
            ? _value.eventType
            : eventType // ignore: cast_nullable_to_non_nullable
                  as WorkEventType,
        attendees: null == attendees
            ? _value._attendees
            : attendees // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkEventModelImpl implements _WorkEventModel {
  const _$WorkEventModelImpl({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.description,
    this.location,
    this.color,
    this.isAllDay = false,
    this.eventType = WorkEventType.meeting,
    final List<String> attendees = const [],
  }) : _attendees = attendees;

  factory _$WorkEventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkEventModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  final String? description;
  @override
  final String? location;
  @override
  final String? color;
  @override
  @JsonKey()
  final bool isAllDay;
  @override
  @JsonKey()
  final WorkEventType eventType;
  final List<String> _attendees;
  @override
  @JsonKey()
  List<String> get attendees {
    if (_attendees is EqualUnmodifiableListView) return _attendees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attendees);
  }

  @override
  String toString() {
    return 'WorkEventModel(id: $id, title: $title, startTime: $startTime, endTime: $endTime, description: $description, location: $location, color: $color, isAllDay: $isAllDay, eventType: $eventType, attendees: $attendees)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkEventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.isAllDay, isAllDay) ||
                other.isAllDay == isAllDay) &&
            (identical(other.eventType, eventType) ||
                other.eventType == eventType) &&
            const DeepCollectionEquality().equals(
              other._attendees,
              _attendees,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    startTime,
    endTime,
    description,
    location,
    color,
    isAllDay,
    eventType,
    const DeepCollectionEquality().hash(_attendees),
  );

  /// Create a copy of WorkEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkEventModelImplCopyWith<_$WorkEventModelImpl> get copyWith =>
      __$$WorkEventModelImplCopyWithImpl<_$WorkEventModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkEventModelImplToJson(this);
  }
}

abstract class _WorkEventModel implements WorkEventModel {
  const factory _WorkEventModel({
    required final String id,
    required final String title,
    required final DateTime startTime,
    required final DateTime endTime,
    final String? description,
    final String? location,
    final String? color,
    final bool isAllDay,
    final WorkEventType eventType,
    final List<String> attendees,
  }) = _$WorkEventModelImpl;

  factory _WorkEventModel.fromJson(Map<String, dynamic> json) =
      _$WorkEventModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override
  String? get description;
  @override
  String? get location;
  @override
  String? get color;
  @override
  bool get isAllDay;
  @override
  WorkEventType get eventType;
  @override
  List<String> get attendees;

  /// Create a copy of WorkEventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkEventModelImplCopyWith<_$WorkEventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
