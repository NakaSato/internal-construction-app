import 'package:get_it/get_it.dart';

import '../application/calendar_management_bloc.dart';
import '../domain/repositories/calendar_management_repository.dart';
import 'mock_calendar_management_repository.dart';

/// Configure calendar management dependencies with mock implementations
void configureCalendarManagementDependencies() {
  final getIt = GetIt.instance;

  // Force register mock repository (replacing any existing registration)
  if (getIt.isRegistered<CalendarManagementRepository>()) {
    getIt.unregister<CalendarManagementRepository>();
  }
  getIt.registerLazySingleton<CalendarManagementRepository>(
    () => MockCalendarManagementRepository(),
  );

  // Force register BLoC as factory (replacing any existing registration)
  if (getIt.isRegistered<CalendarManagementBloc>()) {
    getIt.unregister<CalendarManagementBloc>();
  }
  getIt.registerFactory<CalendarManagementBloc>(
    () => CalendarManagementBloc(getIt<CalendarManagementRepository>()),
  );
}
