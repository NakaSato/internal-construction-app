import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_architecture_app/core/error/failures.dart';
import '../../domain/entities/daily_report.dart';
import '../../domain/usecases/create_daily_report.dart';
import '../../domain/usecases/delete_daily_report.dart';
import '../../domain/usecases/get_daily_report_by_id.dart';
import '../../domain/usecases/get_daily_reports.dart';
import '../../domain/usecases/update_daily_report.dart';
import '../../domain/usecases/upload_daily_report_image.dart';
import '../models/filter_params.dart';
import '../states/daily_reports_state.dart';

/// Cubit to manage daily reports state and operations
class DailyReportsCubit extends Cubit<DailyReportsState> {
  final GetDailyReports _getDailyReports;
  final GetDailyReportById _getDailyReportById;
  final CreateDailyReport _createDailyReport;
  final UpdateDailyReport _updateDailyReport;
  final DeleteDailyReport _deleteDailyReport;
  final UploadDailyReportImage _uploadDailyReportImage;

  DailyReportsCubit({
    required GetDailyReports getDailyReports,
    required GetDailyReportById getDailyReportById,
    required CreateDailyReport createDailyReport,
    required UpdateDailyReport updateDailyReport,
    required DeleteDailyReport deleteDailyReport,
    required UploadDailyReportImage uploadDailyReportImage,
  }) : _getDailyReports = getDailyReports,
       _getDailyReportById = getDailyReportById,
       _createDailyReport = createDailyReport,
       _updateDailyReport = updateDailyReport,
       _deleteDailyReport = deleteDailyReport,
       _uploadDailyReportImage = uploadDailyReportImage,
       super(DailyReportsInitial());

  /// Load initial reports with default filters
  Future<void> loadDailyReports({DailyReportsFilterParams? filters}) async {
    final currentFilters = filters ?? DailyReportsFilterParams.empty;
    emit(DailyReportsLoading());

    final result = await _getDailyReports(
      GetDailyReportsParams(
        pageNumber: currentFilters.pageNumber,
        pageSize: currentFilters.pageSize,
        projectId: currentFilters.projectId,
        technicianId: currentFilters.technicianId,
        status: _convertFilterStatusToEntityStatus(currentFilters.status),
        startDate: currentFilters.startDate,
        endDate: currentFilters.endDate,
      ),
    );

    result.fold(
      (failure) =>
          emit(DailyReportsError(message: _mapFailureToMessage(failure))),
      (reportData) => emit(
        DailyReportsLoaded(
          reports: reportData.reports,
          currentPage: reportData.pageNumber,
          totalPages: reportData.totalPages,
          totalCount: reportData.totalCount,
          hasReachedMax: reportData.pageNumber >= reportData.totalPages,
          activeFilters: currentFilters,
        ),
      ),
    );
  }

  /// Refresh daily reports list
  Future<void> refreshDailyReports() async {
    if (state is DailyReportsLoaded) {
      final currentState = state as DailyReportsLoaded;
      final refreshFilters = currentState.activeFilters.copyWith(pageNumber: 1);

      emit(
        DailyReportsLoaded(
          reports: currentState.reports,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          totalCount: currentState.totalCount,
          hasReachedMax: currentState.hasReachedMax,
          activeFilters: refreshFilters,
          isRefreshing: true,
        ),
      );

      await loadDailyReports(filters: refreshFilters);
    }
  }

  /// Load next page of daily reports
  Future<void> loadMoreReports() async {
    if (state is DailyReportsLoaded) {
      final currentState = state as DailyReportsLoaded;

      if (currentState.hasReachedMax) return;

      final nextPage = currentState.currentPage + 1;
      final nextFilters = currentState.activeFilters.copyWith(
        pageNumber: nextPage,
      );

      final result = await _getDailyReports(
        GetDailyReportsParams(
          pageNumber: nextFilters.pageNumber,
          pageSize: nextFilters.pageSize,
          projectId: nextFilters.projectId,
          technicianId: nextFilters.technicianId,
          status: _convertFilterStatusToEntityStatus(nextFilters.status),
          startDate: nextFilters.startDate,
          endDate: nextFilters.endDate,
        ),
      );

      result.fold(
        (failure) =>
            emit(DailyReportsError(message: _mapFailureToMessage(failure))),
        (reportData) {
          final allReports = List<DailyReport>.from(currentState.reports)
            ..addAll(reportData.reports);

          emit(
            DailyReportsLoaded(
              reports: allReports,
              currentPage: reportData.pageNumber,
              totalPages: reportData.totalPages,
              totalCount: reportData.totalCount,
              hasReachedMax: reportData.pageNumber >= reportData.totalPages,
              activeFilters: nextFilters,
            ),
          );
        },
      );
    }
  }

