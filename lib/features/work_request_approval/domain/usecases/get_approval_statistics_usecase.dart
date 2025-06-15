import 'package:dartz/dartz.dart';
import '../entities/approval_statistics.dart';
import '../repositories/work_request_approval_repository.dart';
import '../../../../core/errors/failures.dart';

class GetApprovalStatisticsUseCase {
  const GetApprovalStatisticsUseCase(this._repository);

  final WorkRequestApprovalRepository _repository;

  Future<Either<Failure, ApprovalStatistics>> call({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _repository.getApprovalStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
