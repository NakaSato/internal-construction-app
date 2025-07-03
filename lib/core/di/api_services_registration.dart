import 'package:get_it/get_it.dart';

import '../network/api_client.dart';
import '../../features/authentication/infrastructure/services/auth_api_service.dart';
import '../../features/project_management/infrastructure/services/project_api_service.dart';
import '../../features/task_management/infrastructure/services/task_api_service.dart';
import '../../features/daily_reports/infrastructure/services/daily_reports_api_service.dart';
import '../../features/work_calendar/infrastructure/services/calendar_api_service.dart';

/// Helper class to register all API services with the dependency injection container
class ApiServicesRegistration {
  /// Register all API services with GetIt
  static void registerApiServices(GetIt getIt) {
    // Register API client first (if not already registered)
    if (!getIt.isRegistered<ApiClient>()) {
      getIt.registerLazySingleton<ApiClient>(() => ApiClient());
    }

    // Register authentication API service
    if (!getIt.isRegistered<AuthApiService>()) {
      getIt.registerLazySingleton<AuthApiService>(
        () => AuthApiService(getIt<ApiClient>()),
      );
    }

    // Register project management API service
    if (!getIt.isRegistered<ProjectApiService>()) {
      getIt.registerLazySingleton<ProjectApiService>(
        () => ProjectApiService(getIt<ApiClient>()),
      );
    }

    // Register task management API service
    if (!getIt.isRegistered<TaskApiService>()) {
      getIt.registerLazySingleton<TaskApiService>(
        () => TaskApiService(getIt<ApiClient>()),
      );
    }

    // Register daily reports API service
    if (!getIt.isRegistered<DailyReportsApiService>()) {
      getIt.registerLazySingleton<DailyReportsApiService>(
        () => DailyReportsApiService(getIt<ApiClient>()),
      );
    }

    // Register calendar API service
    if (!getIt.isRegistered<CalendarApiService>()) {
      getIt.registerLazySingleton<CalendarApiService>(
        () => CalendarApiService(getIt<ApiClient>()),
      );
    }

    print('✅ Registered all API services with dependency injection');
  }

  /// Unregister all API services (useful for testing)
  static void unregisterApiServices(GetIt getIt) {
    final services = [
      AuthApiService,
      ProjectApiService,
      TaskApiService,
      DailyReportsApiService,
      CalendarApiService,
      ApiClient,
    ];

    for (final serviceType in services) {
      if (getIt.isRegistered(instance: serviceType)) {
        getIt.unregister(instance: serviceType);
      }
    }

    print('🗑️ Unregistered all API services from dependency injection');
  }
}
