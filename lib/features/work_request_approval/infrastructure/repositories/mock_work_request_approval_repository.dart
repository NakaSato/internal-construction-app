import 'package:dartz/dartz.dart';
import '../../domain/entities/work_request.dart';
import '../../domain/entities/approval_history.dart';
import '../../domain/entities/approval_statistics.dart';
import '../../domain/entities/approval_requests.dart';
import '../../domain/repositories/work_request_approval_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/mock_work_request_service.dart';

class MockWorkRequestApprovalRepository
    implements WorkRequestApprovalRepository {
  @override
  Future<Either<Failure, List<WorkRequest>>> getMyWorkRequests() async {
    try {
      final requests = await MockWorkRequestService.getMyWorkRequests();
      return Right(requests);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitForApproval(
    String requestId,
    String comments,
  ) async {
    try {
      await MockWorkRequestService.submitForApproval(requestId, comments);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkRequest>>> getPendingApprovals() async {
    try {
      final requests = await MockWorkRequestService.getPendingApprovals();
      return Right(requests);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkRequest>>> getAllPendingApprovals() async {
    try {
      final requests = await MockWorkRequestService.getAllPendingApprovals();
      return Right(requests);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> processApproval(
    String requestId,
    ProcessApprovalRequest request,
  ) async {
    try {
      await MockWorkRequestService.processApproval(
        requestId,
        request.action.value,
        request.comments,
        request.rejectionReason,
      );
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> escalateRequest(
    String requestId,
    EscalateRequest request,
  ) async {
    try {
      // Mock implementation - in real app this would call API
      await Future.delayed(const Duration(milliseconds: 300));
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> bulkApproval(
    BulkApprovalRequest request,
  ) async {
    try {
      // Mock implementation - in real app this would call API
      for (final requestId in request.workRequestIds) {
        await MockWorkRequestService.processApproval(
          requestId,
          request.action.value,
          request.comments,
          request.rejectionReason,
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkRequest>> getApprovalStatus(
    String requestId,
  ) async {
    try {
      final request = await MockWorkRequestService.getWorkRequest(requestId);
      if (request != null) {
        return Right(request);
      } else {
        return const Left(NotFoundFailure('Work request not found'));
      }
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ApprovalHistory>>> getApprovalHistory(
    String requestId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final history = await MockWorkRequestService.getApprovalHistory(
        requestId,
      );
      return Right(history);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ApprovalStatistics>> getApprovalStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Mock statistics
      final stats = ApprovalStatistics(
        totalSubmitted: 45,
        totalApproved: 38,
        totalRejected: 7,
        pendingCount: 12,
        averageApprovalTime: 2.5,
        approvalRate: 84.4,
        byStatus: {'Pending': 12, 'Approved': 38, 'Rejected': 7},
        byPriority: {'Low': 15, 'Medium': 20, 'High': 8, 'Critical': 2},
        startDate: startDate,
        endDate: endDate,
      );
      return Right(stats);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendApprovalReminders(
    SendRemindersRequest request,
  ) async {
    try {
      // Mock implementation - in real app this would call API
      await Future.delayed(const Duration(milliseconds: 500));
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
