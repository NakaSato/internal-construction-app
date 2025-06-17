import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';

// Feature DI configurations
import '../../features/project_management/config/project_management_di.dart';
import '../../features/daily_reports/config/daily_reports_di.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core services
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Register base URL for features
  getIt.registerLazySingleton<String>(() => 'https://api.example.com');

  // Configure feature dependencies
  configureProjectManagementDependencies();
  configureDailyReportsDependencies();
}