  /// Apply new filters to daily reports
  Future<void> applyFilters(DailyReportsFilterParams filters) async {
    final resetPageFilters = filters.copyWith(pageNumber: 1);
    await loadDailyReports(filters: resetPageFilters);
  }

  /// Get a daily report by ID
  Future<void> getDailyReportById(String reportId) async {
    emit(DailyReportDetailLoading());

    final result = await _getDailyReportById(
      GetDailyReportByIdParams(reportId),
    );

    result.fold(
      (failure) =>
          emit(DailyReportDetailError(message: _mapFailureToMessage(failure))),
      (report) => emit(DailyReportDetailLoaded(report: report)),
    );
  }

  /// Create a new daily report
  Future<DailyReport?> createDailyReport(DailyReport report) async {
    emit(DailyReportOperationLoading());

    final result = await _createDailyReport(CreateDailyReportParams(report));

    late DailyReportsState newState;
    DailyReport? createdReport;

    result.fold(
      (failure) {
        newState = DailyReportOperationError(
          message: _mapFailureToMessage(failure),
        );
      },
      (report) {
        createdReport = report;
        newState = DailyReportOperationSuccess(
          message: 'Report created successfully',
          operationType: 'create',
        );
      },
    );

    emit(newState);
    return createdReport;
  }

  /// Update an existing daily report
  Future<DailyReport?> updateDailyReport(DailyReport report) async {
    emit(DailyReportOperationLoading());

    final result = await _updateDailyReport(UpdateDailyReportParams(report));

    late DailyReportsState newState;
    DailyReport? updatedReport;

    result.fold(
      (failure) {
        newState = DailyReportOperationError(
          message: _mapFailureToMessage(failure),
        );
      },
      (report) {
        updatedReport = report;
        newState = DailyReportOperationSuccess(
          message: 'Report updated successfully',
          operationType: 'update',
        );
      },
    );

    emit(newState);
    return updatedReport;
  }

  /// Delete a daily report
  Future<bool> deleteDailyReport(String reportId) async {
    emit(DailyReportOperationLoading());

    final result = await _deleteDailyReport(DeleteDailyReportParams(reportId));

    late DailyReportsState newState;
    bool success = false;

    result.fold(
      (failure) {
        newState = DailyReportOperationError(
          message: _mapFailureToMessage(failure),
        );
      },
      (_) {
        success = true;
        newState = DailyReportOperationSuccess(
          message: 'Report deleted successfully',
          operationType: 'delete',
        );
      },
    );

    emit(newState);
    return success;
  }

  /// Upload a daily report image
  Future<String?> uploadImage(String filePath, {String reportId = ''}) async {
    emit(DailyReportImageUploadLoading());

    final result = await _uploadDailyReportImage(
      UploadDailyReportImageParams(reportId: reportId, imagePath: filePath),
    );

    late DailyReportsState newState;
    String? imageId;

    result.fold(
      (failure) {
        newState = DailyReportImageUploadError(
          message: _mapFailureToMessage(failure),
        );
      },
      (id) {
        imageId = id;
        newState = DailyReportImageUploadSuccess(imageId: id);
      },
    );

    emit(newState);
    return imageId;
  }

  /// Save a draft report to local storage
  Future<void> saveDraftLocally(DailyReport report) async {
    try {
      emit(DailyReportOperationInProgress(operationType: 'save_draft'));

      // In a real implementation, you'd call a local repository method
      // such as: await _localDailyReportRepository.saveReport(report);

      // For now, simulate success
      await Future.delayed(const Duration(seconds: 1));

      emit(DailyReportDraftSaved(draftReport: report));
    } catch (e) {
      emit(
        DailyReportOperationFailure(
          message: 'Failed to save draft: $e',
          operationType: 'save_draft',
        ),
      );
    }
  }

