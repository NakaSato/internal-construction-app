import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../application/calendar_management_bloc.dart';
import '../domain/repositories/calendar_management_repository.dart';
import '../infrastructure/repositories/api_calendar_management_repository.dart';
import '../infrastructure/services/calendar_api_service.dart';

/// Configure calendar management dependencies
void configureCalendarManagementDependencies() {
  final getIt = GetIt.instance;

  // Register API service (check if not already registered)
  if (!getIt.isRegistered<CalendarApiService>()) {
    getIt.registerLazySingleton<CalendarApiService>(
      () => CalendarApiService(getIt<Dio>()),
    );
  }

  // Register repository (check if not already registered)
  if (!getIt.isRegistered<CalendarManagementRepository>()) {
    getIt.registerLazySingleton<CalendarManagementRepository>(
      () => ApiCalendarManagementRepository(getIt<CalendarApiService>()),
    );
  }

  // Register BLoC as factory (check if not already registered)
  if (!getIt.isRegistered<CalendarManagementBloc>()) {
    getIt.registerFactory<CalendarManagementBloc>(
      () => CalendarManagementBloc(getIt<CalendarManagementRepository>()),
    );
  }
}
