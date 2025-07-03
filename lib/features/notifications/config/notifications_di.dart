import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../application/blocs/notification_bloc.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/usecases/get_notifications.dart';
import '../domain/usecases/get_notification_count.dart';
import '../domain/usecases/get_notification_statistics.dart';
import '../domain/usecases/mark_notification_read.dart';
import '../infrastructure/datasources/notification_remote_datasource.dart';
import '../infrastructure/repositories/notification_repository_impl.dart';

/// Configures dependency injection for the notifications feature
void configureNotificationsDependencies(GetIt getIt) {
  // Data sources
  getIt.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      baseUrl:
          'https://api.example.com', // TODO: Use proper base URL from config
    ),
  );

  // Repositories
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: getIt<NotificationRemoteDataSource>(),
    ),
  );

  // Use cases
  getIt.registerLazySingleton<GetNotificationsUseCase>(
    () => GetNotificationsUseCase(getIt<NotificationRepository>()),
  );

  getIt.registerLazySingleton<GetNotificationCountUseCase>(
    () => GetNotificationCountUseCase(getIt<NotificationRepository>()),
  );

  getIt.registerLazySingleton<GetNotificationStatisticsUseCase>(
    () => GetNotificationStatisticsUseCase(getIt<NotificationRepository>()),
  );

  getIt.registerLazySingleton<MarkNotificationAsReadUseCase>(
    () => MarkNotificationAsReadUseCase(getIt<NotificationRepository>()),
  );

  getIt.registerLazySingleton<MarkAllNotificationsAsReadUseCase>(
    () => MarkAllNotificationsAsReadUseCase(getIt<NotificationRepository>()),
  );

  // BLoCs
  getIt.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      getNotifications: getIt<GetNotificationsUseCase>(),
      getNotificationCount: getIt<GetNotificationCountUseCase>(),
      getNotificationStatistics: getIt<GetNotificationStatisticsUseCase>(),
      markNotificationAsRead: getIt<MarkNotificationAsReadUseCase>(),
      markAllNotificationsAsRead: getIt<MarkAllNotificationsAsReadUseCase>(),
      repository: getIt<NotificationRepository>(),
    ),
  );
}
