import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../features/project_management/infrastructure/datasources/project_remote_data_source.dart';
import '../../features/project_management/infrastructure/repositories/project_repository_impl.dart';
import '../../features/project_management/domain/repositories/project_repository.dart';
import '../../features/project_management/application/project_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core services
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Register base URL for features
  getIt.registerLazySingleton<String>(() => 'https://api.example.com');

  // Configure enhanced project management dependencies
  await _configureEnhancedProjectManagementDependencies();

  // TODO: Configure other feature dependencies when DI files are created
  // configureDailyReportsDependencies();
}

/// Configure enhanced project management dependencies
Future<void> _configureEnhancedProjectManagementDependencies() async {
  // Enhanced Project Management Data Sources
  getIt.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Enhanced Project Management Repositories
  getIt.registerLazySingleton<EnhancedProjectRepository>(
    () => EnhancedProjectRepositoryImpl(getIt<ProjectRemoteDataSource>()),
  );

  // Enhanced Project Management BLoCs
  getIt.registerFactory<EnhancedProjectBloc>(
    () => EnhancedProjectBloc(repository: getIt<EnhancedProjectRepository>()),
  );
}
