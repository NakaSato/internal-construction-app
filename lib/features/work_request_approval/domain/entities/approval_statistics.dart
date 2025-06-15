import 'package:equatable/equatable.dart';

class ApprovalStatistics extends Equatable {
  const ApprovalStatistics({
    required this.totalSubmitted,
    required this.totalApproved,
    required this.totalRejected,
    required this.pendingCount,
    required this.averageApprovalTime,
    required this.approvalRate,
    required this.byStatus,
    required this.byPriority,
    required this.startDate,
    required this.endDate,
  });

  final int totalSubmitted;
  final int totalApproved;
  final int totalRejected;
  final int pendingCount;
  final double averageApprovalTime;
  final double approvalRate;
  final Map<String, int> byStatus;
  final Map<String, int> byPriority;
  final DateTime startDate;
  final DateTime endDate;

  @override
  List<Object> get props => [
    totalSubmitted,
    totalApproved,
    totalRejected,
    pendingCount,
    averageApprovalTime,
    approvalRate,
    byStatus,
    byPriority,
    startDate,
    endDate,
  ];
}
