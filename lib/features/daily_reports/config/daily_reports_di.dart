import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../application/cubits/daily_reports_cubit.dart';
import '../domain/repositories/daily_report_repository.dart';
import '../domain/usecases/create_daily_report.dart';
import '../domain/usecases/delete_daily_report.dart';
import '../domain/usecases/get_daily_report_by_id.dart';
import '../domain/usecases/get_daily_reports.dart';
import '../domain/usecases/update_daily_report.dart';
import '../domain/usecases/upload_daily_report_image.dart';
import '../infrastructure/repositories/mock_daily_report_repository.dart';

/// Configure daily reports dependencies
void configureDailyReportsDependencies() {
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

  // Register repository
  if (!getIt.isRegistered<DailyReportRepository>()) {
    getIt.registerLazySingleton<DailyReportRepository>(
      () => MockDailyReportRepository(),
    );
  }

  // Register use cases
  if (!getIt.isRegistered<GetDailyReports>()) {
    getIt.registerLazySingleton<GetDailyReports>(
      () => GetDailyReports(getIt<DailyReportRepository>()),
    );
  }

  if (!getIt.isRegistered<GetDailyReportById>()) {
    getIt.registerLazySingleton<GetDailyReportById>(
      () => GetDailyReportById(getIt<DailyReportRepository>()),
    );
  }

  if (!getIt.isRegistered<CreateDailyReport>()) {
    getIt.registerLazySingleton<CreateDailyReport>(
      () => CreateDailyReport(getIt<DailyReportRepository>()),
    );
  }

  if (!getIt.isRegistered<UpdateDailyReport>()) {
    getIt.registerLazySingleton<UpdateDailyReport>(
      () => UpdateDailyReport(getIt<DailyReportRepository>()),
    );
  }

  if (!getIt.isRegistered<DeleteDailyReport>()) {
    getIt.registerLazySingleton<DeleteDailyReport>(
      () => DeleteDailyReport(getIt<DailyReportRepository>()),
    );
  }

  if (!getIt.isRegistered<UploadDailyReportImage>()) {
    getIt.registerLazySingleton<UploadDailyReportImage>(
      () => UploadDailyReportImage(getIt<DailyReportRepository>()),
    );
  }

  // Register cubit
  if (!getIt.isRegistered<DailyReportsCubit>()) {
    getIt.registerFactory<DailyReportsCubit>(
      () => DailyReportsCubit(
        getDailyReports: getIt<GetDailyReports>(),
        getDailyReportById: getIt<GetDailyReportById>(),
        createDailyReport: getIt<CreateDailyReport>(),
        updateDailyReport: getIt<UpdateDailyReport>(),
        deleteDailyReport: getIt<DeleteDailyReport>(),
        uploadDailyReportImage: getIt<UploadDailyReportImage>(),
      ),
    );
  }
}
