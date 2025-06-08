// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LoginResponseApiResponse _$LoginResponseApiResponseFromJson(
  Map<String, dynamic> json,
) {
  return _LoginResponseApiResponse.fromJson(json);
}

/// @nodoc
mixin _$LoginResponseApiResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  LoginResponse? get data => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;

  /// Serializes this LoginResponseApiResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginResponseApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginResponseApiResponseCopyWith<LoginResponseApiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginResponseApiResponseCopyWith<$Res> {
  factory $LoginResponseApiResponseCopyWith(
    LoginResponseApiResponse value,
    $Res Function(LoginResponseApiResponse) then,
  ) = _$LoginResponseApiResponseCopyWithImpl<$Res, LoginResponseApiResponse>;
  @useResult
  $Res call({
    bool success,
    String message,
    LoginResponse? data,
    List<String> errors,
  });

  $LoginResponseCopyWith<$Res>? get data;
}

/// @nodoc
class _$LoginResponseApiResponseCopyWithImpl<
  $Res,
  $Val extends LoginResponseApiResponse
>
    implements $LoginResponseApiResponseCopyWith<$Res> {
  _$LoginResponseApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginResponseApiResponse
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
                      as LoginResponse?,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of LoginResponseApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LoginResponseCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $LoginResponseCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LoginResponseApiResponseImplCopyWith<$Res>
    implements $LoginResponseApiResponseCopyWith<$Res> {
  factory _$$LoginResponseApiResponseImplCopyWith(
    _$LoginResponseApiResponseImpl value,
    $Res Function(_$LoginResponseApiResponseImpl) then,
  ) = __$$LoginResponseApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    String message,
    LoginResponse? data,
    List<String> errors,
  });

  @override
  $LoginResponseCopyWith<$Res>? get data;
}

