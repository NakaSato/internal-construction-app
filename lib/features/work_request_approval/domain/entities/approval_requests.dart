import 'package:equatable/equatable.dart';

class ProcessApprovalRequest extends Equatable {
  const ProcessApprovalRequest({
    required this.action,
    this.comments,
    this.rejectionReason,
  });

  final ApprovalAction action;
  final String? comments;
  final String? rejectionReason;

  @override
  List<Object?> get props => [action, comments, rejectionReason];
}

class EscalateRequest extends Equatable {
  const EscalateRequest({required this.reason, this.comments});

  final String reason;
  final String? comments;

  @override
  List<Object?> get props => [reason, comments];
}

class BulkApprovalRequest extends Equatable {
  const BulkApprovalRequest({
    required this.workRequestIds,
    required this.action,
    this.comments,
    this.rejectionReason,
  });

  final List<String> workRequestIds;
  final ApprovalAction action;
  final String? comments;
  final String? rejectionReason;

  @override
  List<Object?> get props => [
    workRequestIds,
    action,
    comments,
    rejectionReason,
  ];
}

class SendRemindersRequest extends Equatable {
  const SendRemindersRequest({
    required this.daysPending,
    required this.includeEscalation,
  });

  final int daysPending;
  final bool includeEscalation;

  @override
  List<Object> get props => [daysPending, includeEscalation];
}

enum ApprovalAction {
  approve('approve'),
  reject('reject');

  const ApprovalAction(this.value);
  final String value;
}
