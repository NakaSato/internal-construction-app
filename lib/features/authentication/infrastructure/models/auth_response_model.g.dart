// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthResponseModelImpl _$$AuthResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$AuthResponseModelImpl(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] == null
      ? null
      : AuthDataModel.fromJson(json['data'] as Map<String, dynamic>),
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$AuthResponseModelImplToJson(
  _$AuthResponseModelImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
};

_$AuthDataModelImpl _$$AuthDataModelImplFromJson(Map<String, dynamic> json) =>
    _$AuthDataModelImpl(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthDataModelImplToJson(_$AuthDataModelImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'refreshToken': instance.refreshToken,
      'user': instance.user,
    };

_$LoginRequestModelImpl _$$LoginRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$LoginRequestModelImpl(
  username: json['username'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$$LoginRequestModelImplToJson(
  _$LoginRequestModelImpl instance,
) => <String, dynamic>{
  'username': instance.username,
  'password': instance.password,
};

_$RegisterRequestModelImpl _$$RegisterRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$RegisterRequestModelImpl(
  username: json['username'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  fullName: json['fullName'] as String,
  roleId: (json['roleId'] as num).toInt(),
);

Map<String, dynamic> _$$RegisterRequestModelImplToJson(
  _$RegisterRequestModelImpl instance,
) => <String, dynamic>{
  'username': instance.username,
  'email': instance.email,
  'password': instance.password,
  'fullName': instance.fullName,
  'roleId': instance.roleId,
};

_$RefreshTokenRequestModelImpl _$$RefreshTokenRequestModelImplFromJson(
  Map<String, dynamic> json,
) => _$RefreshTokenRequestModelImpl(
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$$RefreshTokenRequestModelImplToJson(
  _$RefreshTokenRequestModelImpl instance,
) => <String, dynamic>{'refreshToken': instance.refreshToken};

_$RefreshTokenResponseModelImpl _$$RefreshTokenResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$RefreshTokenResponseModelImpl(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: json['data'] as String?,
  errors:
      (json['errors'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$$RefreshTokenResponseModelImplToJson(
  _$RefreshTokenResponseModelImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data,
  'errors': instance.errors,
};
