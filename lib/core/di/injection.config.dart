// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/authentication/application/auth_bloc.dart' as _i574;
import '../../features/authentication/application/auth_cubit.dart' as _i153;
import '../../features/authentication/data/datasources/auth_api_service.dart'
    as _i1066;
import '../../features/authentication/data/repositories/api_auth_repository.dart'
    as _i410;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i742;
import '../../features/authentication/infrastructure/auth_repository_factory.dart'
    as _i202;
import '../../features/calendar/application/calendar_management_bloc.dart'
    as _i907;
import '../../features/calendar/domain/repositories/calendar_management_repository.dart'
    as _i28;
import '../../features/calendar/infrastructure/repositories/api_calendar_management_repository.dart'
    as _i312;
import '../../features/calendar/infrastructure/services/calendar_api_service.dart'
    as _i918;
import '../../features/daily_reports/data/repositories/api_daily_report_repository.dart'
    as _i50;
import '../../features/daily_reports/data/repositories/realtime_daily_report_repository.dart'
    as _i112;
import '../../features/daily_reports/domain/repositories/daily_report_repository.dart'
    as _i137;
import '../../features/daily_reports/infrastructure/services/daily_reports_api_service.dart'
    as _i975;
import '../../features/notifications/application/cubits/notification_cubit.dart'
    as _i359;
import '../../features/notifications/application/cubits/notification_settings_cubit.dart'
    as _i862;
import '../../features/notifications/data/datasources/notification_remote_data_source.dart'
    as _i757;
import '../../features/notifications/data/repositories/api_notification_repository.dart'
    as _i612;
import '../../features/notifications/data/repositories/notification_repository_impl.dart'
    as _i361;
import '../../features/notifications/data/repositories/realtime_notification_repository_wrapper.dart'
    as _i681;
import '../../features/notifications/domain/repositories/notification_repository.dart'
    as _i367;
import '../../features/projects/application/project_bloc.dart' as _i488;
import '../../features/projects/data/datasources/project_api_service.dart'
    as _i706;
import '../../features/projects/data/repositories/api_project_repository.dart'
    as _i585;
import '../../features/projects/data/repositories/realtime_api_project_repository.dart'
    as _i1043;
import '../../features/projects/domain/repositories/project_repository.dart'
    as _i338;
import '../../features/task/data/repositories/api_task_repository.dart'
    as _i560;
import '../../features/task/data/repositories/realtime_task_repository.dart'
    as _i883;
import '../../features/task/domain/repositories/task_repository.dart' as _i81;
import '../../features/task/infrastructure/datasources/task_remote_datasource.dart'
    as _i154;
import '../../features/task/infrastructure/datasources/task_remote_datasource_impl.dart'
    as _i88;
import '../../features/task/infrastructure/repositories/task_repository_impl.dart'
    as _i1070;
import '../../features/wbs/domain/repositories/wbs_repository.dart' as _i528;
import '../../features/wbs/domain/usecases/wbs_usecases.dart' as _i572;
import '../../features/wbs/infrastructure/repositories/wbs_repository_impl.dart'
    as _i1011;
import '../../features/wbs/infrastructure/services/wbs_api_service.dart'
    as _i66;
import '../../features/work_calendar/application/work_calendar_bloc.dart'
    as _i937;
import '../../features/work_calendar/domain/repositories/work_calendar_repository.dart'
    as _i503;
import '../../features/work_calendar/infrastructure/repositories/api_work_calendar_repository.dart'
    as _i743;
import '../network/api_client.dart' as _i557;
import '../network/dio_client.dart' as _i667;
import '../network/network_info.dart' as _i932;
import '../services/realtime_api_streams.dart' as _i826;
import '../services/realtime_service.dart' as _i301;
import '../services/security_service.dart' as _i337;
import '../services/session_validation_service.dart' as _i490;
import '../services/signalr_service.dart' as _i320;
import '../services/token_service.dart' as _i227;
import '../services/unified_realtime_api_service.dart' as _i53;
import '../services/universal_realtime_handler.dart' as _i761;
import '../storage/cache_service.dart' as _i796;
import '../storage/preferences_service.dart' as _i636;
import '../storage/secure_storage_service.dart' as _i666;
import 'auth_module.dart' as _i784;
import 'injection.dart' as _i464;

