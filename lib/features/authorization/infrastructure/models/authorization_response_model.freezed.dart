// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'authorization_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RoleApiResponse _$RoleApiResponseFromJson(Map<String, dynamic> json) {
  return _RoleApiResponse.fromJson(json);
}

/// @nodoc
mixin _$RoleApiResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  RoleModel? get data => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;

  /// Serializes this RoleApiResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoleApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoleApiResponseCopyWith<RoleApiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoleApiResponseCopyWith<$Res> {
  factory $RoleApiResponseCopyWith(
    RoleApiResponse value,
    $Res Function(RoleApiResponse) then,
  ) = _$RoleApiResponseCopyWithImpl<$Res, RoleApiResponse>;
  @useResult
  $Res call({
    bool success,
    String message,
    RoleModel? data,
    List<String> errors,
  });

  $RoleModelCopyWith<$Res>? get data;
}

/// @nodoc
class _$RoleApiResponseCopyWithImpl<$Res, $Val extends RoleApiResponse>
    implements $RoleApiResponseCopyWith<$Res> {
  _$RoleApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoleApiResponse
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
                      as RoleModel?,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of RoleApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RoleModelCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $RoleModelCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RoleApiResponseImplCopyWith<$Res>
    implements $RoleApiResponseCopyWith<$Res> {
  factory _$$RoleApiResponseImplCopyWith(
    _$RoleApiResponseImpl value,
    $Res Function(_$RoleApiResponseImpl) then,
  ) = __$$RoleApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    String message,
    RoleModel? data,
    List<String> errors,
  });

  @override
  $RoleModelCopyWith<$Res>? get data;
}

