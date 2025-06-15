import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/approval_history.dart';

part 'approval_history_model.g.dart';

@JsonSerializable()
class ApprovalHistoryModel {
  const ApprovalHistoryModel({
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
  final String processedAt;
  final String? comments;
  final String? rejectionReason;

  factory ApprovalHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$ApprovalHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ApprovalHistoryModelToJson(this);

  ApprovalHistory toEntity() {
    return ApprovalHistory(
      id: id,
      workRequestId: workRequestId,
      action: action,
      newStatus: newStatus,
      approverName: approverName,
      processedAt: DateTime.parse(processedAt),
      comments: comments,
      rejectionReason: rejectionReason,
    );
  }
}
