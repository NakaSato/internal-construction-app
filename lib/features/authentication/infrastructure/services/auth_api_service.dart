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
  Future<AuthResponseModel> login(@Body() LoginRequestModel request);

  /// Register a new user
  @POST('/api/v1/auth/register')
  Future<AuthResponseModel> register(@Body() RegisterRequestModel request);

  /// Refresh authentication token
  @POST('/api/v1/auth/refresh')
  Future<RefreshTokenResponseModel> refreshToken(
    @Body() RefreshTokenRequestModel request,
  );

  /// Logout user (if endpoint exists)
  @POST('/api/v1/auth/logout')
  Future<void> logout();

  /// Get current user profile
  @GET('/api/v1/auth/profile')
  Future<AuthResponseModel> getProfile();
}