/// @nodoc
class __$$RoleApiResponseImplCopyWithImpl<$Res>
    extends _$RoleApiResponseCopyWithImpl<$Res, _$RoleApiResponseImpl>
    implements _$$RoleApiResponseImplCopyWith<$Res> {
  __$$RoleApiResponseImplCopyWithImpl(
    _$RoleApiResponseImpl _value,
    $Res Function(_$RoleApiResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoleApiResponse
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
      _$RoleApiResponseImpl(
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
                  as RoleModel?,
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
class _$RoleApiResponseImpl implements _RoleApiResponse {
  const _$RoleApiResponseImpl({
    required this.success,
    required this.message,
    this.data,
    final List<String> errors = const [],
  }) : _errors = errors;

  factory _$RoleApiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoleApiResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final RoleModel? data;
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
    return 'RoleApiResponse(success: $success, message: $message, data: $data, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoleApiResponseImpl &&
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

  /// Create a copy of RoleApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoleApiResponseImplCopyWith<_$RoleApiResponseImpl> get copyWith =>
      __$$RoleApiResponseImplCopyWithImpl<_$RoleApiResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RoleApiResponseImplToJson(this);
  }
}

abstract class _RoleApiResponse implements RoleApiResponse {
  const factory _RoleApiResponse({
    required final bool success,
    required final String message,
    final RoleModel? data,
    final List<String> errors,
  }) = _$RoleApiResponseImpl;

  factory _RoleApiResponse.fromJson(Map<String, dynamic> json) =
      _$RoleApiResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  RoleModel? get data;
  @override
  List<String> get errors;

  /// Create a copy of RoleApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoleApiResponseImplCopyWith<_$RoleApiResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RolesListApiResponse _$RolesListApiResponseFromJson(Map<String, dynamic> json) {
  return _RolesListApiResponse.fromJson(json);
}

/// @nodoc
mixin _$RolesListApiResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<RoleModel> get data => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;

  /// Serializes this RolesListApiResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RolesListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RolesListApiResponseCopyWith<RolesListApiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RolesListApiResponseCopyWith<$Res> {
  factory $RolesListApiResponseCopyWith(
    RolesListApiResponse value,
    $Res Function(RolesListApiResponse) then,
  ) = _$RolesListApiResponseCopyWithImpl<$Res, RolesListApiResponse>;
  @useResult
  $Res call({
    bool success,
    String message,
    List<RoleModel> data,
    List<String> errors,
  });
}

/// @nodoc
class _$RolesListApiResponseCopyWithImpl<
  $Res,
  $Val extends RolesListApiResponse
>
    implements $RolesListApiResponseCopyWith<$Res> {
  _$RolesListApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RolesListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
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
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<RoleModel>,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RolesListApiResponseImplCopyWith<$Res>
    implements $RolesListApiResponseCopyWith<$Res> {
  factory _$$RolesListApiResponseImplCopyWith(
    _$RolesListApiResponseImpl value,
    $Res Function(_$RolesListApiResponseImpl) then,
  ) = __$$RolesListApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    String message,
    List<RoleModel> data,
    List<String> errors,
  });
}

/// @nodoc
class __$$RolesListApiResponseImplCopyWithImpl<$Res>
    extends _$RolesListApiResponseCopyWithImpl<$Res, _$RolesListApiResponseImpl>
    implements _$$RolesListApiResponseImplCopyWith<$Res> {
  __$$RolesListApiResponseImplCopyWithImpl(
    _$RolesListApiResponseImpl _value,
    $Res Function(_$RolesListApiResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RolesListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
    Object? errors = null,
  }) {
    return _then(
      _$RolesListApiResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<RoleModel>,
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
class _$RolesListApiResponseImpl implements _RolesListApiResponse {
  const _$RolesListApiResponseImpl({
    required this.success,
    required this.message,
    final List<RoleModel> data = const [],
    final List<String> errors = const [],
  }) : _data = data,
       _errors = errors;

  factory _$RolesListApiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RolesListApiResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  final List<RoleModel> _data;
  @override
  @JsonKey()
  List<RoleModel> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

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
    return 'RolesListApiResponse(success: $success, message: $message, data: $data, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RolesListApiResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    message,
    const DeepCollectionEquality().hash(_data),
    const DeepCollectionEquality().hash(_errors),
  );

  /// Create a copy of RolesListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RolesListApiResponseImplCopyWith<_$RolesListApiResponseImpl>
  get copyWith =>
      __$$RolesListApiResponseImplCopyWithImpl<_$RolesListApiResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RolesListApiResponseImplToJson(this);
  }
}

abstract class _RolesListApiResponse implements RolesListApiResponse {
  const factory _RolesListApiResponse({
    required final bool success,
    required final String message,
    final List<RoleModel> data,
    final List<String> errors,
  }) = _$RolesListApiResponseImpl;

  factory _RolesListApiResponse.fromJson(Map<String, dynamic> json) =
      _$RolesListApiResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  List<RoleModel> get data;
  @override
  List<String> get errors;

  /// Create a copy of RolesListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RolesListApiResponseImplCopyWith<_$RolesListApiResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PermissionApiResponse _$PermissionApiResponseFromJson(
  Map<String, dynamic> json,
) {
  return _PermissionApiResponse.fromJson(json);
}

/// @nodoc
mixin _$PermissionApiResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  PermissionModel? get data => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;

  /// Serializes this PermissionApiResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PermissionApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PermissionApiResponseCopyWith<PermissionApiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PermissionApiResponseCopyWith<$Res> {
  factory $PermissionApiResponseCopyWith(
    PermissionApiResponse value,
    $Res Function(PermissionApiResponse) then,
  ) = _$PermissionApiResponseCopyWithImpl<$Res, PermissionApiResponse>;
  @useResult
  $Res call({
    bool success,
    String message,
    PermissionModel? data,
    List<String> errors,
  });

  $PermissionModelCopyWith<$Res>? get data;
}

/// @nodoc
class _$PermissionApiResponseCopyWithImpl<
  $Res,
  $Val extends PermissionApiResponse
>
    implements $PermissionApiResponseCopyWith<$Res> {
  _$PermissionApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PermissionApiResponse
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
                      as PermissionModel?,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of PermissionApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PermissionModelCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $PermissionModelCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PermissionApiResponseImplCopyWith<$Res>
    implements $PermissionApiResponseCopyWith<$Res> {
  factory _$$PermissionApiResponseImplCopyWith(
    _$PermissionApiResponseImpl value,
    $Res Function(_$PermissionApiResponseImpl) then,
  ) = __$$PermissionApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    String message,
    PermissionModel? data,
    List<String> errors,
  });

  @override
  $PermissionModelCopyWith<$Res>? get data;
}

