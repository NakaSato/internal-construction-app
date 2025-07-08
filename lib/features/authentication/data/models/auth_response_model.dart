import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart';

part 'auth_response_model.freezed.dart';
part 'auth_response_model.g.dart';

/// Response model for login API calls
@freezed
class LoginResponseApiResponse with _$LoginResponseApiResponse {
  const factory LoginResponseApiResponse({
    required bool success,
    required String message,
    LoginResponse? data,
    @Default([]) List<String> errors,
  }) = _LoginResponseApiResponse;

  factory LoginResponseApiResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseApiResponseFromJson(json);
}

/// Login response data model
@freezed
class LoginResponse with _$LoginResponse {
  const factory LoginResponse({String? token, String? refreshToken, required UserModel user}) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
}

/// Response model for refresh token API calls
@freezed
class StringApiResponse with _$StringApiResponse {
  const factory StringApiResponse({
    required bool success,
    required String message,
    String? data,
    @Default([]) List<String> errors,
  }) = _StringApiResponse;

  factory StringApiResponse.fromJson(Map<String, dynamic> json) => _$StringApiResponseFromJson(json);
}

/// Login request model
@freezed
class LoginRequestModel with _$LoginRequestModel {
  const factory LoginRequestModel({required String username, required String password}) = _LoginRequestModel;

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) => _$LoginRequestModelFromJson(json);
}
