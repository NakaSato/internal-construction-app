import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../common/models/errors/failures.dart';
import '../../../../common/models/usecase/usecase.dart';
import '../entities/daily_report.dart';
import '../repositories/daily_report_repository.dart';

class CreateDailyReport
    implements UseCase<DailyReport, CreateDailyReportParams> {
  final DailyReportRepository repository;

  CreateDailyReport(this.repository);

  @override
  Future<Either<Failure, DailyReport>> call(CreateDailyReportParams params) {
    return repository.createDailyReport(params.report);
  }
}

class CreateDailyReportParams extends Equatable {
  final DailyReport report;

  const CreateDailyReportParams(this.report);

  @override
  List<Object> get props => [report];
}
