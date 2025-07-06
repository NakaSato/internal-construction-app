import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/auth_response_model.dart';

part 'auth_api_service.g.dart';

/// REST API service for authentication endpoints
@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  /// Login with username and password
  @POST('/api/v1/auth/login')
  Future<LoginResponseApiResponse> login(@Body() LoginRequestModel request);

  /// Register a new user
  @POST('/api/v1/auth/register')
  Future<UserDtoApiResponse> register(@Body() RegisterRequestModel request);

  /// Refresh authentication token
  @POST('/api/v1/auth/refresh')
  Future<StringApiResponse> refreshToken(@Body() String refreshToken);

  /// Logout current user
  @POST('/api/v1/auth/logout')
  Future<void> logout();
}
