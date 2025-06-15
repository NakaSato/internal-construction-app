import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/daily_report.dart';

part 'daily_report_model.g.dart';

@JsonSerializable()
class DailyReportModel {
  @JsonKey(name: 'id')
  final String reportId;
  final String projectId;
  @JsonKey(name: 'technicianId')
  final String technicianId;
  final String reportDate;
  @JsonKey(name: 'status')
  final int statusValue;
  final String workStartTime;
  final String workEndTime;
  final String weatherConditions;
  final String overallNotes;
  final String safetyNotes;
  final String delaysOrIssues;
  final int photosCount;
  final String createdAt;
  final String updatedAt;
  final ProjectInfoModel? project;
  final TechnicianInfoModel? technician;
  final List<WorkProgressItemModel>? workProgressItems;
  final List<PersonnelLogModel>? personnelLogs;
  final List<MaterialUsageModel>? materialUsage;
  final List<EquipmentLogModel>? equipmentLogs;
  final String? approverComments;
  final String? rejectionReason;
  final String? submittedAt;
  final String? approvedAt;
  final String? rejectedAt;

  DailyReportModel({
    required this.reportId,
    required this.projectId,
    required this.technicianId,
    required this.reportDate,
    required this.statusValue,
    required this.workStartTime,
    required this.workEndTime,
    required this.weatherConditions,
    required this.overallNotes,
    required this.safetyNotes,
    required this.delaysOrIssues,
    required this.photosCount,
    required this.createdAt,
    required this.updatedAt,
    this.project,
    this.technician,
    this.workProgressItems,
    this.personnelLogs,
    this.materialUsage,
    this.equipmentLogs,
    this.approverComments,
    this.rejectionReason,
    this.submittedAt,
    this.approvedAt,
    this.rejectedAt,
  });

  // Factory constructor to create a model from JSON data
  factory DailyReportModel.fromJson(Map<String, dynamic> json) =>
      _$DailyReportModelFromJson(json);

  // Convert model to JSON map
  Map<String, dynamic> toJson() => _$DailyReportModelToJson(this);

  // Convert model to domain entity
  DailyReport toEntity() {
    return DailyReport(
      reportId: reportId,
      projectId: projectId,
      technicianId: technicianId,
      reportDate: DateTime.parse(reportDate),
      status: DailyReportStatus.fromValue(statusValue),
      workStartTime: workStartTime,
      workEndTime: workEndTime,
      weatherConditions: weatherConditions,
      overallNotes: overallNotes,
      safetyNotes: safetyNotes,
      delaysOrIssues: delaysOrIssues,
      photosCount: photosCount,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      project: project?.toEntity(),
      technician: technician?.toEntity(),
      workProgressItems:
          workProgressItems?.map((item) => item.toEntity()).toList() ?? [],
      personnelLogs: personnelLogs?.map((log) => log.toEntity()).toList() ?? [],
      materialUsage:
          materialUsage?.map((usage) => usage.toEntity()).toList() ?? [],
      equipmentLogs: equipmentLogs?.map((log) => log.toEntity()).toList() ?? [],
      approverComments: approverComments,
      rejectionReason: rejectionReason,
      submittedAt: submittedAt != null ? DateTime.parse(submittedAt!) : null,
      approvedAt: approvedAt != null ? DateTime.parse(approvedAt!) : null,
      rejectedAt: rejectedAt != null ? DateTime.parse(rejectedAt!) : null,
    );
  }

