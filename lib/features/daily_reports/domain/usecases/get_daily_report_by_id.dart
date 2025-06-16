import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../common/models/errors/failures.dart';
import '../../../../common/models/usecase/usecase.dart';
import '../entities/daily_report.dart';
import '../repositories/daily_report_repository.dart';

class GetDailyReportById
    implements UseCase<DailyReport, GetDailyReportByIdParams> {
  final DailyReportRepository repository;

  GetDailyReportById(this.repository);

  @override
  Future<Either<Failure, DailyReport>> call(GetDailyReportByIdParams params) {
    return repository.getDailyReportById(params.reportId);
  }
}

class GetDailyReportByIdParams extends Equatable {
  final String reportId;

  const GetDailyReportByIdParams(this.reportId);

  @override
  List<Object> get props => [reportId];
}
