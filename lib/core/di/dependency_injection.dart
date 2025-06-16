import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/domain/usecases/get_project_detail.dart';
import '../../features/projects/infrastructure/datasources/project_remote_datasource.dart';
import '../../features/projects/infrastructure/repositories/project_repository_impl.dart';
import '../../features/projects/application/cubits/project_detail_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Data sources
  getIt.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(getIt<Dio>()),
  );

  // Repositories
  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton<GetProjectDetail>(
    () => GetProjectDetail(getIt()),
  );

  // Cubits
  getIt.registerFactory<ProjectDetailCubit>(() => ProjectDetailCubit(getIt()));
}
