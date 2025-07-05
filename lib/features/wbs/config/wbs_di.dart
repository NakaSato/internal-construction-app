import 'package:get_it/get_it.dart';
import '../domain/repositories/wbs_repository.dart';
import '../infrastructure/repositories/wbs_repository_impl.dart';
import '../infrastructure/services/wbs_api_service.dart';
import '../domain/usecases/wbs_usecases.dart';

/// Configuration for WBS (Work Breakdown Structure) dependencies
class WbsDI {
  static void configure(GetIt getIt) {
    // Register API service
    if (!getIt.isRegistered<WBSApiService>()) {
      getIt.registerLazySingleton<WBSApiService>(() => WBSApiService(getIt()));
    }

    // Register repository
    if (!getIt.isRegistered<WbsRepository>()) {
      getIt.registerLazySingleton<WbsRepository>(() => WbsRepositoryImpl(getIt()));
    }

    // Register use cases
    if (!getIt.isRegistered<GetProjectWbs>()) {
      getIt.registerLazySingleton<GetProjectWbs>(() => GetProjectWbs(getIt()));
    }

    if (!getIt.isRegistered<GetWbsTask>()) {
      getIt.registerLazySingleton<GetWbsTask>(() => GetWbsTask(getIt()));
    }

    if (!getIt.isRegistered<CreateWbsTask>()) {
      getIt.registerLazySingleton<CreateWbsTask>(() => CreateWbsTask(getIt()));
    }

    if (!getIt.isRegistered<UpdateWbsTask>()) {
      getIt.registerLazySingleton<UpdateWbsTask>(() => UpdateWbsTask(getIt()));
    }

    if (!getIt.isRegistered<UpdateTaskStatus>()) {
      getIt.registerLazySingleton<UpdateTaskStatus>(() => UpdateTaskStatus(getIt()));
    }

    if (!getIt.isRegistered<DeleteWbsTask>()) {
      getIt.registerLazySingleton<DeleteWbsTask>(() => DeleteWbsTask(getIt()));
    }

    print('✅ WBS dependencies configured successfully');
  }
}
