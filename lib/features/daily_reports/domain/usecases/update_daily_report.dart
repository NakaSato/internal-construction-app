import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/daily_report.dart';
import '../repositories/daily_report_repository.dart';

class UpdateDailyReport
    implements UseCase<DailyReport, UpdateDailyReportParams> {
  final DailyReportRepository repository;

  UpdateDailyReport(this.repository);

  @override
  Future<Either<Failure, DailyReport>> call(UpdateDailyReportParams params) {
    return repository.updateDailyReport(params.report);
  }
}

class UpdateDailyReportParams extends Equatable {
  final DailyReport report;

  const UpdateDailyReportParams(this.report);

  @override
  List<Object> get props => [report];
}
