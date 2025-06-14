import 'package:get_it/get_it.dart';

import '../application/work_calendar_bloc.dart';
import '../domain/repositories/work_calendar_repository.dart';
import 'mock_work_calendar_repository.dart';

/// Configure work calendar dependencies with mock implementations
void configureWorkCalendarDependencies() {
  final getIt = GetIt.instance;

  // Force register mock repository (replacing any existing registration)
  if (getIt.isRegistered<WorkCalendarRepository>()) {
    getIt.unregister<WorkCalendarRepository>();
  }
  getIt.registerLazySingleton<WorkCalendarRepository>(
    () => MockWorkCalendarRepository(),
  );

  // Force register BLoC as factory (replacing any existing registration)
  if (getIt.isRegistered<WorkCalendarBloc>()) {
    getIt.unregister<WorkCalendarBloc>();
  }
  getIt.registerFactory<WorkCalendarBloc>(
    () => WorkCalendarBloc(getIt<WorkCalendarRepository>()),
  );
}