  // Create model from domain entity
  factory DailyReportModel.fromEntity(DailyReport entity) {
    return DailyReportModel(
      reportId: entity.reportId,
      projectId: entity.projectId,
      technicianId: entity.technicianId,
      reportDate: entity.reportDate.toIso8601String(),
      statusValue: entity.status.value,
      workStartTime: entity.workStartTime,
      workEndTime: entity.workEndTime,
      weatherConditions: entity.weatherConditions,
      overallNotes: entity.overallNotes,
      safetyNotes: entity.safetyNotes,
      delaysOrIssues: entity.delaysOrIssues,
      photosCount: entity.photosCount,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      project: entity.project != null
          ? ProjectInfoModel.fromEntity(entity.project!)
          : null,
      technician: entity.technician != null
          ? TechnicianInfoModel.fromEntity(entity.technician!)
          : null,
      workProgressItems: entity.workProgressItems.isNotEmpty
          ? entity.workProgressItems
                .map((item) => WorkProgressItemModel.fromEntity(item))
                .toList()
          : null,
      personnelLogs: entity.personnelLogs.isNotEmpty
          ? entity.personnelLogs
                .map((log) => PersonnelLogModel.fromEntity(log))
                .toList()
          : null,
      materialUsage: entity.materialUsage.isNotEmpty
          ? entity.materialUsage
                .map((usage) => MaterialUsageModel.fromEntity(usage))
                .toList()
          : null,
      equipmentLogs: entity.equipmentLogs.isNotEmpty
          ? entity.equipmentLogs
                .map((log) => EquipmentLogModel.fromEntity(log))
                .toList()
          : null,
      approverComments: entity.approverComments,
      rejectionReason: entity.rejectionReason,
      submittedAt: entity.submittedAt?.toIso8601String(),
      approvedAt: entity.approvedAt?.toIso8601String(),
      rejectedAt: entity.rejectedAt?.toIso8601String(),
    );
  }
}

// Sub-models

@JsonSerializable()
class ProjectInfoModel {
  final String projectId;
  final String projectName;
  final String address;
  final String? clientInfo;

  ProjectInfoModel({
    required this.projectId,
    required this.projectName,
    required this.address,
    this.clientInfo,
  });

  factory ProjectInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectInfoModelToJson(this);

  ProjectInfo toEntity() {
    return ProjectInfo(
      projectId: projectId,
      projectName: projectName,
      address: address,
      clientInfo: clientInfo,
    );
  }

  factory ProjectInfoModel.fromEntity(ProjectInfo entity) {
    return ProjectInfoModel(
      projectId: entity.projectId,
      projectName: entity.projectName,
      address: entity.address,
      clientInfo: entity.clientInfo,
    );
  }
}

@JsonSerializable()
class TechnicianInfoModel {
  final String userId;
  final String fullName;
  final String email;
  final String? username;
  final String? roleName;

  TechnicianInfoModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.username,
    this.roleName,
  });

  factory TechnicianInfoModel.fromJson(Map<String, dynamic> json) =>
      _$TechnicianInfoModelFromJson(json);

  Map<String, dynamic> toJson() => _$TechnicianInfoModelToJson(this);

  TechnicianInfo toEntity() {
    return TechnicianInfo(
      userId: userId,
      fullName: fullName,
      email: email,
      username: username,
      roleName: roleName,
    );
  }

  factory TechnicianInfoModel.fromEntity(TechnicianInfo entity) {
    return TechnicianInfoModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      username: entity.username,
      roleName: entity.roleName,
    );
  }
}

@JsonSerializable()
class WorkProgressItemModel {
  final String workProgressId;
  final String reportId;
  final String taskDescription;
  final double hoursWorked;
  final int percentageComplete;
  final String notes;
  final String createdAt;

  WorkProgressItemModel({
    required this.workProgressId,
    required this.reportId,
    required this.taskDescription,
    required this.hoursWorked,
    required this.percentageComplete,
    required this.notes,
    required this.createdAt,
  });

  factory WorkProgressItemModel.fromJson(Map<String, dynamic> json) =>
      _$WorkProgressItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkProgressItemModelToJson(this);

