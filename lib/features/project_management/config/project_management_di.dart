import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

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
}
