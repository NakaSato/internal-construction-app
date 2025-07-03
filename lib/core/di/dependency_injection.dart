import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../features/project_management/infrastructure/datasources/project_remote_data_source.dart';
import '../../features/project_management/infrastructure/repositories/project_repository_impl.dart';
import '../../features/project_management/domain/repositories/project_repository.dart';
import '../../features/project_management/application/project_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Configure enhanced project management dependencies (without Dio registration)
  await _configureEnhancedProjectManagementDependencies();

  // TODO: Configure other feature dependencies when DI files are created
  // configureDailyReportsDependencies();
}

/// Configure enhanced project management dependencies
Future<void> _configureEnhancedProjectManagementDependencies() async {
  // Check if Dio is available (it should be registered by Injectable system)
  if (!getIt.isRegistered<Dio>()) {
    throw Exception(
      'Dio should be registered by Injectable system before calling this function',
    );
  }

  // Don't override Injectable registrations - the Injectable system
  // already handles EnhancedProjectRepository registration based on environment:
  // - Dev/Test: MockProjectRepository
  // - Prod: ApiProjectRepository
  //
  // If for some reason Injectable doesn't register it, fall back to manual registration
  if (!getIt.isRegistered<EnhancedProjectRepository>()) {
    print(
      'Warning: EnhancedProjectRepository not registered by Injectable system, falling back to manual registration',
    );

    // Enhanced Project Management Data Sources
    if (!getIt.isRegistered<ProjectRemoteDataSource>()) {
      getIt.registerLazySingleton<ProjectRemoteDataSource>(
        () => ProjectRemoteDataSourceImpl(dio: getIt<Dio>()),
      );
    }

    // Enhanced Project Management Repositories - Use mock for development
    getIt.registerLazySingleton<EnhancedProjectRepository>(
      () => EnhancedProjectRepositoryImpl(getIt<ProjectRemoteDataSource>()),
    );
  }

  // Enhanced Project Management BLoCs - Only register if not already registered
  if (!getIt.isRegistered<EnhancedProjectBloc>()) {
    getIt.registerFactory<EnhancedProjectBloc>(
      () => EnhancedProjectBloc(repository: getIt<EnhancedProjectRepository>()),
    );
  }
}
