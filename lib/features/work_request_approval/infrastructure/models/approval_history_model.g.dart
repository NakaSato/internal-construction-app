// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approval_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApprovalHistoryModel _$ApprovalHistoryModelFromJson(
  Map<String, dynamic> json,
) => ApprovalHistoryModel(
  id: json['id'] as String,
  workRequestId: json['workRequestId'] as String,
  action: json['action'] as String,
  newStatus: json['newStatus'] as String,
  approverName: json['approverName'] as String,
  processedAt: json['processedAt'] as String,
  comments: json['comments'] as String?,
  rejectionReason: json['rejectionReason'] as String?,
);

Map<String, dynamic> _$ApprovalHistoryModelToJson(
  ApprovalHistoryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'workRequestId': instance.workRequestId,
  'action': instance.action,
  'newStatus': instance.newStatus,
  'approverName': instance.approverName,
  'processedAt': instance.processedAt,
  'comments': instance.comments,
  'rejectionReason': instance.rejectionReason,
};
