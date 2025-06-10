import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../application/authorization_bloc.dart';
import '../domain/guards/authorization_guard.dart';
import '../domain/repositories/authorization_repository.dart';
import '../domain/services/authorization_service.dart';
import '../infrastructure/middleware/authorization_middleware.dart';
import '../infrastructure/repositories/api_authorization_repository.dart';
import '../infrastructure/services/authorization_api_service.dart';

/// Initialize authorization dependencies
void configureAuthorizationDependencies() {
  final getIt = GetIt.instance;

  // Register authorization API service
  if (!getIt.isRegistered<AuthorizationApiService>()) {
    getIt.registerLazySingleton<AuthorizationApiService>(
      () => DioAuthorizationApiService(getIt<Dio>()),
    );
  }

  // Register authorization repository
  if (!getIt.isRegistered<AuthorizationRepository>()) {
    getIt.registerLazySingleton<AuthorizationRepository>(
      () => ApiAuthorizationRepository(
        dio: getIt<Dio>(),
        secureStorage: getIt<FlutterSecureStorage>(),
      ),
    );
  }

  // Register authorization service
  if (!getIt.isRegistered<AuthorizationService>()) {
    getIt.registerLazySingleton<AuthorizationService>(
      () => AuthorizationService(getIt<AuthorizationRepository>()),
    );
  }

  // Register authorization guard
  if (!getIt.isRegistered<AuthorizationGuard>()) {
    getIt.registerLazySingleton<AuthorizationGuard>(
      () => AuthorizationGuard(getIt<AuthorizationService>()),
    );
  }

  // Register authorization middleware
  if (!getIt.isRegistered<AuthorizationMiddleware>()) {
    getIt.registerLazySingleton<AuthorizationMiddleware>(
      () => AuthorizationMiddleware(
        authorizationGuard: getIt<AuthorizationGuard>(),
      ),
    );
  }

  // Register authorization bloc factory
  if (!getIt.isRegistered<AuthorizationBloc>()) {
    getIt.registerFactory<AuthorizationBloc>(
      () => AuthorizationBloc(
        authorizationService: getIt<AuthorizationService>(),
      ),
    );
  }
}
