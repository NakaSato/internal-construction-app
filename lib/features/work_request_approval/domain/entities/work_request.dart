import 'package:equatable/equatable.dart';

class WorkRequest extends Equatable {
  const WorkRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.projectName,
    required this.priority,
    required this.estimatedCost,
    required this.currentStatus,
    required this.submittedByName,
    required this.submittedDate,
    required this.submittedForApprovalDate,
    this.lastActionDate,
    this.nextApproverName,
    this.daysPending = 0,
  });

  final String id;
  final String title;
  final String description;
  final String projectName;
  final WorkRequestPriority priority;
  final double estimatedCost;
  final WorkRequestStatus currentStatus;
  final String submittedByName;
  final DateTime submittedDate;
  final DateTime? submittedForApprovalDate;
  final DateTime? lastActionDate;
  final String? nextApproverName;
  final int daysPending;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    projectName,
    priority,
    estimatedCost,
    currentStatus,
    submittedByName,
    submittedDate,
    submittedForApprovalDate,
    lastActionDate,
    nextApproverName,
    daysPending,
  ];

  WorkRequest copyWith({
    String? id,
    String? title,
    String? description,
    String? projectName,
    WorkRequestPriority? priority,
    double? estimatedCost,
    WorkRequestStatus? currentStatus,
    String? submittedByName,
    DateTime? submittedDate,
    DateTime? submittedForApprovalDate,
    DateTime? lastActionDate,
    String? nextApproverName,
    int? daysPending,
  }) {
    return WorkRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectName: projectName ?? this.projectName,
      priority: priority ?? this.priority,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      currentStatus: currentStatus ?? this.currentStatus,
      submittedByName: submittedByName ?? this.submittedByName,
      submittedDate: submittedDate ?? this.submittedDate,
      submittedForApprovalDate:
          submittedForApprovalDate ?? this.submittedForApprovalDate,
      lastActionDate: lastActionDate ?? this.lastActionDate,
      nextApproverName: nextApproverName ?? this.nextApproverName,
      daysPending: daysPending ?? this.daysPending,
    );
  }
}

enum WorkRequestStatus {
  draft('Draft'),
  pendingApproval('Pending Approval'),
  approved('Approved'),
  rejected('Rejected'),
  escalated('Escalated');

  const WorkRequestStatus(this.displayName);
  final String displayName;
}

enum WorkRequestPriority {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  const WorkRequestPriority(this.displayName);
  final String displayName;
}
