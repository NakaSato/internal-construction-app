import 'package:dartz/dartz.dart';
import '../entities/work_request.dart';
import '../entities/approval_history.dart';
import '../entities/approval_statistics.dart';
import '../entities/approval_requests.dart';
import '../../../../core/errors/failures.dart';

abstract class WorkRequestApprovalRepository {
  // User's own work requests
  Future<Either<Failure, List<WorkRequest>>> getMyWorkRequests();

  // Submit a draft for approval
  Future<Either<Failure, void>> submitForApproval(
    String requestId,
    String comments,
  );

  // Pending approvals for current user
  Future<Either<Failure, List<WorkRequest>>> getPendingApprovals();

  // All pending requests (admin only)
  Future<Either<Failure, List<WorkRequest>>> getAllPendingApprovals();

  // Process approval decision
  Future<Either<Failure, void>> processApproval(
    String requestId,
    ProcessApprovalRequest request,
  );

  // Escalate request
  Future<Either<Failure, void>> escalateRequest(
    String requestId,
    EscalateRequest request,
  );

  // Bulk approval actions
  Future<Either<Failure, void>> bulkApproval(BulkApprovalRequest request);

  // Get approval status
  Future<Either<Failure, WorkRequest>> getApprovalStatus(String requestId);

  // Get approval history
  Future<Either<Failure, List<ApprovalHistory>>> getApprovalHistory(
    String requestId, {
    int page = 1,
    int limit = 20,
  });

  // Get approval statistics
  Future<Either<Failure, ApprovalStatistics>> getApprovalStatistics({
    required DateTime startDate,
    required DateTime endDate,
  });

  // Send approval reminders
  Future<Either<Failure, void>> sendApprovalReminders(
    SendRemindersRequest request,
  );
}
