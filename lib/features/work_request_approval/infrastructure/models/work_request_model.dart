import 'package:equatable/equatable.dart';
import '../../domain/entities/work_request.dart';

class WorkRequestModel extends Equatable {
  const WorkRequestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.projectName,
    required this.priority,
    required this.estimatedCost,
    required this.currentStatus,
    required this.submittedByName,
    required this.submittedDate,
    this.submittedForApprovalDate,
    this.lastActionDate,
    this.nextApproverName,
    this.daysPending = 0,
  });

  final String id;
  final String title;
  final String description;
  final String projectName;
  final String priority;
  final double estimatedCost;
  final String currentStatus;
  final String submittedByName;
  final String submittedDate;
  final String? submittedForApprovalDate;
  final String? lastActionDate;
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

  factory WorkRequestModel.fromJson(Map<String, dynamic> json) {
    return WorkRequestModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      projectName: json['projectName']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'medium',
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
      currentStatus: json['currentStatus']?.toString() ?? 'draft',
      submittedByName: json['submittedByName']?.toString() ?? '',
      submittedDate:
          json['submittedDate']?.toString() ?? DateTime.now().toIso8601String(),
      submittedForApprovalDate: json['submittedForApprovalDate']?.toString(),
      lastActionDate: json['lastActionDate']?.toString(),
      nextApproverName: json['nextApproverName']?.toString(),
      daysPending: (json['daysPending'] as num?)?.toInt() ?? 0,
    );
  }

  WorkRequest toEntity() {
    return WorkRequest(
      id: id.isEmpty ? 'unknown' : id,
      title: title.isEmpty ? 'Untitled Request' : title,
      description: description,
      projectName: projectName.isEmpty ? 'Unknown Project' : projectName,
      priority: _mapPriority(priority),
      estimatedCost: estimatedCost,
      currentStatus: _mapStatus(currentStatus),
      submittedByName: submittedByName.isEmpty
          ? 'Unknown User'
          : submittedByName,
      submittedDate: submittedDate.isNotEmpty
          ? DateTime.tryParse(submittedDate) ?? DateTime.now()
          : DateTime.now(),
      submittedForApprovalDate: submittedForApprovalDate != null
          ? DateTime.tryParse(submittedForApprovalDate!)
          : null,
      lastActionDate: lastActionDate != null
          ? DateTime.tryParse(lastActionDate!)
          : null,
      nextApproverName: nextApproverName,
      daysPending: daysPending,
    );
  }

  static WorkRequestModel fromEntity(WorkRequest entity) {
    return WorkRequestModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      projectName: entity.projectName,
      priority: entity.priority.name,
      estimatedCost: entity.estimatedCost,
      currentStatus: entity.currentStatus.name,
      submittedByName: entity.submittedByName,
      submittedDate: entity.submittedDate.toIso8601String(),
      submittedForApprovalDate: entity.submittedForApprovalDate
          ?.toIso8601String(),
      lastActionDate: entity.lastActionDate?.toIso8601String(),
      nextApproverName: entity.nextApproverName,
      daysPending: entity.daysPending,
    );
  }

  WorkRequestStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return WorkRequestStatus.draft;
      case 'pending_approval':
      case 'pendingapproval':
        return WorkRequestStatus.pendingApproval;
      case 'approved':
        return WorkRequestStatus.approved;
      case 'rejected':
        return WorkRequestStatus.rejected;
      case 'escalated':
        return WorkRequestStatus.escalated;
      default:
        return WorkRequestStatus.draft;
    }
  }

  WorkRequestPriority _mapPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return WorkRequestPriority.low;
      case 'medium':
        return WorkRequestPriority.medium;
      case 'high':
        return WorkRequestPriority.high;
      case 'critical':
        return WorkRequestPriority.critical;
      default:
        return WorkRequestPriority.medium;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectName': projectName,
      'priority': priority,
      'estimatedCost': estimatedCost,
      'currentStatus': currentStatus,
      'submittedByName': submittedByName,
      'submittedDate': submittedDate,
      'submittedForApprovalDate': submittedForApprovalDate,
      'lastActionDate': lastActionDate,
      'nextApproverName': nextApproverName,
      'daysPending': daysPending,
    };
  }
}
