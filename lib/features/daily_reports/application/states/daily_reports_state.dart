import 'package:equatable/equatable.dart';

import '../../domain/entities/daily_report.dart';
import '../models/filter_params.dart';

/// Base state class for daily reports
abstract class DailyReportsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class DailyReportsInitial extends DailyReportsState {}

/// Loading state
class DailyReportsLoading extends DailyReportsState {}

/// Error state
class DailyReportsError extends DailyReportsState {
  final String message;

  DailyReportsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Loaded state with reports and pagination info
class DailyReportsLoaded extends DailyReportsState {
  final List<DailyReport> reports;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasReachedMax;
  final DailyReportsFilterParams activeFilters;
  final bool isRefreshing;

  DailyReportsLoaded({
    required this.reports,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasReachedMax,
    required this.activeFilters,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [
    reports,
    currentPage,
    totalPages,
    totalCount,
    hasReachedMax,
    activeFilters,
    isRefreshing,
  ];

  DailyReportsLoaded copyWith({
    List<DailyReport>? reports,
    int? currentPage,
    int? totalPages,
    int? totalCount,
    bool? hasReachedMax,
    DailyReportsFilterParams? activeFilters,
    bool? isRefreshing,
  }) {
    return DailyReportsLoaded(
      reports: reports ?? this.reports,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      activeFilters: activeFilters ?? this.activeFilters,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

// Daily Report Detail States

/// Loading state for daily report detail
class DailyReportDetailLoading extends DailyReportsState {}

/// Error state for daily report detail
class DailyReportDetailError extends DailyReportsState {
  final String message;

  DailyReportDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Loaded state for daily report detail
class DailyReportDetailLoaded extends DailyReportsState {
  final DailyReport report;

  DailyReportDetailLoaded({required this.report});

  @override
  List<Object?> get props => [report];
}

// Daily Report Operation States

/// Loading state during create/update/delete operations
class DailyReportOperationInProgress extends DailyReportsState {
  final String operationType;

  DailyReportOperationInProgress({required this.operationType});

  @override
  List<Object?> get props => [operationType];
}

/// Success state after operation completed
class DailyReportOperationSuccess extends DailyReportsState {
  final String message;
  final String operationType;
  final DailyReport? report;

  DailyReportOperationSuccess({
    required this.message,
    required this.operationType,
    this.report,
  });

  @override
  List<Object?> get props => [message, operationType, report];
}

/// Error state after operation failed
class DailyReportOperationFailure extends DailyReportsState {
  final String message;
  final String operationType;

  DailyReportOperationFailure({
    required this.message,
    required this.operationType,
  });

  @override
  List<Object?> get props => [message, operationType];
}

/// Error state for specific report operations (delete, update, etc.)
class DailyReportOperationError extends DailyReportsState {
  final String message;
  final String? reportId;
  final String? operation;

  DailyReportOperationError({
    required this.message,
    this.reportId,
    this.operation,
  });

  @override
  List<Object?> get props => [message, reportId, operation];
}

/// Loading state for report operations
class DailyReportOperationLoading extends DailyReportsState {}

// Draft Management States

/// Draft saved locally
class DailyReportDraftSaved extends DailyReportsState {
  final DailyReport draftReport;

  DailyReportDraftSaved({required this.draftReport});

  @override
  List<Object?> get props => [draftReport];
}

/// Draft loaded from local storage
class DailyReportDraftLoaded extends DailyReportsState {
  final DailyReport draftReport;

  DailyReportDraftLoaded({required this.draftReport});

  @override
  List<Object?> get props => [draftReport];
}

// Image Upload States

/// Image upload in progress
class DailyReportImageUploadInProgress extends DailyReportsState {
  final int totalImages;
  final int uploadedCount;

  DailyReportImageUploadInProgress({
    required this.totalImages,
    required this.uploadedCount,
  });

  @override
  List<Object?> get props => [totalImages, uploadedCount];

  double get progress => totalImages > 0 ? uploadedCount / totalImages : 0;
}

/// Image upload success
class DailyReportImageUploadSuccess extends DailyReportsState {
  final String imageId;
  final List<String> imageIds;

  DailyReportImageUploadSuccess({this.imageId = '', this.imageIds = const []});

  @override
  List<Object?> get props => [imageId, imageIds];
}

/// Image upload failure
class DailyReportImageUploadFailure extends DailyReportsState {
  final String message;

  DailyReportImageUploadFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Image upload loading
class DailyReportImageUploadLoading extends DailyReportsState {}

/// Image upload error
class DailyReportImageUploadError extends DailyReportsState {
  final String message;

  DailyReportImageUploadError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Offline Sync States

/// State when reports are being synced from offline storage
class DailyReportOfflineSyncInProgress extends DailyReportsState {
  final int totalReports;
  final int syncedCount;

  DailyReportOfflineSyncInProgress({
    required this.totalReports,
    required this.syncedCount,
  });

  @override
  List<Object?> get props => [totalReports, syncedCount];

  double get progress => totalReports > 0 ? syncedCount / totalReports : 0;
}

/// State when offline sync is complete
class DailyReportOfflineSyncComplete extends DailyReportsState {
  final int successCount;
  final int failureCount;

  DailyReportOfflineSyncComplete({
    required this.successCount,
    required this.failureCount,
  });

  @override
  List<Object?> get props => [successCount, failureCount];
}

/// State for weather data fetching
class WeatherDataState extends DailyReportsState {
  final bool isLoading;
  final String? weatherData;
  final String? error;

  WeatherDataState({this.isLoading = false, this.weatherData, this.error});

  @override
  List<Object?> get props => [isLoading, weatherData, error];

  WeatherDataState copyWith({
    bool? isLoading,
    String? weatherData,
    String? error,
  }) {
    return WeatherDataState(
      isLoading: isLoading ?? this.isLoading,
      weatherData: weatherData ?? this.weatherData,
      error: error ?? this.error,
    );
  }
}
