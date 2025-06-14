import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../domain/repositories/project_repository.dart';
import '../infrastructure/repositories/api_project_repository.dart';
import '../infrastructure/repositories/mock_project_repository.dart';
import '../infrastructure/repositories/fallback_project_repository.dart';
import '../infrastructure/services/project_api_service.dart';

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

  // Register API service
  getIt.registerLazySingleton<ProjectApiService>(
    () => ProjectApiService(getIt<Dio>()),
  );

  // Register individual repositories
  getIt.registerLazySingleton<ApiProjectRepository>(
    () => ApiProjectRepository(getIt<ProjectApiService>()),
  );

  getIt.registerLazySingleton<MockProjectRepository>(
    () => const MockProjectRepository(),
  );

  // Register fallback repository as the 'api' instance
  // This will try API first, then fallback to mock data
  getIt.registerLazySingleton<ProjectRepository>(
    () => FallbackProjectRepository(
      getIt<ApiProjectRepository>(),
      getIt<MockProjectRepository>(),
    ),
    instanceName: 'api',
  );
}