/// @nodoc
class __$$PermissionApiResponseImplCopyWithImpl<$Res>
    extends
        _$PermissionApiResponseCopyWithImpl<$Res, _$PermissionApiResponseImpl>
    implements _$$PermissionApiResponseImplCopyWith<$Res> {
  __$$PermissionApiResponseImplCopyWithImpl(
    _$PermissionApiResponseImpl _value,
    $Res Function(_$PermissionApiResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PermissionApiResponse
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
      _$PermissionApiResponseImpl(
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
                  as PermissionModel?,
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
class _$PermissionApiResponseImpl implements _PermissionApiResponse {
  const _$PermissionApiResponseImpl({
    required this.success,
    required this.message,
    this.data,
    final List<String> errors = const [],
  }) : _errors = errors;

  factory _$PermissionApiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PermissionApiResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final PermissionModel? data;
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
    return 'PermissionApiResponse(success: $success, message: $message, data: $data, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionApiResponseImpl &&
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

  /// Create a copy of PermissionApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionApiResponseImplCopyWith<_$PermissionApiResponseImpl>
  get copyWith =>
      __$$PermissionApiResponseImplCopyWithImpl<_$PermissionApiResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PermissionApiResponseImplToJson(this);
  }
}

abstract class _PermissionApiResponse implements PermissionApiResponse {
  const factory _PermissionApiResponse({
    required final bool success,
    required final String message,
    final PermissionModel? data,
    final List<String> errors,
  }) = _$PermissionApiResponseImpl;

  factory _PermissionApiResponse.fromJson(Map<String, dynamic> json) =
      _$PermissionApiResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  PermissionModel? get data;
  @override
  List<String> get errors;

  /// Create a copy of PermissionApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PermissionApiResponseImplCopyWith<_$PermissionApiResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PermissionsListApiResponse _$PermissionsListApiResponseFromJson(
  Map<String, dynamic> json,
) {
  return _PermissionsListApiResponse.fromJson(json);
}

/// @nodoc
mixin _$PermissionsListApiResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<PermissionModel> get data => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;

  /// Serializes this PermissionsListApiResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PermissionsListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PermissionsListApiResponseCopyWith<PermissionsListApiResponse>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PermissionsListApiResponseCopyWith<$Res> {
  factory $PermissionsListApiResponseCopyWith(
    PermissionsListApiResponse value,
    $Res Function(PermissionsListApiResponse) then,
  ) =
      _$PermissionsListApiResponseCopyWithImpl<
        $Res,
        PermissionsListApiResponse
      >;
  @useResult
  $Res call({
    bool success,
    String message,
    List<PermissionModel> data,
    List<String> errors,
  });
}

/// @nodoc
class _$PermissionsListApiResponseCopyWithImpl<
  $Res,
  $Val extends PermissionsListApiResponse
>
    implements $PermissionsListApiResponseCopyWith<$Res> {
  _$PermissionsListApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PermissionsListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
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
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<PermissionModel>,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PermissionsListApiResponseImplCopyWith<$Res>
    implements $PermissionsListApiResponseCopyWith<$Res> {
  factory _$$PermissionsListApiResponseImplCopyWith(
    _$PermissionsListApiResponseImpl value,
    $Res Function(_$PermissionsListApiResponseImpl) then,
  ) = __$$PermissionsListApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    String message,
    List<PermissionModel> data,
    List<String> errors,
  });
}

/// @nodoc
class __$$PermissionsListApiResponseImplCopyWithImpl<$Res>
    extends
        _$PermissionsListApiResponseCopyWithImpl<
          $Res,
          _$PermissionsListApiResponseImpl
        >
    implements _$$PermissionsListApiResponseImplCopyWith<$Res> {
  __$$PermissionsListApiResponseImplCopyWithImpl(
    _$PermissionsListApiResponseImpl _value,
    $Res Function(_$PermissionsListApiResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PermissionsListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? data = null,
    Object? errors = null,
  }) {
    return _then(
      _$PermissionsListApiResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<PermissionModel>,
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
class _$PermissionsListApiResponseImpl implements _PermissionsListApiResponse {
  const _$PermissionsListApiResponseImpl({
    required this.success,
    required this.message,
    final List<PermissionModel> data = const [],
    final List<String> errors = const [],
  }) : _data = data,
       _errors = errors;

  factory _$PermissionsListApiResponseImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$PermissionsListApiResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  final List<PermissionModel> _data;
  @override
  @JsonKey()
  List<PermissionModel> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

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
    return 'PermissionsListApiResponse(success: $success, message: $message, data: $data, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionsListApiResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    message,
    const DeepCollectionEquality().hash(_data),
    const DeepCollectionEquality().hash(_errors),
  );

  /// Create a copy of PermissionsListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionsListApiResponseImplCopyWith<_$PermissionsListApiResponseImpl>
  get copyWith =>
      __$$PermissionsListApiResponseImplCopyWithImpl<
        _$PermissionsListApiResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PermissionsListApiResponseImplToJson(this);
  }
}

abstract class _PermissionsListApiResponse
    implements PermissionsListApiResponse {
  const factory _PermissionsListApiResponse({
    required final bool success,
    required final String message,
    final List<PermissionModel> data,
    final List<String> errors,
  }) = _$PermissionsListApiResponseImpl;

  factory _PermissionsListApiResponse.fromJson(Map<String, dynamic> json) =
      _$PermissionsListApiResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  List<PermissionModel> get data;
  @override
  List<String> get errors;

  /// Create a copy of PermissionsListApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PermissionsListApiResponseImplCopyWith<_$PermissionsListApiResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PermissionCheckResponse _$PermissionCheckResponseFromJson(
  Map<String, dynamic> json,
) {
  return _PermissionCheckResponse.fromJson(json);
}

/// @nodoc
mixin _$PermissionCheckResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  bool get hasPermission => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;

  /// Serializes this PermissionCheckResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PermissionCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PermissionCheckResponseCopyWith<PermissionCheckResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PermissionCheckResponseCopyWith<$Res> {
  factory $PermissionCheckResponseCopyWith(
    PermissionCheckResponse value,
    $Res Function(PermissionCheckResponse) then,
  ) = _$PermissionCheckResponseCopyWithImpl<$Res, PermissionCheckResponse>;
  @useResult
  $Res call({
    bool success,
    String message,
    bool hasPermission,
    List<String> errors,
  });
}

/// @nodoc
class _$PermissionCheckResponseCopyWithImpl<
  $Res,
  $Val extends PermissionCheckResponse
>
    implements $PermissionCheckResponseCopyWith<$Res> {
  _$PermissionCheckResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PermissionCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? hasPermission = null,
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
            hasPermission: null == hasPermission
                ? _value.hasPermission
                : hasPermission // ignore: cast_nullable_to_non_nullable
                      as bool,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PermissionCheckResponseImplCopyWith<$Res>
    implements $PermissionCheckResponseCopyWith<$Res> {
  factory _$$PermissionCheckResponseImplCopyWith(
    _$PermissionCheckResponseImpl value,
    $Res Function(_$PermissionCheckResponseImpl) then,
  ) = __$$PermissionCheckResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    String message,
    bool hasPermission,
    List<String> errors,
  });
}

