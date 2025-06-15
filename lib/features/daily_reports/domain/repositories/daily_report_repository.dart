import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/daily_report.dart';

/// Repository interface for daily report operations
abstract class DailyReportRepository {
  /// Get all daily reports with pagination and filtering
  Future<Either<Failure, DailyReportListResponse>> getDailyReports({
    int pageNumber = 1,
    int pageSize = 10,
    String? projectId,
    String? technicianId,
    DailyReportStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get daily report by ID
  Future<Either<Failure, DailyReport>> getDailyReportById(String reportId);

  /// Create new daily report
  Future<Either<Failure, DailyReport>> createDailyReport(DailyReport report);

  /// Update existing daily report
  Future<Either<Failure, DailyReport>> updateDailyReport(DailyReport report);

  /// Delete daily report
  Future<Either<Failure, void>> deleteDailyReport(String reportId);

  /// Submit daily report for approval
  Future<Either<Failure, DailyReport>> submitDailyReport(String reportId);

  /// Approve daily report
  Future<Either<Failure, DailyReport>> approveDailyReport(
    String reportId,
    String? comments,
  );

  /// Reject daily report
  Future<Either<Failure, DailyReport>> rejectDailyReport(
    String reportId,
    String reason,
  );

  /// Upload image for daily report
  Future<Either<Failure, String>> uploadDailyReportImage(
    String reportId,
    String imagePath,
  );

  /// Delete image from daily report
  Future<Either<Failure, void>> deleteImage(String reportId, String imageId);

  /// Save draft report locally (offline support)
  Future<Either<Failure, DailyReport>> saveDraftLocally(DailyReport report);

  /// Get locally saved drafts
  Future<Either<Failure, List<DailyReport>>> getLocalDrafts();

  /// Sync local drafts with server when online
  Future<Either<Failure, List<DailyReport>>> syncLocalDrafts();
}

/// Daily report list response with pagination data
class DailyReportListResponse {
  final List<DailyReport> reports;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  DailyReportListResponse({
    required this.reports,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });
}
