import 'package:dartz/dartz.dart';
import '../entities/approval_history.dart';
import '../repositories/work_request_approval_repository.dart';
import '../../../../core/errors/failures.dart';

class GetApprovalHistoryUseCase {
  const GetApprovalHistoryUseCase(this._repository);

  final WorkRequestApprovalRepository _repository;

  Future<Either<Failure, List<ApprovalHistory>>> call(
    String requestId, {
    int page = 1,
    int limit = 20,
  }) async {
    return await _repository.getApprovalHistory(
      requestId,
      page: page,
      limit: limit,
    );
  }
}
