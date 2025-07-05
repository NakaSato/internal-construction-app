import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../common/models/errors/failures.dart';
import '../../domain/entities/daily_report.dart';
import '../../domain/repositories/daily_report_repository.dart';
import '../../infrastructure/services/daily_reports_api_service.dart';

/// API-based daily report repository
/// Provides clean interface for real-time wrapper integration
@Injectable()
class ApiDailyReportRepository implements DailyReportRepository {
  ApiDailyReportRepository(this._apiService);

  final DailyReportsApiService _apiService;

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
    try {
      final response = await _apiService.getDailyReports(projectId: projectId, startDate: startDate, endDate: endDate);

      // Convert ApiResponse to DailyReportListResponse
      final reports = (response.data ?? []).map((dto) => _dtoToEntity(dto)).toList();

      return Right(
        DailyReportListResponse(
          reports: reports,
          totalCount: reports.length,
          pageNumber: pageNumber,
          pageSize: pageSize,
          totalPages: (reports.length / pageSize).ceil(),
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DailyReport>> getDailyReportById(String reportId) async {
    try {
      final response = await _apiService.getDailyReport(reportId);
      if (response.data != null) {
        return Right(_dtoToEntity(response.data!));
      } else {
        return Left(NotFoundFailure('Daily report not found'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DailyReport>> createDailyReport(DailyReport report) async {
    try {
      // For now, use simplified request structure
      final request = CreateDailyReportRequest(
        projectId: report.projectId,
        reportDate: report.reportDate,
        workDescription: report.overallNotes, // Map overallNotes to workDescription
        hoursWorked: 8.0, // Default value
        notes: report.overallNotes,
      );

      final response = await _apiService.createDailyReport(request);
      if (response.data != null) {
        return Right(_dtoToEntity(response.data!));
      } else {
        return Left(ServerFailure('Failed to create daily report'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DailyReport>> updateDailyReport(DailyReport report) async {
    try {
      // For now, use simplified request structure
      final request = UpdateDailyReportRequest(
        workDescription: report.overallNotes, // Map overallNotes to workDescription
        hoursWorked: 8.0, // Default value
        notes: report.overallNotes,
      );

      final response = await _apiService.updateDailyReport(report.reportId, request);
      if (response.data != null) {
        return Right(_dtoToEntity(response.data!));
      } else {
        return Left(ServerFailure('Failed to update daily report'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDailyReport(String reportId) async {
    try {
      await _apiService.deleteDailyReport(reportId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Simple implementations for required methods (can be enhanced later)

  @override
  Future<Either<Failure, DailyReport>> submitDailyReport(String reportId) async {
    // Mock implementation - would integrate with actual API
    return Left(UnimplementedFailure('Submit daily report not implemented yet'));
  }

  @override
  Future<Either<Failure, DailyReport>> approveDailyReport(String reportId, String? comments) async {
    // Mock implementation - would integrate with actual API
    return Left(UnimplementedFailure('Approve daily report not implemented yet'));
  }

  @override
  Future<Either<Failure, DailyReport>> rejectDailyReport(String reportId, String reason) async {
    // Mock implementation - would integrate with actual API
    return Left(UnimplementedFailure('Reject daily report not implemented yet'));
  }

  @override
  Future<Either<Failure, String>> uploadDailyReportImage(String reportId, String imagePath) async {
    // Mock implementation - would integrate with actual API
    return Left(UnimplementedFailure('Upload image not implemented yet'));
  }

  @override
  Future<Either<Failure, void>> deleteImage(String reportId, String imageId) async {
    // Mock implementation - would integrate with actual API
    return Left(UnimplementedFailure('Delete image not implemented yet'));
  }

  @override
  Future<Either<Failure, DailyReport>> saveDraftLocally(DailyReport report) async {
    // Mock implementation - would integrate with local storage
    return Left(UnimplementedFailure('Save draft locally not implemented yet'));
  }

  @override
  Future<Either<Failure, List<DailyReport>>> getLocalDrafts() async {
    // Mock implementation - would integrate with local storage
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<DailyReport>>> syncLocalDrafts() async {
    // Mock implementation - would integrate with actual sync logic
    return const Right([]);
  }

  /// Helper method to convert DTO to Entity
  DailyReport _dtoToEntity(DailyReportDto dto) {
    return DailyReport(
      reportId: dto.id,
      projectId: dto.projectId,
      technicianId: dto.userId, // Map userId to technicianId
      reportDate: dto.reportDate,
      status: DailyReportStatus.draft, // Default status
      workStartTime: '08:00', // Default value
      workEndTime: '17:00', // Default value
      weatherConditions: dto.weather ?? 'N/A',
      overallNotes: dto.workDescription,
      safetyNotes: dto.safety ?? '',
      delaysOrIssues: dto.issues ?? '',
      photosCount: dto.images?.length ?? 0,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}

/// Failure for unimplemented features
class UnimplementedFailure extends Failure {
  const UnimplementedFailure(super.message);

  @override
  List<Object> get props => [message];
}

/// Failure for not found resources
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);

  @override
  List<Object> get props => [message];
}
