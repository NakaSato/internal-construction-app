// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:dio/dio.dart' as _i361;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:location/location.dart' as _i645;

import '../../features/authentication/application/auth_bloc.dart' as _i574;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i742;
import '../../features/authentication/infrastructure/auth_repository_impl.dart'
    as _i238;
import '../../features/image_upload/application/image_upload_bloc.dart'
    as _i1043;
import '../../features/image_upload/domain/repositories/image_upload_repository.dart'
    as _i138;
import '../../features/image_upload/infrastructure/repositories/firebase_image_upload_repository.dart'
    as _i627;
import '../../features/location_tracking/application/location_tracking_bloc.dart'
    as _i251;
import '../../features/location_tracking/domain/repositories/location_tracking_repository.dart'
    as _i316;
import '../../features/location_tracking/infrastructure/repositories/firebase_location_tracking_repository.dart'
    as _i950;
import '../../features/work_calendar/application/work_calendar_bloc.dart'
    as _i937;
import '../../features/work_calendar/domain/repositories/work_calendar_repository.dart'
    as _i503;
import '../network/dio_client.dart' as _i667;
import 'injection.dart' as _i464;
import 'work_calendar_module.dart' as _i300;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final externalDependenciesModule = _$ExternalDependenciesModule();
    final networkModule = _$NetworkModule();
    final workCalendarModule = _$WorkCalendarModule();
    gh.lazySingleton<_i59.FirebaseAuth>(
      () => externalDependenciesModule.firebaseAuth,
    );
    gh.lazySingleton<_i457.FirebaseStorage>(
      () => externalDependenciesModule.firebaseStorage,
    );
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => externalDependenciesModule.firestore,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => externalDependenciesModule.secureStorage,
    );
    gh.lazySingleton<_i645.Location>(() => externalDependenciesModule.location);
    gh.lazySingleton<_i361.Dio>(() => networkModule.dio());
    gh.lazySingleton<_i503.WorkCalendarRepository>(
      () => workCalendarModule.workCalendarRepository(
        gh<_i974.FirebaseFirestore>(),
        gh<_i59.FirebaseAuth>(),
      ),
    );
    gh.lazySingleton<_i316.LocationTrackingRepository>(
      () => _i950.FirebaseLocationTrackingRepository(
        gh<_i974.FirebaseFirestore>(),
        gh<_i645.Location>(),
      ),
    );
    gh.lazySingleton<_i742.AuthRepository>(
      () => _i238.AuthRepositoryImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.factory<_i937.WorkCalendarBloc>(
      () => _i937.WorkCalendarBloc(gh<_i503.WorkCalendarRepository>()),
    );
    gh.lazySingleton<_i138.ImageUploadRepository>(
      () => _i627.FirebaseImageUploadRepository(
        gh<_i59.FirebaseAuth>(),
        gh<_i457.FirebaseStorage>(),
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.factory<_i574.AuthBloc>(
      () => _i574.AuthBloc(gh<_i742.AuthRepository>()),
    );
    gh.factory<_i1043.ImageUploadBloc>(
      () => _i1043.ImageUploadBloc(gh<_i138.ImageUploadRepository>()),
    );
    gh.factory<_i251.LocationTrackingBloc>(
      () => _i251.LocationTrackingBloc(gh<_i316.LocationTrackingRepository>()),
    );
    return this;
  }
}

class _$ExternalDependenciesModule extends _i464.ExternalDependenciesModule {}

class _$NetworkModule extends _i667.NetworkModule {}

class _$WorkCalendarModule extends _i300.WorkCalendarModule {}