const String _test = 'test';
const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final externalDependenciesModule = _$ExternalDependenciesModule();
    final networkModule = _$NetworkModule();
    final authModule = _$AuthModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => externalDependenciesModule.secureStorage,
    );
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => externalDependenciesModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<String>(() => externalDependenciesModule.baseUrl);
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio());
    gh.factory<_i932.NetworkInfo>(() => _i932.NetworkInfoImpl());
    gh.lazySingleton<_i503.WorkCalendarRepository>(
      () => _i743.ApiWorkCalendarRepository(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i557.ApiClient>(
      () => _i557.ApiClient(baseUrl: gh<String>(), authToken: gh<String>()),
    );
    gh.lazySingleton<_i1066.AuthApiService>(
      () => authModule.authApiService(gh<_i361.Dio>()),
    );
    gh.factory<_i66.WBSApiService>(() => _i66.WBSApiService(gh<_i361.Dio>()));
    gh.lazySingleton<_i666.SecureStorageService>(
      () => _i666.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i528.WbsRepository>(
      () => _i1011.WbsRepositoryImpl(gh<_i66.WBSApiService>()),
    );
    gh.lazySingleton<_i636.PreferencesService>(
      () => _i636.PreferencesService(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i796.CacheService>(
      () => _i796.CacheService(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i154.TaskRemoteDataSource>(
      () => _i88.TaskRemoteDataSourceImpl(
        client: gh<_i361.Dio>(),
        baseUrl: gh<String>(),
      ),
    );
    gh.lazySingleton<_i742.AuthRepository>(
      () => _i410.ApiAuthRepository(
        gh<_i1066.AuthApiService>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
      instanceName: 'api',
    );
    gh.lazySingleton<_i757.NotificationRemoteDataSource>(
      () => _i757.NotificationRemoteDataSource(gh<_i557.ApiClient>()),
    );
    gh.factory<_i975.DailyReportsApiService>(
      () => _i975.DailyReportsApiService(gh<_i557.ApiClient>()),
    );
    gh.factory<_i706.ProjectApiService>(
      () => _i706.ProjectApiService(gh<_i361.Dio>(), baseUrl: gh<String>()),
    );
    gh.factory<_i612.ApiNotificationRepository>(
      () => _i612.ApiNotificationRepository(
        gh<_i757.NotificationRemoteDataSource>(),
      ),
    );
    gh.factory<_i1070.TaskRepositoryImpl>(
      () => _i1070.TaskRepositoryImpl(
        remoteDataSource: gh<_i154.TaskRemoteDataSource>(),
        networkInfo: gh<_i932.NetworkInfo>(),
      ),
    );
    gh.factory<_i918.CalendarApiService>(
      () => _i918.CalendarApiService(gh<_i361.Dio>(), baseUrl: gh<String>()),
    );
    gh.factory<_i937.WorkCalendarBloc>(
      () => _i937.WorkCalendarBloc(gh<_i503.WorkCalendarRepository>()),
    );
    gh.factory<_i361.NotificationRepositoryImpl>(
      () => _i361.NotificationRepositoryImpl(
        gh<_i757.NotificationRemoteDataSource>(),
      ),
      registerFor: {_test},
    );
    gh.factory<_i560.ApiTaskRepository>(
      () => _i560.ApiTaskRepository(gh<_i1070.TaskRepositoryImpl>()),
    );
    gh.lazySingleton<_i320.SignalRService>(
      () => _i320.SignalRService(gh<_i666.SecureStorageService>()),
    );
    gh.lazySingleton<_i53.UnifiedRealtimeApiService>(
      () => _i53.UnifiedRealtimeApiService(gh<_i666.SecureStorageService>()),
    );
    gh.lazySingleton<_i301.RealtimeService>(
      () => _i301.RealtimeService(gh<_i666.SecureStorageService>()),
    );
    gh.lazySingleton<_i761.UniversalRealtimeHandler>(
      () => _i761.UniversalRealtimeHandler(gh<_i320.SignalRService>()),
    );
    gh.factory<_i50.ApiDailyReportRepository>(
      () => _i50.ApiDailyReportRepository(gh<_i975.DailyReportsApiService>()),
    );
    gh.lazySingleton<_i202.AuthRepositoryFactory>(
      () => _i202.AuthRepositoryFactory(
        gh<_i742.AuthRepository>(instanceName: 'api'),
      ),
    );
    gh.lazySingleton<_i367.NotificationRepository>(
      () => _i681.RealtimeNotificationRepositoryWrapper(
        gh<_i612.ApiNotificationRepository>(),
      ),
      registerFor: {_dev, _prod},
    );
    gh.factory<_i572.GetProjectWbs>(
      () => _i572.GetProjectWbs(gh<_i528.WbsRepository>()),
    );
    gh.factory<_i572.GetWbsTask>(
      () => _i572.GetWbsTask(gh<_i528.WbsRepository>()),
    );
    gh.factory<_i572.CreateWbsTask>(
      () => _i572.CreateWbsTask(gh<_i528.WbsRepository>()),
    );
    gh.factory<_i572.UpdateWbsTask>(
      () => _i572.UpdateWbsTask(gh<_i528.WbsRepository>()),
    );
    gh.factory<_i572.UpdateTaskStatus>(
      () => _i572.UpdateTaskStatus(gh<_i528.WbsRepository>()),
    );
    gh.factory<_i572.DeleteWbsTask>(
      () => _i572.DeleteWbsTask(gh<_i528.WbsRepository>()),
    );
    gh.lazySingleton<_i227.TokenService>(
      () =>
          _i227.TokenService(gh<_i666.SecureStorageService>(), gh<_i361.Dio>()),
    );
    gh.factory<_i585.ApiProjectRepository>(
      () => _i585.ApiProjectRepository(gh<_i706.ProjectApiService>()),
    );
    gh.factory<_i153.AuthCubit>(
      () => _i153.AuthCubit(
        gh<_i202.AuthRepositoryFactory>(),
        gh<_i636.PreferencesService>(),
      ),
    );
    gh.factory<_i338.ProjectRepository>(
      () => _i1043.RealtimeProjectRepositoryWrapper(
        gh<_i585.ApiProjectRepository>(),
      ),
      registerFor: {_dev, _prod},
    );
    gh.lazySingleton<_i28.CalendarManagementRepository>(
      () =>
          _i312.ApiCalendarManagementRepository(gh<_i918.CalendarApiService>()),
    );
    gh.factory<_i907.CalendarManagementBloc>(
      () =>
          _i907.CalendarManagementBloc(gh<_i28.CalendarManagementRepository>()),
    );
    gh.factory<_i359.NotificationCubit>(
      () => _i359.NotificationCubit(gh<_i367.NotificationRepository>()),
    );
    gh.factory<_i862.NotificationSettingsCubit>(
      () => _i862.NotificationSettingsCubit(gh<_i367.NotificationRepository>()),
    );
    gh.lazySingleton<_i488.ProjectBloc>(
      () => _i488.ProjectBloc(
        repository: gh<_i338.ProjectRepository>(),
        signalRService: gh<_i320.SignalRService>(),
      ),
    );
    gh.factory<_i81.TaskRepository>(
      () => _i883.RealtimeTaskRepositoryWrapper(gh<_i560.ApiTaskRepository>()),
      registerFor: {_dev, _prod},
    );
    gh.lazySingleton<_i826.RealtimeApiStreams>(
      () => _i826.RealtimeApiStreams(gh<_i53.UnifiedRealtimeApiService>()),
    );
    gh.lazySingleton<_i337.SecurityService>(
      () => _i337.SecurityService(
        gh<_i227.TokenService>(),
        gh<_i666.SecureStorageService>(),
      ),
    );
    gh.factory<_i137.DailyReportRepository>(
      () => _i112.RealtimeDailyReportRepositoryWrapper(
        gh<_i50.ApiDailyReportRepository>(),
      ),
      registerFor: {_dev, _prod},
    );
    gh.factory<_i574.AuthBloc>(
      () => _i574.AuthBloc(
        gh<_i202.AuthRepositoryFactory>(),
        gh<_i227.TokenService>(),
        gh<_i337.SecurityService>(),
      ),
    );
    gh.lazySingleton<_i490.SessionValidationService>(
      () => _i490.SessionValidationService(
        gh<_i227.TokenService>(),
        gh<_i337.SecurityService>(),
      ),
    );
    return this;
  }
}

class _$ExternalDependenciesModule extends _i464.ExternalDependenciesModule {}

class _$NetworkModule extends _i667.NetworkModule {}

class _$AuthModule extends _i784.AuthModule {}
