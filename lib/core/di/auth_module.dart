import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../config/environment_config.dart';
import '../../features/authentication/data/datasources/auth_api_service.dart';

@module
abstract class AuthModule {
  @lazySingleton
  AuthApiService authApiService(Dio dio) {
    return AuthApiService(dio, baseUrl: EnvironmentConfig.apiBaseUrl);
  }
}