  WorkProgressItem toEntity() {
    return WorkProgressItem(
      workProgressId: workProgressId,
      reportId: reportId,
      taskDescription: taskDescription,
      hoursWorked: hoursWorked,
      percentageComplete: percentageComplete,
      notes: notes,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory WorkProgressItemModel.fromEntity(WorkProgressItem entity) {
    return WorkProgressItemModel(
      workProgressId: entity.workProgressId,
      reportId: entity.reportId,
      taskDescription: entity.taskDescription,
      hoursWorked: entity.hoursWorked,
      percentageComplete: entity.percentageComplete,
      notes: entity.notes,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}

@JsonSerializable()
class PersonnelLogModel {
  final String personnelLogId;
  final String reportId;
  final String personnelName;
  final String role;
  final double hoursWorked;
  final double overtimeHours;
  final String notes;
  final String createdAt;

  PersonnelLogModel({
    required this.personnelLogId,
    required this.reportId,
    required this.personnelName,
    required this.role,
    required this.hoursWorked,
    required this.overtimeHours,
    required this.notes,
    required this.createdAt,
  });

  factory PersonnelLogModel.fromJson(Map<String, dynamic> json) =>
      _$PersonnelLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$PersonnelLogModelToJson(this);

  PersonnelLog toEntity() {
    return PersonnelLog(
      personnelLogId: personnelLogId,
      reportId: reportId,
      personnelName: personnelName,
      role: role,
      hoursWorked: hoursWorked,
      overtimeHours: overtimeHours,
      notes: notes,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory PersonnelLogModel.fromEntity(PersonnelLog entity) {
    return PersonnelLogModel(
      personnelLogId: entity.personnelLogId,
      reportId: entity.reportId,
      personnelName: entity.personnelName,
      role: entity.role,
      hoursWorked: entity.hoursWorked,
      overtimeHours: entity.overtimeHours,
      notes: entity.notes,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}

@JsonSerializable()
class MaterialUsageModel {
  final String materialUsageId;
  final String reportId;
  final String materialName;
  final int quantityUsed;
  final String unit;
  final String notes;
  final String createdAt;

  MaterialUsageModel({
    required this.materialUsageId,
    required this.reportId,
    required this.materialName,
    required this.quantityUsed,
    required this.unit,
    required this.notes,
    required this.createdAt,
  });

  factory MaterialUsageModel.fromJson(Map<String, dynamic> json) =>
      _$MaterialUsageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialUsageModelToJson(this);

  MaterialUsage toEntity() {
    return MaterialUsage(
      materialUsageId: materialUsageId,
      reportId: reportId,
      materialName: materialName,
      quantityUsed: quantityUsed,
      unit: unit,
      notes: notes,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory MaterialUsageModel.fromEntity(MaterialUsage entity) {
    return MaterialUsageModel(
      materialUsageId: entity.materialUsageId,
      reportId: entity.reportId,
      materialName: entity.materialName,
      quantityUsed: entity.quantityUsed,
      unit: entity.unit,
      notes: entity.notes,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}

@JsonSerializable()
class EquipmentLogModel {
  final String equipmentLogId;
  final String reportId;
  final String equipmentName;
  final double usageHours;
  final String condition;
  final String notes;
  final String createdAt;

  EquipmentLogModel({
    required this.equipmentLogId,
    required this.reportId,
    required this.equipmentName,
    required this.usageHours,
    required this.condition,
    required this.notes,
    required this.createdAt,
  });

  factory EquipmentLogModel.fromJson(Map<String, dynamic> json) =>
      _$EquipmentLogModelFromJson(json);

  Map<String, dynamic> toJson() => _$EquipmentLogModelToJson(this);

  EquipmentLog toEntity() {
    return EquipmentLog(
      equipmentLogId: equipmentLogId,
      reportId: reportId,
      equipmentName: equipmentName,
      usageHours: usageHours,
      condition: condition,
      notes: notes,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory EquipmentLogModel.fromEntity(EquipmentLog entity) {
    return EquipmentLogModel(
      equipmentLogId: entity.equipmentLogId,
      reportId: entity.reportId,
      equipmentName: entity.equipmentName,
      usageHours: entity.usageHours,
      condition: entity.condition,
      notes: entity.notes,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
