import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';

import '../../features/authentication/data/datasources/auth_api_service.dart';

@module
abstract class AuthModule {
  @lazySingleton
  AuthApiService authApiService(Dio dio) {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
    return AuthApiService(dio, baseUrl: baseUrl);
  }
}
