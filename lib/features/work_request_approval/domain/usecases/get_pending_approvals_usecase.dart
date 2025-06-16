import 'package:dartz/dartz.dart';
import '../entities/work_request.dart';
import '../repositories/work_request_approval_repository.dart';
import '../../../../common/models/errors/failures.dart';

class GetPendingApprovalsUseCase {
  const GetPendingApprovalsUseCase(this._repository);

  final WorkRequestApprovalRepository _repository;

  Future<Either<Failure, List<WorkRequest>>> call() async {
    return await _repository.getPendingApprovals();
  }
}
