import 'package:equatable/equatable.dart';

class ApprovalHistory extends Equatable {
  const ApprovalHistory({
    required this.id,
    required this.workRequestId,
    required this.action,
    required this.newStatus,
    required this.approverName,
    required this.processedAt,
    this.comments,
    this.rejectionReason,
  });

  final String id;
  final String workRequestId;
  final String action;
  final String newStatus;
  final String approverName;
  final DateTime processedAt;
  final String? comments;
  final String? rejectionReason;

  @override
  List<Object?> get props => [
    id,
    workRequestId,
    action,
    newStatus,
    approverName,
    processedAt,
    comments,
    rejectionReason,
  ];
}