/// @nodoc
class __$$PermissionCheckResponseImplCopyWithImpl<$Res>
    extends
        _$PermissionCheckResponseCopyWithImpl<
          $Res,
          _$PermissionCheckResponseImpl
        >
    implements _$$PermissionCheckResponseImplCopyWith<$Res> {
  __$$PermissionCheckResponseImplCopyWithImpl(
    _$PermissionCheckResponseImpl _value,
    $Res Function(_$PermissionCheckResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PermissionCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? hasPermission = null,
    Object? errors = null,
  }) {
    return _then(
      _$PermissionCheckResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        hasPermission: null == hasPermission
            ? _value.hasPermission
            : hasPermission // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$PermissionCheckResponseImpl implements _PermissionCheckResponse {
  const _$PermissionCheckResponseImpl({
    required this.success,
    required this.message,
    this.hasPermission = false,
    final List<String> errors = const [],
  }) : _errors = errors;

  factory _$PermissionCheckResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PermissionCheckResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  @JsonKey()
  final bool hasPermission;
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
    return 'PermissionCheckResponse(success: $success, message: $message, hasPermission: $hasPermission, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionCheckResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.hasPermission, hasPermission) ||
                other.hasPermission == hasPermission) &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    message,
    hasPermission,
    const DeepCollectionEquality().hash(_errors),
  );

  /// Create a copy of PermissionCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionCheckResponseImplCopyWith<_$PermissionCheckResponseImpl>
  get copyWith =>
      __$$PermissionCheckResponseImplCopyWithImpl<
        _$PermissionCheckResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PermissionCheckResponseImplToJson(this);
  }
}

abstract class _PermissionCheckResponse implements PermissionCheckResponse {
  const factory _PermissionCheckResponse({
    required final bool success,
    required final String message,
    final bool hasPermission,
    final List<String> errors,
  }) = _$PermissionCheckResponseImpl;

  factory _PermissionCheckResponse.fromJson(Map<String, dynamic> json) =
      _$PermissionCheckResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  bool get hasPermission;
  @override
  List<String> get errors;

  /// Create a copy of PermissionCheckResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PermissionCheckResponseImplCopyWith<_$PermissionCheckResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}