/// @nodoc
class __$$LoginResponseApiResponseImplCopyWithImpl<$Res>
    extends
        _$LoginResponseApiResponseCopyWithImpl<
          $Res,
          _$LoginResponseApiResponseImpl
        >
    implements _$$LoginResponseApiResponseImplCopyWith<$Res> {
  __$$LoginResponseApiResponseImplCopyWithImpl(
    _$LoginResponseApiResponseImpl _value,
    $Res Function(_$LoginResponseApiResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginResponseApiResponse
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
      _$LoginResponseApiResponseImpl(
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
                  as LoginResponse?,
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
class _$LoginResponseApiResponseImpl implements _LoginResponseApiResponse {
  const _$LoginResponseApiResponseImpl({
    required this.success,
    required this.message,
    this.data,
    final List<String> errors = const [],
  }) : _errors = errors;

  factory _$LoginResponseApiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginResponseApiResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final LoginResponse? data;
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
    return 'LoginResponseApiResponse(success: $success, message: $message, data: $data, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginResponseApiResponseImpl &&
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

  /// Create a copy of LoginResponseApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginResponseApiResponseImplCopyWith<_$LoginResponseApiResponseImpl>
  get copyWith =>
      __$$LoginResponseApiResponseImplCopyWithImpl<
        _$LoginResponseApiResponseImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginResponseApiResponseImplToJson(this);
  }
}

abstract class _LoginResponseApiResponse implements LoginResponseApiResponse {
  const factory _LoginResponseApiResponse({
    required final bool success,
    required final String message,
    final LoginResponse? data,
    final List<String> errors,
  }) = _$LoginResponseApiResponseImpl;

  factory _LoginResponseApiResponse.fromJson(Map<String, dynamic> json) =
      _$LoginResponseApiResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  LoginResponse? get data;
  @override
  List<String> get errors;

  /// Create a copy of LoginResponseApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginResponseApiResponseImplCopyWith<_$LoginResponseApiResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) {
  return _LoginResponse.fromJson(json);
}

/// @nodoc
mixin _$LoginResponse {
  String? get token => throw _privateConstructorUsedError;
  String? get refreshToken => throw _privateConstructorUsedError;
  UserModel get user => throw _privateConstructorUsedError;

  /// Serializes this LoginResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginResponseCopyWith<LoginResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginResponseCopyWith<$Res> {
  factory $LoginResponseCopyWith(
    LoginResponse value,
    $Res Function(LoginResponse) then,
  ) = _$LoginResponseCopyWithImpl<$Res, LoginResponse>;
  @useResult
  $Res call({String? token, String? refreshToken, UserModel user});

  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class _$LoginResponseCopyWithImpl<$Res, $Val extends LoginResponse>
    implements $LoginResponseCopyWith<$Res> {
  _$LoginResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = freezed,
    Object? refreshToken = freezed,
    Object? user = null,
  }) {
    return _then(
      _value.copyWith(
            token: freezed == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String?,
            refreshToken: freezed == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            user: null == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as UserModel,
          )
          as $Val,
    );
  }

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res> get user {
    return $UserModelCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LoginResponseImplCopyWith<$Res>
    implements $LoginResponseCopyWith<$Res> {
  factory _$$LoginResponseImplCopyWith(
    _$LoginResponseImpl value,
    $Res Function(_$LoginResponseImpl) then,
  ) = __$$LoginResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? token, String? refreshToken, UserModel user});

  @override
  $UserModelCopyWith<$Res> get user;
}

/// @nodoc
class __$$LoginResponseImplCopyWithImpl<$Res>
    extends _$LoginResponseCopyWithImpl<$Res, _$LoginResponseImpl>
    implements _$$LoginResponseImplCopyWith<$Res> {
  __$$LoginResponseImplCopyWithImpl(
    _$LoginResponseImpl _value,
    $Res Function(_$LoginResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = freezed,
    Object? refreshToken = freezed,
    Object? user = null,
  }) {
    return _then(
      _$LoginResponseImpl(
        token: freezed == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String?,
        refreshToken: freezed == refreshToken
            ? _value.refreshToken
            : refreshToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        user: null == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as UserModel,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginResponseImpl implements _LoginResponse {
  const _$LoginResponseImpl({
    this.token,
    this.refreshToken,
    required this.user,
  });

  factory _$LoginResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginResponseImplFromJson(json);

  @override
  final String? token;
  @override
  final String? refreshToken;
  @override
  final UserModel user;

  @override
  String toString() {
    return 'LoginResponse(token: $token, refreshToken: $refreshToken, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginResponseImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token, refreshToken, user);

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      __$$LoginResponseImplCopyWithImpl<_$LoginResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginResponseImplToJson(this);
  }
}

abstract class _LoginResponse implements LoginResponse {
  const factory _LoginResponse({
    final String? token,
    final String? refreshToken,
    required final UserModel user,
  }) = _$LoginResponseImpl;

  factory _LoginResponse.fromJson(Map<String, dynamic> json) =
      _$LoginResponseImpl.fromJson;

  @override
  String? get token;
  @override
  String? get refreshToken;
  @override
  UserModel get user;

  /// Create a copy of LoginResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginResponseImplCopyWith<_$LoginResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserDtoApiResponse _$UserDtoApiResponseFromJson(Map<String, dynamic> json) {
  return _UserDtoApiResponse.fromJson(json);
}

/// @nodoc
mixin _$UserDtoApiResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  UserModel? get data => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;

  /// Serializes this UserDtoApiResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserDtoApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDtoApiResponseCopyWith<UserDtoApiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDtoApiResponseCopyWith<$Res> {
  factory $UserDtoApiResponseCopyWith(
    UserDtoApiResponse value,
    $Res Function(UserDtoApiResponse) then,
  ) = _$UserDtoApiResponseCopyWithImpl<$Res, UserDtoApiResponse>;
  @useResult
  $Res call({
    bool success,
    String message,
    UserModel? data,
    List<String> errors,
  });

  $UserModelCopyWith<$Res>? get data;
}

/// @nodoc
class _$UserDtoApiResponseCopyWithImpl<$Res, $Val extends UserDtoApiResponse>
    implements $UserDtoApiResponseCopyWith<$Res> {
  _$UserDtoApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDtoApiResponse
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
                      as UserModel?,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of UserDtoApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserDtoApiResponseImplCopyWith<$Res>
    implements $UserDtoApiResponseCopyWith<$Res> {
  factory _$$UserDtoApiResponseImplCopyWith(
    _$UserDtoApiResponseImpl value,
    $Res Function(_$UserDtoApiResponseImpl) then,
  ) = __$$UserDtoApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    String message,
    UserModel? data,
    List<String> errors,
  });

  @override
  $UserModelCopyWith<$Res>? get data;
}

/// @nodoc
class __$$UserDtoApiResponseImplCopyWithImpl<$Res>
    extends _$UserDtoApiResponseCopyWithImpl<$Res, _$UserDtoApiResponseImpl>
    implements _$$UserDtoApiResponseImplCopyWith<$Res> {
  __$$UserDtoApiResponseImplCopyWithImpl(
    _$UserDtoApiResponseImpl _value,
    $Res Function(_$UserDtoApiResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserDtoApiResponse
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
      _$UserDtoApiResponseImpl(
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
                  as UserModel?,
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
class _$UserDtoApiResponseImpl implements _UserDtoApiResponse {
  const _$UserDtoApiResponseImpl({
    required this.success,
    required this.message,
    this.data,
    final List<String> errors = const [],
  }) : _errors = errors;

  factory _$UserDtoApiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDtoApiResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final UserModel? data;
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
    return 'UserDtoApiResponse(success: $success, message: $message, data: $data, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDtoApiResponseImpl &&
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

  /// Create a copy of UserDtoApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDtoApiResponseImplCopyWith<_$UserDtoApiResponseImpl> get copyWith =>
      __$$UserDtoApiResponseImplCopyWithImpl<_$UserDtoApiResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDtoApiResponseImplToJson(this);
  }
}

abstract class _UserDtoApiResponse implements UserDtoApiResponse {
  const factory _UserDtoApiResponse({
    required final bool success,
    required final String message,
    final UserModel? data,
    final List<String> errors,
  }) = _$UserDtoApiResponseImpl;

  factory _UserDtoApiResponse.fromJson(Map<String, dynamic> json) =
      _$UserDtoApiResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  UserModel? get data;
  @override
  List<String> get errors;

  /// Create a copy of UserDtoApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDtoApiResponseImplCopyWith<_$UserDtoApiResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StringApiResponse _$StringApiResponseFromJson(Map<String, dynamic> json) {
  return _StringApiResponse.fromJson(json);
}

/// @nodoc
mixin _$StringApiResponse {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String? get data => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;

  /// Serializes this StringApiResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StringApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StringApiResponseCopyWith<StringApiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StringApiResponseCopyWith<$Res> {
  factory $StringApiResponseCopyWith(
    StringApiResponse value,
    $Res Function(StringApiResponse) then,
  ) = _$StringApiResponseCopyWithImpl<$Res, StringApiResponse>;
  @useResult
  $Res call({bool success, String message, String? data, List<String> errors});
}

/// @nodoc
class _$StringApiResponseCopyWithImpl<$Res, $Val extends StringApiResponse>
    implements $StringApiResponseCopyWith<$Res> {
  _$StringApiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StringApiResponse
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
                      as String?,
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
abstract class _$$StringApiResponseImplCopyWith<$Res>
    implements $StringApiResponseCopyWith<$Res> {
  factory _$$StringApiResponseImplCopyWith(
    _$StringApiResponseImpl value,
    $Res Function(_$StringApiResponseImpl) then,
  ) = __$$StringApiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String message, String? data, List<String> errors});
}

/// @nodoc
class __$$StringApiResponseImplCopyWithImpl<$Res>
    extends _$StringApiResponseCopyWithImpl<$Res, _$StringApiResponseImpl>
    implements _$$StringApiResponseImplCopyWith<$Res> {
  __$$StringApiResponseImplCopyWithImpl(
    _$StringApiResponseImpl _value,
    $Res Function(_$StringApiResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StringApiResponse
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
      _$StringApiResponseImpl(
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
                  as String?,
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
class _$StringApiResponseImpl implements _StringApiResponse {
  const _$StringApiResponseImpl({
    required this.success,
    required this.message,
    this.data,
    final List<String> errors = const [],
  }) : _errors = errors;

  factory _$StringApiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$StringApiResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final String? data;
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
    return 'StringApiResponse(success: $success, message: $message, data: $data, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StringApiResponseImpl &&
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

  /// Create a copy of StringApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StringApiResponseImplCopyWith<_$StringApiResponseImpl> get copyWith =>
      __$$StringApiResponseImplCopyWithImpl<_$StringApiResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StringApiResponseImplToJson(this);
  }
}

abstract class _StringApiResponse implements StringApiResponse {
  const factory _StringApiResponse({
    required final bool success,
    required final String message,
    final String? data,
    final List<String> errors,
  }) = _$StringApiResponseImpl;

  factory _StringApiResponse.fromJson(Map<String, dynamic> json) =
      _$StringApiResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  String? get data;
  @override
  List<String> get errors;

  /// Create a copy of StringApiResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StringApiResponseImplCopyWith<_$StringApiResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LoginRequestModel _$LoginRequestModelFromJson(Map<String, dynamic> json) {
  return _LoginRequestModel.fromJson(json);
}

/// @nodoc
mixin _$LoginRequestModel {
  String get username => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  /// Serializes this LoginRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoginRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoginRequestModelCopyWith<LoginRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginRequestModelCopyWith<$Res> {
  factory $LoginRequestModelCopyWith(
    LoginRequestModel value,
    $Res Function(LoginRequestModel) then,
  ) = _$LoginRequestModelCopyWithImpl<$Res, LoginRequestModel>;
  @useResult
  $Res call({String username, String password});
}

/// @nodoc
class _$LoginRequestModelCopyWithImpl<$Res, $Val extends LoginRequestModel>
    implements $LoginRequestModelCopyWith<$Res> {
  _$LoginRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoginRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? username = null, Object? password = null}) {
    return _then(
      _value.copyWith(
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoginRequestModelImplCopyWith<$Res>
    implements $LoginRequestModelCopyWith<$Res> {
  factory _$$LoginRequestModelImplCopyWith(
    _$LoginRequestModelImpl value,
    $Res Function(_$LoginRequestModelImpl) then,
  ) = __$$LoginRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String username, String password});
}

/// @nodoc
class __$$LoginRequestModelImplCopyWithImpl<$Res>
    extends _$LoginRequestModelCopyWithImpl<$Res, _$LoginRequestModelImpl>
    implements _$$LoginRequestModelImplCopyWith<$Res> {
  __$$LoginRequestModelImplCopyWithImpl(
    _$LoginRequestModelImpl _value,
    $Res Function(_$LoginRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoginRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? username = null, Object? password = null}) {
    return _then(
      _$LoginRequestModelImpl(
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoginRequestModelImpl implements _LoginRequestModel {
  const _$LoginRequestModelImpl({
    required this.username,
    required this.password,
  });

  factory _$LoginRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoginRequestModelImplFromJson(json);

  @override
  final String username;
  @override
  final String password;

  @override
  String toString() {
    return 'LoginRequestModel(username: $username, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginRequestModelImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, username, password);

  /// Create a copy of LoginRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginRequestModelImplCopyWith<_$LoginRequestModelImpl> get copyWith =>
      __$$LoginRequestModelImplCopyWithImpl<_$LoginRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LoginRequestModelImplToJson(this);
  }
}

abstract class _LoginRequestModel implements LoginRequestModel {
  const factory _LoginRequestModel({
    required final String username,
    required final String password,
  }) = _$LoginRequestModelImpl;

  factory _LoginRequestModel.fromJson(Map<String, dynamic> json) =
      _$LoginRequestModelImpl.fromJson;

  @override
  String get username;
  @override
  String get password;

  /// Create a copy of LoginRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoginRequestModelImplCopyWith<_$LoginRequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RegisterRequestModel _$RegisterRequestModelFromJson(Map<String, dynamic> json) {
  return _RegisterRequestModel.fromJson(json);
}

/// @nodoc
mixin _$RegisterRequestModel {
  String get username => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  int get roleId => throw _privateConstructorUsedError;

  /// Serializes this RegisterRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RegisterRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterRequestModelCopyWith<RegisterRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterRequestModelCopyWith<$Res> {
  factory $RegisterRequestModelCopyWith(
    RegisterRequestModel value,
    $Res Function(RegisterRequestModel) then,
  ) = _$RegisterRequestModelCopyWithImpl<$Res, RegisterRequestModel>;
  @useResult
  $Res call({
    String username,
    String email,
    String password,
    String fullName,
    int roleId,
  });
}

/// @nodoc
class _$RegisterRequestModelCopyWithImpl<
  $Res,
  $Val extends RegisterRequestModel
>
    implements $RegisterRequestModelCopyWith<$Res> {
  _$RegisterRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? email = null,
    Object? password = null,
    Object? fullName = null,
    Object? roleId = null,
  }) {
    return _then(
      _value.copyWith(
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            password: null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            roleId: null == roleId
                ? _value.roleId
                : roleId // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RegisterRequestModelImplCopyWith<$Res>
    implements $RegisterRequestModelCopyWith<$Res> {
  factory _$$RegisterRequestModelImplCopyWith(
    _$RegisterRequestModelImpl value,
    $Res Function(_$RegisterRequestModelImpl) then,
  ) = __$$RegisterRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String username,
    String email,
    String password,
    String fullName,
    int roleId,
  });
}

/// @nodoc
class __$$RegisterRequestModelImplCopyWithImpl<$Res>
    extends _$RegisterRequestModelCopyWithImpl<$Res, _$RegisterRequestModelImpl>
    implements _$$RegisterRequestModelImplCopyWith<$Res> {
  __$$RegisterRequestModelImplCopyWithImpl(
    _$RegisterRequestModelImpl _value,
    $Res Function(_$RegisterRequestModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RegisterRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? username = null,
    Object? email = null,
    Object? password = null,
    Object? fullName = null,
    Object? roleId = null,
  }) {
    return _then(
      _$RegisterRequestModelImpl(
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        password: null == password
            ? _value.password
            : password // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        roleId: null == roleId
            ? _value.roleId
            : roleId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RegisterRequestModelImpl implements _RegisterRequestModel {
  const _$RegisterRequestModelImpl({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    required this.roleId,
  });

  factory _$RegisterRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RegisterRequestModelImplFromJson(json);

  @override
  final String username;
  @override
  final String email;
  @override
  final String password;
  @override
  final String fullName;
  @override
  final int roleId;

  @override
  String toString() {
    return 'RegisterRequestModel(username: $username, email: $email, password: $password, fullName: $fullName, roleId: $roleId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterRequestModelImpl &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.roleId, roleId) || other.roleId == roleId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, username, email, password, fullName, roleId);

  /// Create a copy of RegisterRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterRequestModelImplCopyWith<_$RegisterRequestModelImpl>
  get copyWith =>
      __$$RegisterRequestModelImplCopyWithImpl<_$RegisterRequestModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RegisterRequestModelImplToJson(this);
  }
}

abstract class _RegisterRequestModel implements RegisterRequestModel {
  const factory _RegisterRequestModel({
    required final String username,
    required final String email,
    required final String password,
    required final String fullName,
    required final int roleId,
  }) = _$RegisterRequestModelImpl;

  factory _RegisterRequestModel.fromJson(Map<String, dynamic> json) =
      _$RegisterRequestModelImpl.fromJson;

  @override
  String get username;
  @override
  String get email;
  @override
  String get password;
  @override
  String get fullName;
  @override
  int get roleId;

  /// Create a copy of RegisterRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterRequestModelImplCopyWith<_$RegisterRequestModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
