import 'package:dartz/dartz.dart';
import '../entities/approval_requests.dart';
import '../repositories/work_request_approval_repository.dart';
import '../../../../core/errors/failures.dart';

class ProcessApprovalUseCase {
  const ProcessApprovalUseCase(this._repository);

  final WorkRequestApprovalRepository _repository;

  Future<Either<Failure, void>> call(
    String requestId,
    ProcessApprovalRequest request,
  ) async {
    return await _repository.processApproval(requestId, request);
  }
}
