import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/daily_report.dart';
import '../repositories/daily_report_repository.dart';

class GetDailyReports
    implements UseCase<DailyReportListResponse, GetDailyReportsParams> {
  final DailyReportRepository repository;

  GetDailyReports(this.repository);

  @override
  Future<Either<Failure, DailyReportListResponse>> call(
    GetDailyReportsParams params,
  ) {
    return repository.getDailyReports(
      pageNumber: params.pageNumber,
      pageSize: params.pageSize,
      projectId: params.projectId,
      technicianId: params.technicianId,
      status: params.status,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetDailyReportsParams extends Equatable {
  final int pageNumber;
  final int pageSize;
  final String? projectId;
  final String? technicianId;
  final DailyReportStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetDailyReportsParams({
    this.pageNumber = 1,
    this.pageSize = 10,
    this.projectId,
    this.technicianId,
    this.status,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
    pageNumber,
    pageSize,
    projectId,
    technicianId,
    status,
    startDate,
    endDate,
  ];
}
