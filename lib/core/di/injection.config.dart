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

import '../../features/authentication/application/auth_bloc.dart' as _i574;
import '../../features/authentication/application/auth_cubit.dart' as _i153;
import '../../features/authentication/data/datasources/auth_api_service.dart'
    as _i1066;
import '../../features/authentication/data/repositories/api_auth_repository.dart'
    as _i410;
import '../../features/authentication/data/repositories/auth_repository_factory.dart'
    as _i580;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i742;
import '../../features/authentication/infrastructure/auth_repository_factory.dart'
    as _i202;
import '../../features/calendar_management/application/calendar_management_bloc.dart'
    as _i185;
import '../../features/calendar_management/domain/repositories/calendar_management_repository.dart'
    as _i646;
import '../../features/calendar_management/infrastructure/repositories/api_calendar_management_repository.dart'
    as _i43;
import '../../features/calendar_management/infrastructure/services/calendar_api_service.dart'
    as _i1036;
import '../../features/project_management/application/project_bloc.dart'
    as _i1062;
import '../../features/project_management/data/datasources/project_api_service.dart'
    as _i421;
import '../../features/project_management/data/repositories/api_project_repository.dart'
    as _i677;
import '../../features/project_management/domain/repositories/project_repository.dart'
    as _i475;
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
import '../network/dio_client.dart' as _i667;
import '../services/realtime_service.dart' as _i301;
import '../services/universal_realtime_handler.dart' as _i761;
import '../storage/secure_storage_service.dart' as _i666;
import 'auth_module.dart' as _i784;
import 'injection.dart' as _i464;

const String _dev = 'dev';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final externalDependenciesModule = _$ExternalDependenciesModule();
    final networkModule = _$NetworkModule();
    final authModule = _$AuthModule();
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => externalDependenciesModule.secureStorage,
    );
    gh.lazySingleton<String>(() => externalDependenciesModule.baseUrl);
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio());
    gh.lazySingleton<_i503.WorkCalendarRepository>(
      () => _i743.ApiWorkCalendarRepository(gh<_i361.Dio>()),
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
    gh.lazySingleton<_i742.AuthRepository>(
      () => _i410.ApiAuthRepository(
        gh<_i1066.AuthApiService>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
      instanceName: 'api',
    );
    gh.factory<_i421.ProjectApiService>(
      () => _i421.ProjectApiService(gh<_i361.Dio>(), baseUrl: gh<String>()),
    );
    gh.factory<_i1036.CalendarApiService>(
      () => _i1036.CalendarApiService(gh<_i361.Dio>(), baseUrl: gh<String>()),
    );
    gh.factory<_i937.WorkCalendarBloc>(
      () => _i937.WorkCalendarBloc(gh<_i503.WorkCalendarRepository>()),
    );
    gh.lazySingleton<_i301.RealtimeService>(
      () => _i301.RealtimeService(gh<_i666.SecureStorageService>()),
    );
    gh.lazySingleton<_i202.AuthRepositoryFactory>(
      () => _i202.AuthRepositoryFactory(
        gh<_i742.AuthRepository>(instanceName: 'api'),
      ),
    );
    gh.lazySingleton<_i580.AuthRepositoryFactory>(
      () => _i580.AuthRepositoryFactory(
        gh<_i742.AuthRepository>(instanceName: 'api'),
      ),
    );
    gh.lazySingleton<_i646.CalendarManagementRepository>(
      () =>
          _i43.ApiCalendarManagementRepository(gh<_i1036.CalendarApiService>()),
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
    gh.factory<_i475.EnhancedProjectRepository>(
      () => _i677.ApiProjectRepository(gh<_i421.ProjectApiService>()),
      registerFor: {_dev, _prod},
    );
    gh.factory<_i185.CalendarManagementBloc>(
      () => _i185.CalendarManagementBloc(
        gh<_i646.CalendarManagementRepository>(),
      ),
    );
    gh.lazySingleton<_i761.UniversalRealtimeHandler>(
      () => _i761.UniversalRealtimeHandler(gh<_i301.RealtimeService>()),
    );
    gh.factory<_i153.AuthCubit>(
      () => _i153.AuthCubit(gh<_i202.AuthRepositoryFactory>()),
    );
    gh.factory<_i574.AuthBloc>(
      () => _i574.AuthBloc(gh<_i202.AuthRepositoryFactory>()),
    );
    gh.factory<_i1062.EnhancedProjectBloc>(
      () => _i1062.EnhancedProjectBloc(
        repository: gh<_i475.EnhancedProjectRepository>(),
        realtimeService: gh<_i301.RealtimeService>(),
      ),
    );
    return this;
  }
}

class _$ExternalDependenciesModule extends _i464.ExternalDependenciesModule {}

class _$NetworkModule extends _i667.NetworkModule {}

class _$AuthModule extends _i784.AuthModule {}
