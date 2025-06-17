import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../domain/repositories/project_repository.dart';
import '../data/repositories/api_project_repository.dart';
import '../data/repositories/mock_project_repository.dart';
import '../data/repositories/fallback_project_repository.dart';
import '../data/datasources/project_api_service.dart';
import '../application/project_bloc.dart';

/// Configure project management dependencies
void configureProjectManagementDependencies() {
  final getIt = GetIt.instance;

  // Register Dio if not already registered
  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(() {
      final dio = Dio();
      dio.options.baseUrl = getIt<String>(); // Get base URL from DI
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      return dio;
    });
  }

  // Data sources
  if (!getIt.isRegistered<ProjectApiService>()) {
    getIt.registerLazySingleton<ProjectApiService>(
      () => ProjectApiService(getIt<Dio>()),
    );
  }

  // Repositories
  if (!getIt.isRegistered<MockProjectRepository>()) {
    getIt.registerLazySingleton<MockProjectRepository>(
      () => const MockProjectRepository(),
    );
  }

  if (!getIt.isRegistered<ApiProjectRepository>()) {
    getIt.registerLazySingleton<ApiProjectRepository>(
      () => ApiProjectRepository(getIt<ProjectApiService>()),
    );
  }

  // Register the fallback repository with the 'api' name as expected by ProjectBloc
  if (!getIt.isRegistered<ProjectRepository>(instanceName: 'api')) {
    getIt.registerLazySingleton<ProjectRepository>(
      () => FallbackProjectRepository(
        getIt<ApiProjectRepository>(),
        getIt<MockProjectRepository>(),
      ),
      instanceName: 'api',
    );
  }

  // BLoCs
  if (!getIt.isRegistered<ProjectBloc>()) {
    getIt.registerFactory<ProjectBloc>(
      () => ProjectBloc(getIt<ProjectRepository>(instanceName: 'api')),
    );
  }
}