  /// Load a draft report from local storage
  Future<void> loadDraft(String reportId) async {
    try {
      emit(DailyReportOperationInProgress(operationType: 'load_draft'));

      // In a real implementation, you'd call a local repository method
      // such as: final draft = await _localDailyReportRepository.getReport(reportId);

      // For now, simulate loading a draft
      await Future.delayed(const Duration(seconds: 1));

      // This is just a placeholder
      final mockDraft = DailyReport(
        reportId: reportId,
        projectId: 'mock_project_id',
        technicianId: 'mock_technician_id',
        reportDate: DateTime.now(),
        status: DailyReportStatus.draft,
        workStartTime: '09:00',
        workEndTime: '17:00',
        weatherConditions: 'Partly cloudy',
        overallNotes: 'Draft notes',
        safetyNotes: 'No incidents',
        delaysOrIssues: 'None',
        photosCount: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      emit(DailyReportDraftLoaded(draftReport: mockDraft));
    } catch (e) {
      emit(
        DailyReportOperationFailure(
          message: 'Failed to load draft: $e',
          operationType: 'load_draft',
        ),
      );
    }
  }

  /// Sync offline reports
  Future<void> syncOfflineReports() async {
    try {
      // In a real implementation, you'd get all unsynchronized reports
      // such as: final unsyncedReports = await _localDailyReportRepository.getUnsyncedReports();

      // Mocking the process for now
      const totalReports = 3;
      emit(
        DailyReportOfflineSyncInProgress(
          totalReports: totalReports,
          syncedCount: 0,
        ),
      );

      // Simulate sync process
      for (int i = 1; i <= totalReports; i++) {
        await Future.delayed(const Duration(seconds: 1));
        emit(
          DailyReportOfflineSyncInProgress(
            totalReports: totalReports,
            syncedCount: i,
          ),
        );
      }

      emit(DailyReportOfflineSyncComplete(successCount: 2, failureCount: 1));

      // Refresh reports list
      await loadDailyReports();
    } catch (e) {
      emit(
        DailyReportOperationFailure(
          message: 'Failed to sync offline reports: $e',
          operationType: 'sync_offline',
        ),
      );
    }
  }

  /// Fetch current weather for location
  Future<void> fetchCurrentWeather(double latitude, double longitude) async {
    try {
      emit(WeatherDataState(isLoading: true));

      // In a real implementation, you would call a weather API service
      // such as: final weather = await _weatherService.getCurrentWeather(lat, lng);

      // For now, simulate a weather API call
      await Future.delayed(const Duration(seconds: 1));
      final mockWeatherData = 'Sunny, 75°F, Light winds from SW, Humidity 45%';

      emit(WeatherDataState(weatherData: mockWeatherData, isLoading: false));
    } catch (e) {
      emit(
        WeatherDataState(
          error: 'Failed to fetch weather data: $e',
          isLoading: false,
        ),
      );
    }
  }

  /// Convert filter status to entity status
  DailyReportStatus? _convertFilterStatusToEntityStatus(
    DailyReportsFilterStatus? filterStatus,
  ) {
    if (filterStatus == null) return null;

    switch (filterStatus) {
      case DailyReportsFilterStatus.draft:
        return DailyReportStatus.draft;
      case DailyReportsFilterStatus.submitted:
        return DailyReportStatus.submitted;
      case DailyReportsFilterStatus.approved:
        return DailyReportStatus.approved;
      case DailyReportsFilterStatus.rejected:
        return DailyReportStatus.rejected;
      case DailyReportsFilterStatus.all:
        return null; // Return null for "all" filter
    }
  }

  /// Map failure to user-friendly error message
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error. Please try again later.';
      case NetworkFailure _:
        return 'Network error. Please check your connection.';
      case CacheFailure _:
        return 'Cache error. Please restart the app.';
      case ValidationFailure _:
        return (failure as ValidationFailure).message;
      case ForbiddenFailure _:
        return 'You are not authorized to perform this action.';
      case NotFoundFailure _:
        return 'Resource not found. It may have been deleted.';
      case LocalDatabaseFailure _:
        return 'Local storage error. Please restart the app.';
      case AuthFailure _:
        return 'Authentication error. Please sign in again.';
      default:
        return 'Unexpected error occurred. Please try again.';
    }
  }
}
