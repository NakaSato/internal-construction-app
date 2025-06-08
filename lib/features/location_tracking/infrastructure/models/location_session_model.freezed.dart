// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LocationSessionModel _$LocationSessionModelFromJson(Map<String, dynamic> json) {
  return _LocationSessionModel.fromJson(json);
}

/// @nodoc
mixin _$LocationSessionModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  List<LocationDataModel> get locations => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this LocationSessionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationSessionModelCopyWith<LocationSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationSessionModelCopyWith<$Res> {
  factory $LocationSessionModelCopyWith(
    LocationSessionModel value,
    $Res Function(LocationSessionModel) then,
  ) = _$LocationSessionModelCopyWithImpl<$Res, LocationSessionModel>;
  @useResult
  $Res call({
    String id,
    String name,
    DateTime startTime,
    DateTime? endTime,
    List<LocationDataModel> locations,
    bool isActive,
    String? description,
  });
}

/// @nodoc
class _$LocationSessionModelCopyWithImpl<
  $Res,
  $Val extends LocationSessionModel
>
    implements $LocationSessionModelCopyWith<$Res> {
  _$LocationSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? locations = null,
    Object? isActive = null,
    Object? description = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            locations: null == locations
                ? _value.locations
                : locations // ignore: cast_nullable_to_non_nullable
                      as List<LocationDataModel>,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocationSessionModelImplCopyWith<$Res>
    implements $LocationSessionModelCopyWith<$Res> {
  factory _$$LocationSessionModelImplCopyWith(
    _$LocationSessionModelImpl value,
    $Res Function(_$LocationSessionModelImpl) then,
  ) = __$$LocationSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    DateTime startTime,
    DateTime? endTime,
    List<LocationDataModel> locations,
    bool isActive,
    String? description,
  });
}

/// @nodoc
class __$$LocationSessionModelImplCopyWithImpl<$Res>
    extends _$LocationSessionModelCopyWithImpl<$Res, _$LocationSessionModelImpl>
    implements _$$LocationSessionModelImplCopyWith<$Res> {
  __$$LocationSessionModelImplCopyWithImpl(
    _$LocationSessionModelImpl _value,
    $Res Function(_$LocationSessionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? locations = null,
    Object? isActive = null,
    Object? description = freezed,
  }) {
    return _then(
      _$LocationSessionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        locations: null == locations
            ? _value._locations
            : locations // ignore: cast_nullable_to_non_nullable
                  as List<LocationDataModel>,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationSessionModelImpl implements _LocationSessionModel {
  const _$LocationSessionModelImpl({
    required this.id,
    required this.name,
    required this.startTime,
    this.endTime,
    final List<LocationDataModel> locations = const [],
    this.isActive = false,
    this.description,
  }) : _locations = locations;

  factory _$LocationSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationSessionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
  final List<LocationDataModel> _locations;
  @override
  @JsonKey()
  List<LocationDataModel> get locations {
    if (_locations is EqualUnmodifiableListView) return _locations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_locations);
  }

  @override
  @JsonKey()
  final bool isActive;
  @override
  final String? description;

  @override
  String toString() {
    return 'LocationSessionModel(id: $id, name: $name, startTime: $startTime, endTime: $endTime, locations: $locations, isActive: $isActive, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationSessionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            const DeepCollectionEquality().equals(
              other._locations,
              _locations,
            ) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    startTime,
    endTime,
    const DeepCollectionEquality().hash(_locations),
    isActive,
    description,
  );

  /// Create a copy of LocationSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationSessionModelImplCopyWith<_$LocationSessionModelImpl>
  get copyWith =>
      __$$LocationSessionModelImplCopyWithImpl<_$LocationSessionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationSessionModelImplToJson(this);
  }
}

abstract class _LocationSessionModel implements LocationSessionModel {
  const factory _LocationSessionModel({
    required final String id,
    required final String name,
    required final DateTime startTime,
    final DateTime? endTime,
    final List<LocationDataModel> locations,
    final bool isActive,
    final String? description,
  }) = _$LocationSessionModelImpl;

  factory _LocationSessionModel.fromJson(Map<String, dynamic> json) =
      _$LocationSessionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
  @override
  List<LocationDataModel> get locations;
  @override
  bool get isActive;
  @override
  String? get description;

  /// Create a copy of LocationSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationSessionModelImplCopyWith<_$LocationSessionModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
