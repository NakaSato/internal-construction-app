import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Core services
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Register base URL for features
  getIt.registerLazySingleton<String>(() => 'https://api.example.com');

  // TODO: Configure feature dependencies when DI files are created
  // configureProjectManagementDependencies();
  // configureDailyReportsDependencies();
}