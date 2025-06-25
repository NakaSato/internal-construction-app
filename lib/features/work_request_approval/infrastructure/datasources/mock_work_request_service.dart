import '../../domain/entities/work_request.dart';
import '../../domain/entities/approval_history.dart';

class MockWorkRequestService {
  static final List<WorkRequest> _mockRequests = [
    WorkRequest(
      id: 'wr_001',
      title: 'Solar Panel Maintenance',
      description:
          'Regular maintenance check for solar panels on building A roof',
      projectName: 'Manager Repair',
      priority: WorkRequestPriority.medium,
      estimatedCost: 1500.00,
      currentStatus: WorkRequestStatus.pendingApproval,
      submittedByName: 'Test User',
      submittedDate: DateTime.now().subtract(const Duration(days: 1)),
      submittedForApprovalDate: DateTime.now().subtract(
        const Duration(days: 1),
      ),
      daysPending: 1,
      nextApproverName: 'Manager Smith',
    ),
    WorkRequest(
      id: 'wr_002',
      title: 'Replace Inverter Unit',
      description: 'Install new 50kW inverter unit to replace faulty equipment',
      projectName: 'Capital Project',
      priority: WorkRequestPriority.high,
      estimatedCost: 5000.00,
      currentStatus: WorkRequestStatus.pendingApproval,
      submittedByName: 'Jane Doe',
      submittedDate: DateTime.now().subtract(const Duration(days: 3)),
      submittedForApprovalDate: DateTime.now().subtract(
        const Duration(days: 3),
      ),
      daysPending: 3,
      nextApproverName: 'Manager Smith',
    ),
    WorkRequest(
      id: 'wr_003',
      title: 'Repair Damaged Wiring',
      description: 'Fix damaged electrical wiring in the control room',
      projectName: 'Emergency Repair',
      priority: WorkRequestPriority.critical,
      estimatedCost: 2500.00,
      currentStatus: WorkRequestStatus.draft,
      submittedByName: 'Current User',
      submittedDate: DateTime.now().subtract(const Duration(hours: 2)),
      submittedForApprovalDate: null,
      daysPending: 0,
    ),
    WorkRequest(
      id: 'wr_004',
      title: 'Install New Monitoring System',
      description:
          'Deploy advanced monitoring system for real-time solar farm performance tracking',
      projectName: 'Technology Upgrade',
      priority: WorkRequestPriority.medium,
      estimatedCost: 8500.00,
      currentStatus: WorkRequestStatus.approved,
      submittedByName: 'Tech Team Lead',
      submittedDate: DateTime.now().subtract(const Duration(days: 7)),
      submittedForApprovalDate: DateTime.now().subtract(
        const Duration(days: 7),
      ),
      lastActionDate: DateTime.now().subtract(const Duration(days: 2)),
      daysPending: 0,
    ),
    WorkRequest(
      id: 'wr_005',
      title: 'Battery Storage Expansion',
      description: 'Add 100kWh battery storage capacity to the existing system',
      projectName: 'Capacity Expansion',
      priority: WorkRequestPriority.low,
      estimatedCost: 15000.00,
      currentStatus: WorkRequestStatus.rejected,
      submittedByName: 'Project Manager',
      submittedDate: DateTime.now().subtract(const Duration(days: 10)),
      submittedForApprovalDate: DateTime.now().subtract(
        const Duration(days: 10),
      ),
      lastActionDate: DateTime.now().subtract(const Duration(days: 5)),
      daysPending: 0,
    ),
  ];

  static final List<ApprovalHistory> _mockHistory = [
    ApprovalHistory(
      id: 'ah_001',
      workRequestId: 'wr_004',
      action: 'AdminApproved',
      newStatus: 'Approved',
      approverName: 'Admin User',
      processedAt: DateTime.now().subtract(const Duration(days: 2)),
      comments:
          'Final approval granted. Excellent project scope and detailed implementation plan.',
    ),
    ApprovalHistory(
      id: 'ah_002',
      workRequestId: 'wr_004',
      action: 'ManagerApproved',
      newStatus: 'Pending Admin Approval',
      approverName: 'Manager Smith',
      processedAt: DateTime.now().subtract(const Duration(days: 4)),
      comments:
          'Project looks promising. Technology upgrade is needed. Forwarding to admin.',
    ),
    ApprovalHistory(
      id: 'ah_003',
      workRequestId: 'wr_004',
      action: 'Submitted',
      newStatus: 'Pending Manager Approval',
      approverName: 'System',
      processedAt: DateTime.now().subtract(const Duration(days: 7)),
      comments: 'Work request submitted for approval process.',
    ),
  ];

  static Future<List<WorkRequest>> getMyWorkRequests() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockRequests
        .where(
          (request) =>
              request.submittedByName == 'Current User' ||
              request.submittedByName == 'Test User',
        )
        .toList();
  }

  static Future<List<WorkRequest>> getPendingApprovals() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockRequests
        .where(
          (request) =>
              request.currentStatus == WorkRequestStatus.pendingApproval,
        )
        .toList();
  }

  static Future<List<WorkRequest>> getAllPendingApprovals() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockRequests
        .where(
          (request) =>
              request.currentStatus == WorkRequestStatus.pendingApproval,
        )
        .toList();
  }

  static Future<void> submitForApproval(
    String requestId,
    String comments,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _mockRequests[index] = _mockRequests[index].copyWith(
        currentStatus: WorkRequestStatus.pendingApproval,
        submittedForApprovalDate: DateTime.now(),
        daysPending: 0,
        nextApproverName: 'Manager Smith',
      );
    }
  }

  static Future<void> processApproval(
    String requestId,
    String action,
    String? comments,
    String? rejectionReason,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      final newStatus = action == 'approve'
          ? WorkRequestStatus.approved
          : WorkRequestStatus.rejected;

      _mockRequests[index] = _mockRequests[index].copyWith(
        currentStatus: newStatus,
        lastActionDate: DateTime.now(),
        daysPending: 0,
        nextApproverName: null,
      );

      // Add to history
      _mockHistory.insert(
        0,
        ApprovalHistory(
          id: 'ah_${DateTime.now().millisecondsSinceEpoch}',
          workRequestId: requestId,
          action: action == 'approve' ? 'Approved' : 'Rejected',
          newStatus: newStatus.displayName,
          approverName: 'Current Approver',
          processedAt: DateTime.now(),
          comments: comments,
          rejectionReason: rejectionReason,
        ),
      );
    }
  }

  static Future<List<ApprovalHistory>> getApprovalHistory(
    String requestId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockHistory.where((h) => h.workRequestId == requestId).toList();
  }

  static Future<WorkRequest?> getWorkRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockRequests.firstWhere((r) => r.id == requestId);
    } catch (e) {
      return null;
    }
  }
}
