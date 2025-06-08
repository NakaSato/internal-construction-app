// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_data_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LocationDataModel _$LocationDataModelFromJson(Map<String, dynamic> json) {
  return _LocationDataModel.fromJson(json);
}

/// @nodoc
mixin _$LocationDataModel {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  double? get accuracy => throw _privateConstructorUsedError;
  double? get altitude => throw _privateConstructorUsedError;
  double? get speed => throw _privateConstructorUsedError;
  double? get heading => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;

  /// Serializes this LocationDataModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationDataModelCopyWith<LocationDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationDataModelCopyWith<$Res> {
  factory $LocationDataModelCopyWith(
    LocationDataModel value,
    $Res Function(LocationDataModel) then,
  ) = _$LocationDataModelCopyWithImpl<$Res, LocationDataModel>;
  @useResult
  $Res call({
    double latitude,
    double longitude,
    DateTime timestamp,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
  });
}

/// @nodoc
class _$LocationDataModelCopyWithImpl<$Res, $Val extends LocationDataModel>
    implements $LocationDataModelCopyWith<$Res> {
  _$LocationDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = null,
    Object? accuracy = freezed,
    Object? altitude = freezed,
    Object? speed = freezed,
    Object? heading = freezed,
    Object? address = freezed,
  }) {
    return _then(
      _value.copyWith(
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            accuracy: freezed == accuracy
                ? _value.accuracy
                : accuracy // ignore: cast_nullable_to_non_nullable
                      as double?,
            altitude: freezed == altitude
                ? _value.altitude
                : altitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            speed: freezed == speed
                ? _value.speed
                : speed // ignore: cast_nullable_to_non_nullable
                      as double?,
            heading: freezed == heading
                ? _value.heading
                : heading // ignore: cast_nullable_to_non_nullable
                      as double?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocationDataModelImplCopyWith<$Res>
    implements $LocationDataModelCopyWith<$Res> {
  factory _$$LocationDataModelImplCopyWith(
    _$LocationDataModelImpl value,
    $Res Function(_$LocationDataModelImpl) then,
  ) = __$$LocationDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double latitude,
    double longitude,
    DateTime timestamp,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    String? address,
  });
}

/// @nodoc
class __$$LocationDataModelImplCopyWithImpl<$Res>
    extends _$LocationDataModelCopyWithImpl<$Res, _$LocationDataModelImpl>
    implements _$$LocationDataModelImplCopyWith<$Res> {
  __$$LocationDataModelImplCopyWithImpl(
    _$LocationDataModelImpl _value,
    $Res Function(_$LocationDataModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = null,
    Object? accuracy = freezed,
    Object? altitude = freezed,
    Object? speed = freezed,
    Object? heading = freezed,
    Object? address = freezed,
  }) {
    return _then(
      _$LocationDataModelImpl(
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        accuracy: freezed == accuracy
            ? _value.accuracy
            : accuracy // ignore: cast_nullable_to_non_nullable
                  as double?,
        altitude: freezed == altitude
            ? _value.altitude
            : altitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        speed: freezed == speed
            ? _value.speed
            : speed // ignore: cast_nullable_to_non_nullable
                  as double?,
        heading: freezed == heading
            ? _value.heading
            : heading // ignore: cast_nullable_to_non_nullable
                  as double?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationDataModelImpl implements _LocationDataModel {
  const _$LocationDataModelImpl({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    this.address,
  });

  factory _$LocationDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationDataModelImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final DateTime timestamp;
  @override
  final double? accuracy;
  @override
  final double? altitude;
  @override
  final double? speed;
  @override
  final double? heading;
  @override
  final String? address;

  @override
  String toString() {
    return 'LocationDataModel(latitude: $latitude, longitude: $longitude, timestamp: $timestamp, accuracy: $accuracy, altitude: $altitude, speed: $speed, heading: $heading, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationDataModelImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.altitude, altitude) ||
                other.altitude == altitude) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.heading, heading) || other.heading == heading) &&
            (identical(other.address, address) || other.address == address));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    latitude,
    longitude,
    timestamp,
    accuracy,
    altitude,
    speed,
    heading,
    address,
  );

  /// Create a copy of LocationDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationDataModelImplCopyWith<_$LocationDataModelImpl> get copyWith =>
      __$$LocationDataModelImplCopyWithImpl<_$LocationDataModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationDataModelImplToJson(this);
  }
}

abstract class _LocationDataModel implements LocationDataModel {
  const factory _LocationDataModel({
    required final double latitude,
    required final double longitude,
    required final DateTime timestamp,
    final double? accuracy,
    final double? altitude,
    final double? speed,
    final double? heading,
    final String? address,
  }) = _$LocationDataModelImpl;

  factory _LocationDataModel.fromJson(Map<String, dynamic> json) =
      _$LocationDataModelImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;
  @override
  DateTime get timestamp;
  @override
  double? get accuracy;
  @override
  double? get altitude;
  @override
  double? get speed;
  @override
  double? get heading;
  @override
  String? get address;

  /// Create a copy of LocationDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationDataModelImplCopyWith<_$LocationDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
