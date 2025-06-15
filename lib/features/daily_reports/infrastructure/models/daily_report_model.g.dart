// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyReportModel _$DailyReportModelFromJson(Map<String, dynamic> json) =>
    DailyReportModel(
      reportId: json['id'] as String,
      projectId: json['projectId'] as String,
      technicianId: json['technicianId'] as String,
      reportDate: json['reportDate'] as String,
      statusValue: (json['status'] as num).toInt(),
      workStartTime: json['workStartTime'] as String,
      workEndTime: json['workEndTime'] as String,
      weatherConditions: json['weatherConditions'] as String,
      overallNotes: json['overallNotes'] as String,
      safetyNotes: json['safetyNotes'] as String,
      delaysOrIssues: json['delaysOrIssues'] as String,
      photosCount: (json['photosCount'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      project: json['project'] == null
          ? null
          : ProjectInfoModel.fromJson(json['project'] as Map<String, dynamic>),
      technician: json['technician'] == null
          ? null
          : TechnicianInfoModel.fromJson(
              json['technician'] as Map<String, dynamic>,
            ),
      workProgressItems: (json['workProgressItems'] as List<dynamic>?)
          ?.map(
            (e) => WorkProgressItemModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      personnelLogs: (json['personnelLogs'] as List<dynamic>?)
          ?.map((e) => PersonnelLogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      materialUsage: (json['materialUsage'] as List<dynamic>?)
          ?.map((e) => MaterialUsageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      equipmentLogs: (json['equipmentLogs'] as List<dynamic>?)
          ?.map((e) => EquipmentLogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      approverComments: json['approverComments'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      submittedAt: json['submittedAt'] as String?,
      approvedAt: json['approvedAt'] as String?,
      rejectedAt: json['rejectedAt'] as String?,
    );

Map<String, dynamic> _$DailyReportModelToJson(DailyReportModel instance) =>
    <String, dynamic>{
      'id': instance.reportId,
      'projectId': instance.projectId,
      'technicianId': instance.technicianId,
      'reportDate': instance.reportDate,
      'status': instance.statusValue,
      'workStartTime': instance.workStartTime,
      'workEndTime': instance.workEndTime,
      'weatherConditions': instance.weatherConditions,
      'overallNotes': instance.overallNotes,
      'safetyNotes': instance.safetyNotes,
      'delaysOrIssues': instance.delaysOrIssues,
      'photosCount': instance.photosCount,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'project': instance.project,
      'technician': instance.technician,
      'workProgressItems': instance.workProgressItems,
      'personnelLogs': instance.personnelLogs,
      'materialUsage': instance.materialUsage,
      'equipmentLogs': instance.equipmentLogs,
      'approverComments': instance.approverComments,
      'rejectionReason': instance.rejectionReason,
      'submittedAt': instance.submittedAt,
      'approvedAt': instance.approvedAt,
      'rejectedAt': instance.rejectedAt,
    };

ProjectInfoModel _$ProjectInfoModelFromJson(Map<String, dynamic> json) =>
    ProjectInfoModel(
      projectId: json['projectId'] as String,
      projectName: json['projectName'] as String,
      address: json['address'] as String,
      clientInfo: json['clientInfo'] as String?,
    );

Map<String, dynamic> _$ProjectInfoModelToJson(ProjectInfoModel instance) =>
    <String, dynamic>{
      'projectId': instance.projectId,
      'projectName': instance.projectName,
      'address': instance.address,
      'clientInfo': instance.clientInfo,
    };

TechnicianInfoModel _$TechnicianInfoModelFromJson(Map<String, dynamic> json) =>
    TechnicianInfoModel(
      userId: json['userId'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      roleName: json['roleName'] as String?,
    );

Map<String, dynamic> _$TechnicianInfoModelToJson(
  TechnicianInfoModel instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'fullName': instance.fullName,
  'email': instance.email,
  'username': instance.username,
  'roleName': instance.roleName,
};

WorkProgressItemModel _$WorkProgressItemModelFromJson(
  Map<String, dynamic> json,
) => WorkProgressItemModel(
  workProgressId: json['workProgressId'] as String,
  reportId: json['reportId'] as String,
  taskDescription: json['taskDescription'] as String,
  hoursWorked: (json['hoursWorked'] as num).toDouble(),
  percentageComplete: (json['percentageComplete'] as num).toInt(),
  notes: json['notes'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$WorkProgressItemModelToJson(
  WorkProgressItemModel instance,
) => <String, dynamic>{
  'workProgressId': instance.workProgressId,
  'reportId': instance.reportId,
  'taskDescription': instance.taskDescription,
  'hoursWorked': instance.hoursWorked,
  'percentageComplete': instance.percentageComplete,
  'notes': instance.notes,
  'createdAt': instance.createdAt,
};

PersonnelLogModel _$PersonnelLogModelFromJson(Map<String, dynamic> json) =>
    PersonnelLogModel(
      personnelLogId: json['personnelLogId'] as String,
      reportId: json['reportId'] as String,
      personnelName: json['personnelName'] as String,
      role: json['role'] as String,
      hoursWorked: (json['hoursWorked'] as num).toDouble(),
      overtimeHours: (json['overtimeHours'] as num).toDouble(),
      notes: json['notes'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$PersonnelLogModelToJson(PersonnelLogModel instance) =>
    <String, dynamic>{
      'personnelLogId': instance.personnelLogId,
      'reportId': instance.reportId,
      'personnelName': instance.personnelName,
      'role': instance.role,
      'hoursWorked': instance.hoursWorked,
      'overtimeHours': instance.overtimeHours,
      'notes': instance.notes,
      'createdAt': instance.createdAt,
    };

MaterialUsageModel _$MaterialUsageModelFromJson(Map<String, dynamic> json) =>
    MaterialUsageModel(
      materialUsageId: json['materialUsageId'] as String,
      reportId: json['reportId'] as String,
      materialName: json['materialName'] as String,
      quantityUsed: (json['quantityUsed'] as num).toInt(),
      unit: json['unit'] as String,
      notes: json['notes'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$MaterialUsageModelToJson(MaterialUsageModel instance) =>
    <String, dynamic>{
      'materialUsageId': instance.materialUsageId,
      'reportId': instance.reportId,
      'materialName': instance.materialName,
      'quantityUsed': instance.quantityUsed,
      'unit': instance.unit,
      'notes': instance.notes,
      'createdAt': instance.createdAt,
    };

EquipmentLogModel _$EquipmentLogModelFromJson(Map<String, dynamic> json) =>
    EquipmentLogModel(
      equipmentLogId: json['equipmentLogId'] as String,
      reportId: json['reportId'] as String,
      equipmentName: json['equipmentName'] as String,
      usageHours: (json['usageHours'] as num).toDouble(),
      condition: json['condition'] as String,
      notes: json['notes'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$EquipmentLogModelToJson(EquipmentLogModel instance) =>
    <String, dynamic>{
      'equipmentLogId': instance.equipmentLogId,
      'reportId': instance.reportId,
      'equipmentName': instance.equipmentName,
      'usageHours': instance.usageHours,
      'condition': instance.condition,
      'notes': instance.notes,
      'createdAt': instance.createdAt,
    };
