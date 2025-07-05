import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../common/models/errors/failures.dart';
import '../../../../core/mixins/realtime_api_mixin.dart';
import '../../../../core/services/realtime_api_streams.dart';
import '../../domain/entities/daily_report.dart';
import '../../domain/repositories/daily_report_repository.dart';
import 'api_daily_report_repository.dart';

/// Real-time enhanced daily report repository wrapper
/// Adds real-time update capabilities to daily report management
@Injectable(as: DailyReportRepository, env: [Environment.dev, Environment.prod])
class RealtimeDailyReportRepositoryWrapper with RealtimeApiMixin implements DailyReportRepository {
  RealtimeDailyReportRepositoryWrapper(this._baseRepository);

  final ApiDailyReportRepository _baseRepository;

  @override
  String get endpointName => 'daily-reports';

  /// Initialize real-time updates for this repository
  Future<void> initializeRealtimeCapabilities() async {
    startRealtimeUpdates<RealtimeDailyReportUpdate>(
      onUpdate: (update) {
        debugPrint('📋 RealtimeDailyReportRepositoryWrapper: Received real-time daily report update: ${update.type}');
        // Real-time updates will be handled by the BLoC layer
        // This repository serves as a bridge for data access
      },
      onError: (error) {
        debugPrint('❌ RealtimeDailyReportRepositoryWrapper: Real-time error: $error');
      },
    );
  }

  // Delegate all methods to base repository while adding real-time markers

  @override
  Future<Either<Failure, DailyReportListResponse>> getDailyReports({
    int pageNumber = 1,
    int pageSize = 10,
    String? projectId,
    String? technicianId,
    DailyReportStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (kDebugMode) {
      debugPrint('📋 RealtimeDailyReportRepositoryWrapper.getDailyReports called with real-time support');
    }
    return await _baseRepository.getDailyReports(
      pageNumber: pageNumber,
      pageSize: pageSize,
      projectId: projectId,
      technicianId: technicianId,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Either<Failure, DailyReport>> getDailyReportById(String reportId) async {
    if (kDebugMode) {
      debugPrint('🔍 RealtimeDailyReportRepositoryWrapper.getDailyReportById called with real-time support');
    }
    return await _baseRepository.getDailyReportById(reportId);
  }

  @override
  Future<Either<Failure, DailyReport>> createDailyReport(DailyReport report) async {
    if (kDebugMode) {
      debugPrint('🆕 RealtimeDailyReportRepositoryWrapper.createDailyReport called with real-time notifications');
    }

    return await _baseRepository.createDailyReport(report);
  }

  @override
  Future<Either<Failure, DailyReport>> updateDailyReport(DailyReport report) async {
    if (kDebugMode) {
      debugPrint('✏️ RealtimeDailyReportRepositoryWrapper.updateDailyReport called with real-time notifications');
    }

    return await _baseRepository.updateDailyReport(report);
  }

  @override
  Future<Either<Failure, void>> deleteDailyReport(String reportId) async {
    if (kDebugMode) {
      debugPrint('🗑️ RealtimeDailyReportRepositoryWrapper.deleteDailyReport called with real-time notifications');
    }

    return await _baseRepository.deleteDailyReport(reportId);
  }

  @override
  Future<Either<Failure, DailyReport>> submitDailyReport(String reportId) async {
    if (kDebugMode) {
      debugPrint('📤 RealtimeDailyReportRepositoryWrapper.submitDailyReport called with real-time notifications');
    }

    return await _baseRepository.submitDailyReport(reportId);
  }

  @override
  Future<Either<Failure, DailyReport>> approveDailyReport(String reportId, String? comments) async {
    if (kDebugMode) {
      debugPrint('✅ RealtimeDailyReportRepositoryWrapper.approveDailyReport called with real-time notifications');
    }

    return await _baseRepository.approveDailyReport(reportId, comments);
  }

  @override
  Future<Either<Failure, DailyReport>> rejectDailyReport(String reportId, String reason) async {
    if (kDebugMode) {
      debugPrint('❌ RealtimeDailyReportRepositoryWrapper.rejectDailyReport called with real-time notifications');
    }

    return await _baseRepository.rejectDailyReport(reportId, reason);
  }

  @override
  Future<Either<Failure, String>> uploadDailyReportImage(String reportId, String imagePath) async {
    if (kDebugMode) {
      debugPrint('📸 RealtimeDailyReportRepositoryWrapper.uploadDailyReportImage called with real-time notifications');
    }

    return await _baseRepository.uploadDailyReportImage(reportId, imagePath);
  }

  @override
  Future<Either<Failure, void>> deleteImage(String reportId, String imageId) async {
    if (kDebugMode) {
      debugPrint('🗑️ RealtimeDailyReportRepositoryWrapper.deleteImage called with real-time notifications');
    }

    return await _baseRepository.deleteImage(reportId, imageId);
  }

  @override
  Future<Either<Failure, DailyReport>> saveDraftLocally(DailyReport report) async {
    return await _baseRepository.saveDraftLocally(report);
  }

  @override
  Future<Either<Failure, List<DailyReport>>> getLocalDrafts() async {
    return await _baseRepository.getLocalDrafts();
  }

  @override
  Future<Either<Failure, List<DailyReport>>> syncLocalDrafts() async {
    if (kDebugMode) {
      debugPrint('🔄 RealtimeDailyReportRepositoryWrapper.syncLocalDrafts called with real-time notifications');
    }

    return await _baseRepository.syncLocalDrafts();
  }

  /// Dispose real-time resources when no longer needed
  void dispose() {
    disposeRealtime();
    if (kDebugMode) {
      debugPrint('🧹 RealtimeDailyReportRepositoryWrapper: Disposing real-time daily report repository');
    }
  }
}
